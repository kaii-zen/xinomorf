{ pkgs ? import <nixpkgs> {} }:

import ../../../. {
  inherit pkgs;
  src = pkgs.callPackage ../. {
    configuration = ./nixos;
  };
  filter = path: _: builtins.match "^.*/nixos(/.*)?$" path == null;
}
