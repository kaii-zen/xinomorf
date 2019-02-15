{ entrypoint }:

(import ./nixpkgs.nix).lib.evalModules {
  modules = [
    ./modules
    (./. + "/${entrypoint}")
  ];
}
