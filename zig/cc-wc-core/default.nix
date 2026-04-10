{
  lib,
  stdenv,
  zig,
  cc-wc-core-zig-version,
}:

stdenv.mkDerivation {
  pname = "cc-wc-core-zig";
  version = "${cc-wc-core-zig-version.major}.${cc-wc-core-zig-version.minor}.${cc-wc-core-zig-version.patch}";
  src = ./.;
  meta = {
    description = "cc-wc core library (Zig)";
    owner = "xdeathofmojox";
  };
  nativeBuildInputs = [
    zig.hook
  ];
  outputs = [
    "out"
    "dev"
  ];
}
