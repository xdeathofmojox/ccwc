{
  stdenv,
  zig,
  cc-wc-core-src,
}:
let
  zonContent = builtins.readFile ./build.zig.zon;
  zonFlat = builtins.replaceStrings [ "\n" ] [ " " ] zonContent;
  versionMatch = builtins.match ''.*\.version = "([0-9]+\.[0-9]+\.[0-9]+)".*'' zonFlat;
  version = builtins.head versionMatch;
in
stdenv.mkDerivation {
  pname = "cc-wc-zig";
  inherit version;
  src = ./.;
  meta = {
    description = "cc-wc executable (Zig)";
    owner = "xdeathofmojox";
  };
  nativeBuildInputs = [
    zig.hook
  ];

  postUnpack = ''
    cp -r ${cc-wc-core-src} cc-wc-core
  '';
}
