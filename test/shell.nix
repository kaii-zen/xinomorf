{ pkgs ? import <nixpkgs> {}}:
let
  inherit (pkgs) mkShell callPackage;
  this = callPackage ./. {};
in pkgs.mkShell {
  buildInputs = [ this ];
  # shellHook = ''
  #   init 1>&2
  # '';
}
