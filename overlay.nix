final: prev: rec {
  # Rust packages
  cc-wc-rust = final.rustPlatform.buildRustPackage {
    pname = (final.lib.importTOML ./Cargo.toml).workspace.metadata.crane.name;
    version = (final.lib.importTOML ./Cargo.toml).workspace.package.version;
    src = ./.;
    cargoLock.lockFile = ./Cargo.lock;
    buildAndTestSubdir = "./crates/cc-wc";
  };
  cc-wc-core-rust = final.rustPlatform.buildRustPackage {
    pname = (final.lib.importTOML ./crates/cc-wc-core/Cargo.toml).package.name;
    version = (final.lib.importTOML ./crates/cc-wc-core/Cargo.toml).package.version;
    src = ./.;
    cargoLock.lockFile = ./Cargo.lock;
    buildAndTestSubdir = "./crates/cc-wc-core";
  };
  # Zig packages
  cc-wc-core-zig-version = {
    major = "0";
    minor = "2";
    patch = "0";
  };
  cc-wc-core-zig = final.callPackage ./zig/cc-wc-core { };
  cc-wc-zig-version = {
    major = "0";
    minor = "2";
    patch = "0";
  };
  cc-wc-zig = final.callPackage ./zig/cc-wc { };
}
