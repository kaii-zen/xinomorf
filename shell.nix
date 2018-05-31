{ pkgs ? import <nixpkgs> {}
, self ? pkgs.callPackage ./test {}}:

with builtins;

let
  aliases = self.aliases self;
in pkgs.mkShell {
  buildInputs = [ self pkgs.bashInteractive aliases ];
  shellHook = ''
    if ! env | grep '^DIRENV' &>/dev/null; then
      echo "NO DIRENV"
    fi
  '';
}
