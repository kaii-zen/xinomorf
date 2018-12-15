{ newScope, wrapper, terraformStubs
, name
, src
, filter
, modules
, vars }:

let
  callPackage = newScope self;
  self = rec {
    inherit name src filter vars terraformStubs modules;
    inherit (callPackage ./wrapper {}) wrapper aliases;
    cli   = callPackage ./cli {};
    shell = callPackage ./shell {};
  };
in self
