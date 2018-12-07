{ lib }:

with builtins;
with lib;

let
  stringify' = { quoteStr ? str: ''"${str}"'' }: obj:
    if isDerivation obj
    then quoteStr obj
    else if isAttrs obj
    then attrsToStr obj []
    else if isList obj
    then listToStr obj
    else if isBool obj || isInt obj || isFloat obj
    then toString obj
    else quoteStr obj;

  stringify = stringify' {};
  stringifyNoQuotes = stringify' { quoteStr = lib.id; };

  attrsToStr = attrs: list: ''
    {
    ${
      concatStringsSep "\n" (mapAttrsToList (name: value: "  ${name} = ${stringify value}") attrs)
    }
    ${
      concatStringsSep "\n" (map stringifyNoQuotes list)
    }}
  '';

  listToStr = list: ''
    [
    ${
      concatStringsSep ",\n" (map stringify list)
    }]
  '';
in {
  inherit stringify;
  stringifyAttrs = attrsToStr;
}
