{ pkgs ? import <nixpkgs> {}
, self ? pkgs.callPackage ./. {}
, cli  ? pkgs.callPackage (builtins.fetchGit https://github.com/kreisys/xinomorf.git) {}
}: self.shell { inherit self cli; }
