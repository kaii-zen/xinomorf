{ configuration ? null }:

(import ./xinomorf.nix { inherit configuration; }).wrapper
