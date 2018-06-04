# We have to use bashInteractive
# because otherwise `compgen`
# won't be available...    ↴
{ runCommand, bashInteractive, writeText }:

let
  usage = writeText "xinomorf-usage.txt" ''
    Usage: xinomorf [--version] [--help] <command> [args]

    The available commands for execution are listed below.

    Commands:
        list|ls             List deployments installed on this system
        plan                Create a Terraform deployment plan
        apply               Apply a Terraform plan
        destroy             Destroy a Terraform deployment
        init                Initialize a new project
  '';

in runCommand "xinomorf" {} ''
  mkdir -p $out/bin

  cat <<'EOF' > $out/bin/xinomorf
  #!${bashInteractive}/bin/bash
  pref="xf"

  stderr() {
    1>&2 echo -e "$@"
  }

  err() {
    stderr "\e[31merror\e[0m:" "$@"
  }

  indent() {
    sed 's/^/  /'
  }

  deployments() {
    compgen -c $pref- | cut -d- -f2
  }

  has_deployment() {
    local deployment=$1
    deployments | grep "^$deployment$" &>/dev/null
  }

  cmd=$1
  shift

  case $cmd in
    list|ls)
      deployments
      ;;
    init)
      echo Initializing new project $PWD
      cp -r ${./skel}/. .
      chmod -R +w .
      ;;
    plan|apply|destroy)
      deployment=$1
      shift

      if [[ -z $deployment ]] || ! has_deployment $deployment; then
        err "Must specify a valid deployment."
        stderr "Available deployments:"
        deployments | indent
        exit 1
      fi

      exec $pref-$deployment $cmd "$@"
      ;;
    *)
      cat ${usage}
      ;;

  esac
  EOF
  chmod +x $out/bin/xinomorf
  ln -s $out/bin/xinomorf $out/bin/xm
''
