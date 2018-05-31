{ pkgs, self, cli }:

with builtins;

let
  aliases = self.aliases self;
in pkgs.mkShell {
  buildInputs = [ self pkgs.bashInteractive aliases cli ];
  shellHook = ''
    if ! env | grep '^DIRENV' &>/dev/null; then
      # We aren't allowed to print anything when
      # using direnv nix integration...
      echo "NO DIRENV"
    fi
  '';
}
