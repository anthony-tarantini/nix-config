# Settings shared by every host.
{ pkgs, user, unstable, inputs, ... }:
{
  # Nixpkgs
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
  ];

  # Nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;

  # Flake-only: no nix-channel. NIX_PATH and the registry point at the
  # flake's pinned nixpkgs (nixpkgs=flake:nixpkgs).
  nix.channel.enable = false;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # System
  environment.pathsToLink = [ "/share/zsh" ];
  environment.localBinInPath = true;
  environment.systemPackages = with pkgs; [
    docker-client
    docker-compose
  ];

  hardware.graphics.enable = true;

  # Email GUI (NixOS-level: also enables gnome-keyring + dconf). See home/email.nix.
  programs.geary.enable = true;
  programs.nix-ld.enable = true;

  # Shell (login shell must be registered at the system level)
  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;

  users.users.${user}.shell = pkgs.zsh;

  # Home Manager (per-user modules are wired in flake.nix)
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.extraSpecialArgs = { inherit unstable inputs; };
}
