{ lib, stringify, stringifyAttrs }:

{ vars }:

rec {
  data = type: name: attrs: {
    __toString = self: ''
    data ${stringify type} ${stringify name} ${stringify attrs}
  '';
  };

  resource = type: name: attrs: list: {
    inherit type name attrs list;
    __toString = self: ''
      resource ${stringify type} ${stringify name} ${stringifyAttrs attrs list}
    '';
  };

  provider = name: attrs: {
    inherit name attrs;
    __toString = self: ''
      provider ${stringify name} ${stringify attrs}
    '';
  };

  provisioner = name: attrs: ''
    provisioner ${stringify name} ${stringify attrs}
  '';

  module = name: attrs: with lib; let
    getTfvars = path: if (builtins.readDir path) ? "terraform.tfvars.json" then importJSON "${path}/terraform.tfvars.json" else {};
    extraAttrs = if attrs ? source then getTfvars attrs.source else {};
  in {
    inherit name attrs;
    __toString = self: ''
      module ${stringify name} ${stringify (recursiveUpdate extraAttrs attrs)}
    '';
  };

  locals = attrs: ''
    locals ${stringify attrs}
  '';

  variable = name: attrs: ''
    variable ${stringify name} ${stringify attrs}
  '';

  var = vars;
}
