{ pkgs, unstable, inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
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
    glab
    curl
    wget
    claude-code
    unstable.opencode
  ];

  # Catppuccin Macchiato for every supported program that is enabled
  # (starship, zsh-syntax-highlighting, fzf, delta, bat, ...).
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "mauve";

    # Ports are rendered with catppuccin's own whiskers build, which downloads
    # crates and fails behind the corporate TLS proxy (sandboxed builds don't
    # trust our CA). Use the same version prebuilt from nixpkgs instead.
    sources =
      (import "${inputs.catppuccin}/default.nix" { inherit pkgs; }).packages.overrideScope
        (_: _: { whiskers = pkgs.catppuccin-whiskers; });
  };

  # Managed through programs.bat (not home.packages) so catppuccin can theme it
  programs.bat.enable = true;

  programs.t3code = {
    enable = true;
    package = unstable.t3code;

    mutableUserSettings = true;
    mutableKeybindings = true;
    mutableClientSettings = true;
  };
}
