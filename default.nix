{ pkgs ? import <nixpkgs> {}
, src ? builtins.getEnv "PWD"
, name ? if pkgs.lib.isDerivation src then src.name else builtins.baseNameOf src
, filter ? _: _: true
, vars ? {}
}:

let
  callPackage = pkgs.newScope self;
  self = rec {
    inherit src name filter vars;
    inherit (callPackage ./pkgs {}) wrapper shell;
    inherit (import ./lib { inherit (pkgs) lib; }) terraformStubs;
  };
in self
