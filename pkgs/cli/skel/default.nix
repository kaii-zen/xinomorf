{ pkgs     ? import <nixpkgs> {}
, xinomorf ? import ../xinomorf.nix { inherit pkgs; }}:


xinomorf {
  name   = "test";
  src    = pkgs.callPackage ./module {
    inherit xinomorf;
    configuration = ./nixos;
  };
  filter = path: _: builtins.match "^.*/nixos(/.*)?$" path == null;
}
