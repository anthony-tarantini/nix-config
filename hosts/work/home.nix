# Home Manager settings for the work machine only.
{ inputs, ... }:
{
  # Git email and GitLab SSH host live outside the repo (see `work-local` in flake.nix)
  imports = [ "${inputs.work-local}/home.nix" ];

  home.stateVersion = "26.05";

  # Zed needs this under WSL (no real GPU)
  home.sessionVariables.ZED_ALLOW_EMULATED_GPU = "1";

  # Which nixosConfiguration the nix-* shell helpers act on
  home.sessionVariables.NIX_FLAKE_HOST = "work";

  programs.zsh = {
    # Wave Terminal: WSL connections ignore the block's cmd:cwd, so splits and
    # widgets would always start in ~. Read it ourselves and cd there.
    initContent = ''
      if [[ -n "$WAVETERM_BLOCKID" ]] && (( $+commands[wsh] )); then
        _wave_cwd="$(wsh getmeta --raw cmd:cwd 2>/dev/null)"
        [[ -n "$_wave_cwd" && -d "$_wave_cwd" && "$_wave_cwd" != "$PWD" ]] && cd -- "$_wave_cwd"
        unset _wave_cwd
      fi
    '';
  };

}
