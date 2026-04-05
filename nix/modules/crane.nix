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
      _module.args = {
        inherit craneLib commonArgs cargoArtifacts;
      };
    };
}
