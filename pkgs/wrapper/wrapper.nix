{ stdenv, lib, runCommand, terraform, git, terraformStubs
, name
, src
, filter
, vars }:

with builtins;
with lib;

let
  files = let
    regular = attrNames (filterAttrs (_: v: v == "regular") (readDir src));
    tf    = builtins.filter (filename: hasSuffix ".tf"     filename) regular;
    tfNix = builtins.filter (filename: hasSuffix ".tf.nix" filename) regular;
  in if mutuallyExclusive tf (map (removeSuffix ".nix") tfNix) then {
    inherit tf tfNix;
  } else throw "Filenames must be unique (can't have both foo.tf.nix and foo.tf)";
in runCommand name {
  src = if isDerivation src then (src + "/etc/terraform") else path {
    path = src;
    filter = path: type: match "^.*\.nix$" path == null && type != "symlink" && filter path type;
  };
  buildInputs = [ terraform git ];

} ''
  set -e
  mkdir -p $out/{lib,etc}/terraform $out/bin

  cd $src
  cp -r * $out/etc/terraform

  cd $out/etc/terraform
  ${concatStringsSep "\n" (map (fileName: ''
    cat <<'EOF' > ${removeSuffix ".nix" fileName}
    ${concatStringsSep "\n" (import (src + "/${fileName}") (terraformStubs { inherit vars; }))}
    EOF
    ''
  ) files.tfNix)}

  terraform fmt

  export TF_DATA_DIR=$out/lib/terraform
  terraform init

  cat <<EOF > $out/bin/xf-${name}
  #!${stdenv.shell}
  PATH=${terraform}/bin:$PATH

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