{ pkgs, unstable, ... }:
{
  imports = [
    ./email.nix
    ./git.nix
    ./jujutsu.nix
    ./pass.nix
    ./shell.nix
    ./zed.nix
  ];

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    bat
    glab
    curl
    wget
    claude-code
    opencode
  ];

  programs.t3code = {
    enable = true;
    package = unstable.t3code;

    mutableUserSettings = true;
    mutableKeybindings = true;
    mutableClientSettings = true;
  };
}
