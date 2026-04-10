{ ... }:
{
  perSystem =
    { pkgs, fenix, ... }:
    let
      toolchain = fenix.stable.withComponents [
        "cargo"
        "clippy"
        "rustc"
        "rustfmt"
        "rust-src"
      ];
      rustInputs = with pkgs; [
        toolchain
        fenix.rust-analyzer
        cargo-audit
        cargo-deny
        cargo-flamegraph
        cargo-geiger
        cargo-machete
        cargo-make
        cargo-nextest
        cargo-tarpaulin
        tokei
      ];
      zigInputs = with pkgs; [
        zig
        zls
      ];
    in
    {
      devShells = {
        default = pkgs.mkShell { buildInputs = rustInputs ++ zigInputs; };
        rust = pkgs.mkShell { buildInputs = rustInputs; };
        zig = pkgs.mkShell { buildInputs = zigInputs; };
      };
    };
}
