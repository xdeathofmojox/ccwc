{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      apps = {
        cc-wc-zig = {
          type = "app";
          program = "${pkgs.cc-wc-zig}/bin/cc-wc";
        };
        cc-wc-rust = {
          type = "app";
          program = "${pkgs.cc-wc-rust}/bin/cc-wc";
        };
      };
    };
}
