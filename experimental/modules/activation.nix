{ pkgs, ... }:
with pkgs;

{
  options.activationScript = lib.mkOption {
    type = lib.types.path;
    default = writeScript "hello" ''
      #!${stdenv.shell}
      echo HI
    '';
  };
}
