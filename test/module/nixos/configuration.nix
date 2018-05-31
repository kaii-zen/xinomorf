{ pkgs, config, ... }:
{
  imports = [ ./hook/configuration.nix ];
  # That's all the config we need to enable SSM to rebuild the system
  services.ssm-agent.enable = true;
  systemd.services.ssm-agent = {
    path = [ pkgs.bash config.system.build.nixos-rebuild ];
    environment.NIX_PATH = builtins.concatStringsSep ":" config.nix.nixPath;
  };
}
