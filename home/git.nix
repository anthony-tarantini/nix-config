{ ... }:
{
  programs.git = {
    enable = true;
    settings.user.name = "Tony Tarantini";
    # user.email is set per host in hosts/*/home.nix
  };

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      # Host-specific SSH entries go in hosts/*/home.nix
    };
  };
}
