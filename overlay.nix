final: prev: {
  cc-wc = final.rustPlatform.buildRustPackage {
    pname = (final.lib.importTOML ./Cargo.toml).package.name;
    version = (final.lib.importTOML ./Cargo.toml).package.version;
    src = ./.;
    cargoLock.lockFile = ./Cargo.lock;
  };
}
