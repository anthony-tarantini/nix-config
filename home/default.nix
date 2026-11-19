{ pkgs, unstable, ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
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
