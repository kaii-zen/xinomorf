{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, src ? builtins.getEnv "PWD"
, name ? if pkgs.lib.isDerivation src then src.name else builtins.baseNameOf src
, filter ? _: _: true
, vars ? {}
}:

let
  callPackage = pkgs.newScope self;
  self = rec {
    inherit src name filter vars;
    inherit (callPackage ./pkgs {}) wrapper shell cli;
    inherit (import ./lib { inherit lib; }) terraformStubs;
  };
in self
