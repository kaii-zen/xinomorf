{ pkgs ? import <nixpkgs> {}
, self ? pkgs.callPackage ./. {}
, cli  ? pkgs.callPackage (import ./xinomorf.nix) {}
}: self.shell { inherit self cli; }
