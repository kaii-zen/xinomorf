{ runCommand }:

runCommand "nixexprs.tar.bz2" {
  src = ./.;
} ''
  tar cjf $out -C $(dirname $src) --strip-components=1 $(basename $src)
''
