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
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
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
      };
    };
}
