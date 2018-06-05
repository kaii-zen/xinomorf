{ lib ? import <nixpkgs/lib> {}}:

rec {
  stringify = import ./stringify.nix { inherit lib; };
  terraformStubs = import ./terraform-stubs.nix { inherit stringify; };
}
