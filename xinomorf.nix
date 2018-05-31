{ pkgs ? import <nixpkgs> {}}:

with builtins;

{ name, src, filter ? _: _: true, vars ? {} }: let
  inherit (pkgs.lib) mapAttrsToList filterAttrs hasSuffix removeSuffix mutuallyExclusive;

  stringify = import ./stringify.nix { inherit (pkgs.lib) mapAttrsToList; };
  terraformStubs = import ./stubs.nix { inherit stringify vars; };

  files = let
    regular = attrNames (filterAttrs (_: v: v == "regular") (readDir src));
    tf    = builtins.filter (filename: hasSuffix ".tf"     filename) regular;
    tfNix = builtins.filter (filename: hasSuffix ".tf.nix" filename) regular;
  in if mutuallyExclusive tf (map (removeSuffix ".nix") tfNix) then {
    inherit tf tfNix;
  } else throw "Filenames must be unique (can't have both foo.tf.nix and foo.tf)";
in pkgs.runCommand name {
  src = path {
    path = src;
    filter = path: type: match "^.*\.nix$" path == null && type != "symlink" && filter path type;
  };
  buildInputs = [ pkgs.terraform pkgs.git ];
} ''
  set -e
  mkdir -p $out/{lib,etc}/terraform $out/bin

  cd $src
  cp -r * $out/etc/terraform

  cd $out/etc/terraform
  ${concatStringsSep "\n" (map (fileName: ''
    cat <<'EOF' > ${removeSuffix ".nix" fileName}
    ${concatStringsSep "\n" (import (src + "/${fileName}") terraformStubs)}
    EOF
    ''
  ) files.tfNix)}

  terraform fmt

  export TF_DATA_DIR=$out/lib/terraform
  terraform init

  cat <<EOF > $out/bin/xf-${name}
  #!${pkgs.stdenv.shell}
  export TF_DATA_DIR=$out/lib/terraform
  case \$1 in
    init)
      echo no
      ;;
    plan)
      ${pkgs.terraform}/bin/terraform plan -state=\$PWD/terraform.tfstate $out/etc/terraform
      ;;
  esac
  EOF
  chmod +x $out/bin/xf-${name}
''
