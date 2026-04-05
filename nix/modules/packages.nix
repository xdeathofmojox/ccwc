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
        default = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });
        cc-wc = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });
      };
      legacyPackages = pkgs;
    };
}
