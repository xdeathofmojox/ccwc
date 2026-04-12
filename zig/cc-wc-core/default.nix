{
  lib,
  stdenv,
  zig,
}:
let
  zonContent = builtins.readFile ./build.zig.zon;
  zonFlat = builtins.replaceStrings [ "\n" ] [ " " ] zonContent;
  versionMatch = builtins.match ''.*\.version = "([0-9]+\.[0-9]+\.[0-9]+)".*'' zonFlat;
  version = builtins.head versionMatch;
in
stdenv.mkDerivation {
  pname = "cc-wc-core-zig";
  inherit version;
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
