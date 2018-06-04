{ pkgs     ? import <nixpkgs> {}
, xinomorf ? import (builtins.fetchGit https://github.com/kreisys/xinomorf.git + "/lib/wrap-deployment.nix") { inherit pkgs; }}:


xinomorf {
  name   = builtins.baseNameOf (builtins.getEnv "PWD");
  src    = ./.;
}
