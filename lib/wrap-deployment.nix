{ pkgs ? import <nixpkgs> {}}:

with builtins;

{ name, src, filter ? _: _: true, vars ? {} }: let
  inherit (pkgs.lib) mapAttrsToList filterAttrs hasSuffix removeSuffix mutuallyExclusive isDerivation;

  stringify = import ./stringify.nix { inherit (pkgs.lib) mapAttrsToList; };
  terraformStubs = import ./terraform-stubs.nix { inherit stringify vars; };

  files = let
    regular = attrNames (filterAttrs (_: v: v == "regular") (readDir src));
    tf    = builtins.filter (filename: hasSuffix ".tf"     filename) regular;
    tfNix = builtins.filter (filename: hasSuffix ".tf.nix" filename) regular;
  in if mutuallyExclusive tf (map (removeSuffix ".nix") tfNix) then {
    inherit tf tfNix;
  } else throw "Filenames must be unique (can't have both foo.tf.nix and foo.tf)";
in pkgs.runCommand name {
  src = if isDerivation src then (src + "/etc/terraform") else path {
    path = src;
    filter = path: type: match "^.*\.nix$" path == null && type != "symlink" && filter path type;
  };
  buildInputs = [ pkgs.terraform pkgs.git ];

  passthru = {
    shell = { self, cli }: import ../pkgs/shell { inherit pkgs self cli; };
    aliases = self: pkgs.runCommand "${self.name}-aliases" {} '' mkdir -p $out/bin
      ln -s ${self}/bin/xf-${self.name} $out/bin/plan
      ln -s ${self}/bin/xf-${self.name} $out/bin/apply
      ln -s ${self}/bin/xf-${self.name} $out/bin/destroy
      ln -s ${self}/bin/xf-${self.name} $out/bin/terraform
    '';
  };

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
  PATH=${pkgs.terraform}/bin:$PATH

  tf_stat="\$PWD/terraform.tfstate"
  tf_conf="$out/etc/terraform"
  tf_data="$out/lib/terraform"

  export TF_DATA_DIR="\$tf_data"

  bin="\$(basename \$0)"
  if [[ \$bin == xf-${name} ]]; then
    cmd="\$1"
    shift
  else
    cmd="\$bin"
  fi

  case \$cmd in
    init)
      echo no
      ;;
    plan|apply|destroy)
      exec terraform \$cmd -state=\$tf_stat "\$@" $out/etc/terraform
      ;;
    terraform)
      case \$1 in
        fmt)
          exec terraform "\$@"
          ;;
        *)
          echo "Please don't run terraform directly"
          exit 1
        ;;
      esac
      ;;
  esac
  EOF
  chmod +x $out/bin/xf-${name}
''
