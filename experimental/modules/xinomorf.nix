{ lib, config, pkgs, ... }:

let
  inherit (import ../../lib { inherit lib; }) terraformStubs;
in {
  options.resources = lib.mkOption {
    type = lib.types.attrs;
    default = {};
  };

  config.activationScript = with lib; with terraformStubs { vars = {}; }; let
    mkResources = type: mapAttrsToList (name: attrs: resource type name attrs []);
    resources   = flatten (mapAttrsToList mkResources config.resources);
  in with pkgs; writeScript "hello" ''
    #!${stdenv.shell}
    cat <<EOF
    ${lib.concatStringsSep "\n" resources}
    EOF
  '';
}
