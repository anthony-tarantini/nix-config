{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "history" ];
      theme = "agnoster";
    };

    shellAliases = {
      la = "ls -la";
      config = "zeditor ~/.config/nix";
      t3d = "setsid -f t3code-desktop >/dev/null 2>&1";
      rebuild = "nix-rebuild";
    };

    # NixOS helpers. They act on the current host, which each host sets
    # with NIX_FLAKE_HOST in hosts/*/home.nix (falls back to the hostname).
    # Override for one command: NIX_FLAKE_HOST=home nix-dryrun
    # None of them change directory. After a switch or revert, an
    # interactive shell restarts itself so new aliases and variables load.
    initContent = ''
      _nix_flake_dir() { print -r -- "''${NIX_FLAKE_DIR:-$HOME/.config/nix}"; }
      _nix_flake_host() { print -r -- "''${NIX_FLAKE_HOST:-$(hostname)}"; }

      _nix_reload_shell() {
        [[ -o interactive ]] || return 0
        print -P "%F{green}Reloading shell...%f"
        # Clear the "already sourced" guards so session variables are re-read
        unset __HM_SESS_VARS_SOURCED __NIXOS_SET_ENVIRONMENT_DONE
        exec zsh
      }

      # nix-rebuild [nixos-rebuild args]: build and switch to the current config
      nix-rebuild() {
        sudo nixos-rebuild switch --flake "$(_nix_flake_dir)#$(_nix_flake_host)" "$@" \
          && _nix_reload_shell
      }

      # nix-dryrun [nix build args]: build without switching, show what would change
      nix-dryrun() {
        local out
        out=$(nix build --no-link --print-out-paths \
          "$(_nix_flake_dir)#nixosConfigurations.$(_nix_flake_host).config.system.build.toplevel" \
          "$@") || return
        if [[ "$out" == "$(readlink -f /run/current-system)" ]]; then
          print "No changes."
          return
        fi
        local diff
        diff=$(nix store diff-closures /run/current-system "$out")
        if [[ -n "$diff" ]]; then
          print -r -- "$diff"
        else
          print "Config changed; no package versions changed."
        fi
      }

      # nix-update [input...]: update flake inputs (all by default), then rebuild
      nix-update() {
        nix flake update --flake "$(_nix_flake_dir)" "$@" && nix-rebuild
      }

      # nix-revert: switch back to the previous system generation
      nix-revert() {
        sudo nixos-rebuild switch --rollback && _nix_reload_shell
      }
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.starship.enable = true;
  programs.fzf.enable = true;
}
