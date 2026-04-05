{ inputs, ... }:
{
  perSystem =
    { pkgs, fenix, ... }:
    let
      craneLib = (inputs.crane.mkLib pkgs).overrideToolchain fenix.stable.toolchain;
      src = craneLib.cleanCargoSource inputs.self;
      commonArgs = {
        inherit src;
        strictDeps = true;
      };
      cargoArtifacts = craneLib.buildDepsOnly commonArgs;
    in
    {
      checks = {
        clippy = craneLib.cargoClippy (
          commonArgs
          // {
            inherit cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          }
        );

        tests = craneLib.cargoNextest (commonArgs // { inherit cargoArtifacts; });

        machete = craneLib.mkCargoDerivation (
          commonArgs
          // {
            inherit cargoArtifacts;
            nativeBuildInputs = [ pkgs.cargo-machete ];
            buildPhaseCargoCommand = "cargo machete";
          }
        );

        audit = craneLib.cargoAudit (
          commonArgs
          // {
            advisory-db = inputs.advisory-db;
          }
        );

        deny = craneLib.cargoDeny (commonArgs // { });
      };
    };
}
