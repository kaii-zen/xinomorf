### http://nixos.org/channels/nixos-18.03 nixos
### s3://benbria/asg/nixostest/nixexprs.tar.bz2 bootstrap

{
  imports = [
    <nixos/nixos/modules/virtualisation/amazon-image.nix>
    <bootstrap/configuration.nix>
  ];
}
