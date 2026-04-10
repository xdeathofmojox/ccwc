{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      craneLib,
      commonArgs,
      cargoArtifacts,
      ...
    }:
    {
      checks = {
        zig-test-cc-wc = pkgs.stdenv.mkDerivation {
          name = "zig-test-cc-wc";
          src = ../../zig/cc-wc;
          nativeBuildInputs = [ pkgs.zig ];
          buildPhase = "zig build test";
          installPhase = "touch $out";
        };

        zig-test-cc-wc-core = pkgs.stdenv.mkDerivation {
          name = "zig-test-cc-wc-core";
          src = ../../zig/cc-wc-core;
          nativeBuildInputs = [ pkgs.zig ];
          buildPhase = "zig build test";
          installPhase = "touch $out";
        };

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
