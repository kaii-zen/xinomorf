{ lib, stringify, stringifyAttrs }:

{ vars }:

rec {
  data = type: name: attrs: ''
    data ${stringify type} ${stringify name} ${stringify attrs}
  '';

  resource = type: name: attrs: list: ''
    resource ${stringify type} ${stringify name} ${stringifyAttrs attrs list}
  '';

  provider = name: attrs: ''
    provider ${stringify name} ${stringify attrs}
  '';

  provisioner = name: attrs: ''
    provisioner ${stringify name} ${stringify attrs}
  '';

  module = name: attrs: with lib; let
    getTfvars = path: if (builtins.readDir path) ? "terraform.tfvars.json" then importJSON "${path}/terraform.tfvars.json" else {};
    extraAttrs = if attrs ? source then getTfvars attrs.source else {};
  in ''
    module ${stringify name} ${stringify (recursiveUpdate extraAttrs attrs)}
  '';

  locals = attrs: ''
    locals ${stringify attrs}
  '';

  variable = name: attrs: ''
    variable ${stringify name} ${stringify attrs}
  '';

  var = vars;
}
