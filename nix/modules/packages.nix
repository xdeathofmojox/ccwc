{ ... }:
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
      packages = {
        default = craneLib.buildPackage (
          commonArgs
          // {
            inherit cargoArtifacts;
            cargoExtraArgs = "-p cc-wc";
          }
        );
        cc-wc-rust = craneLib.buildPackage (
          commonArgs
          // {
            inherit cargoArtifacts;
            cargoExtraArgs = "-p cc-wc";
          }
        );
        cc-wc-core-rust = craneLib.buildPackage (
          commonArgs
          // craneLib.crateNameFromCargoToml { cargoToml = ./../../crates/cc-wc-core/Cargo.toml; }
          // {
            inherit cargoArtifacts;
            cargoExtraArgs = "-p cc-wc-core";
          }
        );
        inherit (pkgs) cc-wc-zig cc-wc-core-zig;
      };
      legacyPackages = pkgs;
    };
}
