{ newScope, terraformStubs
, name
, src
, filter
, vars
, }:

let
  callPackage = newScope self;
  self = rec {
    inherit name src filter vars terraformStubs;
    wrapper = callPackage ./wrapper.nix {};
    aliases = callPackage ./aliases.nix {};
  };
in self
