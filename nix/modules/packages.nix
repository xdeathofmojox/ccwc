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
        ccwc = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });
      };
      legacyPackages = pkgs;
    };
}
