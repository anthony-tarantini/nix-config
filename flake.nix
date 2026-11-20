{
  description = "NixOS + Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private GitHub repo shared by EVERY host (personal email, GitHub identity),
    # kept out of this repo. Edit in a clone (~/.config/nix-private), commit and
    # push, then `nix-update private`. Fetched over SSH as your user, so build
    # with the nix-* helpers (nixos-rebuild --sudo), not plain `sudo`.
    private = {
      url = "git+ssh://git@github.com/anthony-tarantini/sensitive-nix-config.git";
      flake = false;
    };

    # Work-machine files kept out of Git (corporate CA certs).
    # Only hosts/work reads this input. Nix fetches inputs lazily, so other
    # hosts never need this folder unless they run a full `nix flake update`.
    # After changing files there: `nix flake update work-local`.
    work-local = {
      url = "path:/home/nixos/.config/nix-work";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, home-manager, nixos-wsl, ... }@inputs:
    let
      mkHost =
        {
          name,
          user,
          system ? "x86_64-linux",
          modules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs user;
            unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            { nixpkgs.hostPlatform = system; }
            home-manager.nixosModules.home-manager
            ./hosts/common.nix
            ./hosts/${name}/configuration.nix
            {
              home-manager.users.${user}.imports = [
                ./home
                ./hosts/${name}/home.nix
              ];
            }
          ] ++ modules;
        };
    in
    {
      nixosConfigurations = {
        work = mkHost {
          name = "work";
          user = "nixos";
          modules = [ nixos-wsl.nixosModules.default ];
        };
      };
    };
}
