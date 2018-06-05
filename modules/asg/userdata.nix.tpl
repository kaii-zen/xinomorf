### http://nixos.org/channels/nixos-18.03 nixos
### ${url} bootstrap

{
  imports = [
    <nixos/nixos/modules/virtualisation/amazon-image.nix>
    <bootstrap/configuration.nix>
  ];
}
