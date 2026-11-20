{ config, lib, ... }:
let
  gitUser = config.programs.git.settings.user;
in
{
  programs.jujutsu = {
    enable = true;
    settings = {
      # Same identity as git: name from git.nix, default email from the host
      user = {
        name = gitUser.name;
      } // lib.optionalAttrs (gitUser ? email) { inherit (gitUser) email; };

      ui = {
        default-command = "log";
        # Render diffs in git format and page them through delta
        pager = "delta";
        diff-formatter = ":git";
      };
    };
  };
}
