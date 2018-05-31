{ pkgs ? import <nixpkgs> {}
, self ? pkgs.callPackage ./. {}
}: self.shell self
