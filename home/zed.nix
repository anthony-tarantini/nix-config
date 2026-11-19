{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "csharp"
      "dockerfile"
      "docker-compose"
      "git-firefly"
      "nix"
      "toml"
      "typst"
    ];

    extraPackages = with pkgs; [
      # Nix
      nixd

      # .NET
      omnisharp-roslyn

      # JS/TS/React
      nodejs
      vtsls
      vscode-langservers-extracted
      tailwindcss-language-server

      # Rust
      rust-analyzer

      # Go
      gopls
      delve

      # Python
      basedpyright
      ruff

      # Docker
      dockerfile-language-server
      docker-compose-language-service

      # Config formats
      taplo
      yaml-language-server

      # Typst
      tinymist
    ];

    userSettings = {
      languages = {
        Nix.language_servers = [ "nixd" "!nil" ];
        Python = {
          language_servers = [ "basedpyright" "ruff" "!pyright" "!pylsp" "..." ];
          formatter.language_server.name = "ruff";
        };
      };
    };
  };
}
