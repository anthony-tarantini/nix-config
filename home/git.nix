{ inputs, ... }:
{
  # GitHub commit identity (personal email) lives in the private repo
  imports = [ "${inputs.private}/git.nix" ];

  programs.git = {
    enable = true;
    settings.user.name = "Tony Tarantini";
    settings.init.defaultBranch = "main";
    # Default user.email is set per host in hosts/*/home.nix;
    # GitHub repos override it (see nix-private/git.nix)
  };

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };

      "github.com" = {
        # SSH over 443: port 22 is blocked on some networks (e.g. work)
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityFile = "~/.ssh/github";
        # Offer only this key, not every key the agent holds
        identitiesOnly = "yes";
      };

      # Host-specific SSH entries go in hosts/*/home.nix
    };
  };
}
