{ pkgs ? import <nixpkgs> {} }:

let
  src = builtins.fetchGit {
    url = https://github.com/kreisys/xinomorf.git;
    rev = "3767c9b4526bd81d8e1c57f191249cb09ca61c74
";
  };
in import src {}
