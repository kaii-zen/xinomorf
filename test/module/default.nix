{ pkgs     ? import <nixpkgs> {}
, xinomorf ? import ../../xinomorf.nix { inherit pkgs; }
, configuration ? null }:

xinomorf {
  name   = "module";
  src    = ./.;
  filter = path: _: builtins.match "^.*/nixos(/.*)?$" path == null;
  vars   = {
    bootstrap = pkgs.callPackage ./nixos { inherit configuration; };
  };
}
