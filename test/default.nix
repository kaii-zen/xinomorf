{ pkgs      ? import <nixpkgs> {}
, xinomorf ? import ../xinomorf.nix { inherit pkgs; }}:

xinomorf {
  name   = "test";
  src    = ./module;
  filter = path: _: builtins.match "^.*/nixos(/.*)?$" path == null;
  vars   = {
    bootstrap = pkgs.callPackage ./nixos {};
  };
}
