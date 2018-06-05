{ lib }:

with builtins;
with lib;

let
  stringify = obj: if isString obj
                   then quoteStr obj
                   else if isAttrs obj
                   then attrsToStr obj
                   else if isList obj
                   then listToStr obj
                   else toString obj;

  quoteStr = str: ''"${str}"'';

  attrsToStr = attrs: ''
    {
    ${
      concatStringsSep "" (mapAttrsToList (name: value: "  ${name} = ${stringify value}\n") attrs)
    }}
  '';

  listToStr = list: ''
    [
    ${
      concatStringsSep ",\n" (map stringify list)
    }]
  '';
in stringify
