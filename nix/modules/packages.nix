{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        default = pkgs.ccwc;
        inherit (pkgs)
          ccwc
          ;
      };
      legacyPackages = pkgs;
    };
}
