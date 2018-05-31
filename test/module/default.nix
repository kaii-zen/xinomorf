{ pkgs      ? import <nixpkgs> {}
, xenomorph ? import ../xenomorph.nix { inherit pkgs; }}:

xenomorph {
  name   = "test";
  src    = ./module;
  filter = path: _: builtins.match "^.*/nixos(/.*)?$" path == null;
  vars   = {
    bootstrap = pkgs.callPackage ./nixos {};
  };
}
