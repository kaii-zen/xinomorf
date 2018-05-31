{ pkgs ? import <nixpkgs> {}
, self ? pkgs.callPackage ./test {}
, cli  ? pkgs.callPackage ./. {}}:

import ./pkgs/shell { inherit pkgs self cli; }
