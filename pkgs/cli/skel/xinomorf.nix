{ pkgs ? import <nixpkgs> {} }:

let
  src = builtins.fetchGit {
    url = https://github.com/kreisys/xinomorf.git;
    rev = "a9998c4dc379e79a803beee2505efc58f995bee6";
  };
in import src {}
