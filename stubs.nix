{ stringify, vars }:

{
  data = type: name: attrs: ''
    data ${stringify type} ${stringify name} ${stringify attrs}
  '';

  resource = type: name: attrs: ''
    resource ${stringify type} ${stringify name} ${stringify attrs}
  '';

  provider = name: attrs: ''
    provider ${stringify name} ${stringify attrs}
  '';

  module = name: attrs: ''
    module ${stringify name} ${stringify attrs}
  '';

  locals = attrs: ''
    locals ${stringify attrs}
  '';

  variable = name: attrs: ''
    variable ${stringify name} ${stringify attrs}
  '';

  var = vars;
}
