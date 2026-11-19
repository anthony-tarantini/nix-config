{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "bash"
      "csharp"
      "dockerfile"
      "docker-compose"
      "eslint"
      "git-firefly"
      "nix"
      "toml"
      "typst"
    ];

    extraPackages = with pkgs; [
      # Nix
      nixd

      # .NET: Roslyn LSP is pinned via userSettings.lsp.roslyn below

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

      # Use Nix-packaged servers rather than the project PATH or downloads.
      lsp.nixd.binary.path = "${pkgs.nixd}/bin/nixd";
      lsp.eslint.binary = {
        path = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
        arguments = [ "--stdio" ];
      };

      # The C# extension downloads Roslyn from NuGet, which some networks
      # block (e.g. work). Use the nixpkgs build instead; arguments match
      # what the extension passes.
      lsp.roslyn.binary = {
        path = "${pkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer";
        arguments = [ "--stdio" "--autoLoadProjects" ];
      };
    };
  };
}
