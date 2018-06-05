{ newScope, wrapper, terraformStubs
, name
, src
, filter
, vars }:

let
  callPackage = newScope self;
  self = rec {
    inherit name src filter vars terraformStubs;
    inherit (callPackage ./wrapper {}) wrapper aliases;
    cli   = callPackage ./cli {};
    shell = callPackage ./shell {};
  };
in self
