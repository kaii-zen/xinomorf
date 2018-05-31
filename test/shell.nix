{ pkgs ? import <nixpkgs> {}
, self ? pkgs.callPackage ./. {}
, cli  ? pkgs.callPackage ../. {}
}: self.shell { inherit self cli; }
