{ inputs, ... }:
{
  # Personal account details live outside the repo (see `private` in flake.nix)
  imports = [ "${inputs.private}/email.nix" ];

  # Geary is enabled at the system level (hosts/common.nix): it's a NixOS
  # option that also sets up gnome-keyring and dconf.

  programs.aerc = {
    enable = true;
    extraConfig.general.unsafe-accounts-conf = true;
  };
}
