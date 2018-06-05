{ pkgs ? import <nixpkgs> {}, configuration ? null }:

import ../../. {
  inherit pkgs;
  src    = ./.;
  filter = path: _: builtins.match "^.*/nixos(/.*)?$" path == null;
  vars   = {
    bootstrap = pkgs.callPackage ./nixos { inherit configuration; };
  };
}
