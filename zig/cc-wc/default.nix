{
  stdenv,
  zig,
  cc-wc-zig-version,
}:

stdenv.mkDerivation {
  pname = "cc-wc-zig";
  version = "${cc-wc-zig-version.major}.${cc-wc-zig-version.minor}.${cc-wc-zig-version.patch}";
  src = ./.;
  meta = {
    description = "cc-wc executable (Zig)";
    owner = "xdeathofmojox";
  };
  nativeBuildInputs = [
    zig.hook
  ];
}
