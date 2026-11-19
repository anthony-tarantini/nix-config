# Password store: `pass` (GPG-encrypted files, synced via its own private Git repo).
# Used by aerc's passwordCommand (`pass show email/<account>`). Nix never
# reads the passwords; it only installs the tools.
{ pkgs, ... }:
{
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    # GUI prompt (works under WSLg), falls back to the terminal without a display.
    # A GUI prompt matters for aerc, which runs `pass` behind its own TUI.
    pinentry.package = pkgs.pinentry-qt;
    # Remember the passphrase for 8h so mail checks don't keep prompting
    defaultCacheTtl = 28800;
    maxCacheTtl = 28800;
  };

  programs.password-store.enable = true;
}
