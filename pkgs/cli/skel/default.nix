{ pkgs     ? import <nixpkgs> {}
, xinomorf ? import ((import ./xinomorf.nix) + "/lib/wrap-deployment.nix") { inherit pkgs; }}:


xinomorf {
  name   = builtins.baseNameOf (builtins.getEnv "PWD");
  src    = ./.;
}
