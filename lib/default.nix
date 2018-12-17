{ lib ? import <nixpkgs/lib>}:

let stringify' = import ./stringify.nix { inherit lib; }; in
rec {
  inherit (stringify') stringify stringifyAttrs;
  terraformStubs = import ./terraform-stubs.nix { inherit stringify stringifyAttrs lib; };
}
