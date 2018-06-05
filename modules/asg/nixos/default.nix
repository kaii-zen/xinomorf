{ lib, runCommand, configuration ? null }:

runCommand "nixexprs.tar.bz2" {
  src = ./.;
} ''
  cp -r $src bootstrap
  chmod -R +w bootstrap
  ${lib.optionalString (configuration != null) ''
    cp -r ${configuration}/* bootstrap/hook/
  ''}
  tar cjvf $out bootstrap
''
