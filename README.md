# NixOS config

NixOS + Home Manager configuration for my machines, as a flake.

| Host   | What it is                     | Status  |
|--------|--------------------------------|---------|
| `work` | NixOS-WSL on Windows           | active  |
| `home` | Native NixOS desktop           | planned |

## Layout

```
~/.config/nix/
├── flake.nix              # inputs + mkHost helper, one nixosConfiguration per host
├── flake.lock
├── home/                  # Home Manager modules shared by every host
│   ├── default.nix        #   CLI packages, t3code
│   ├── email.nix          #   aerc; imports the personal account from nix-private
│   ├── shell.nix          #   zsh, oh-my-zsh, starship, fzf, direnv, nix-* helpers
│   ├── git.nix            #   git (name only), ssh, ssh-agent
│   └── zed.nix            #   Zed + language servers
└── hosts/
    ├── common.nix         # system settings shared by every host (nix, gc, zsh, HM wiring)
    └── work/
        ├── configuration.nix  # WSL, Docker Desktop, corporate CA certs
        └── home.nix           # work-only HM: NIX_FLAKE_HOST, Wave fix, Zed GPU var
```

`mkHost` in `flake.nix` builds each host from `hosts/common.nix`, `hosts/<name>/configuration.nix`, and Home Manager with `home/` plus `hosts/<name>/home.nix`. Values set in several places are combined by the NixOS module system. For example, `home/git.nix` sets the git name and the host sets the email.

`unstable` (nixpkgs-unstable) and `inputs` are available as module arguments in both NixOS and Home Manager modules.

## Shared private repo: `~/.config/nix-private`

Personal values that **every** host needs, but that shouldn't be in this repo, live in a separate **private GitHub repo**. The flake fetches it over SSH through the `private` input (`flake = false`). The local clone at `~/.config/nix-private` is only for editing:

```
~/.config/nix-private/     # clone of the private repo, NOT part of this one
├── email.nix              # HM module: personal email account (accounts.email.accounts.personal)
└── git.nix                # HM module: commit email for any repo with a GitHub remote
```

- `home/email.nix` and `home/git.nix` import these files.
- GitHub identity: repos whose remote is GitHub (SSH or HTTPS) commit with the personal email via git `includeIf "hasconfig:remote.*.url:…"`. Other repos use the host's default email. The SSH side (`~/.ssh/github` key, over port 443) is in the shared `home/git.nix`.
- `flake.lock` pins a **commit** of that repo, not its contents.
- Nix reads what's **pushed**, not your local edits. After editing:

  ```sh
  cd ~/.config/nix-private && git commit -am "..." && git push   # 1. commit + push there
  nix-update private                                              # 2. bump the lock + rebuild
  ```

  Then commit the `flake.lock` change in this repo.
- Other machines don't need a clone to build. Nix fetches the pinned commit itself, using your GitHub SSH key. That's why the `nix-*` helpers build as you (`nixos-rebuild --sudo`). A plain `sudo nixos-rebuild` would fetch as root, without your key.
- It's **private, not secret**: fine for addresses and server names. Passwords stay in `pass` (`passwordCommand`).

## Machine-local files: `~/.config/nix-work`

Some work values are employer-specific and stay **out of this repo**. They live in a separate folder that the flake reads through a local `path:` input called `work-local`:

```
~/.config/nix-work/        # NOT in Git
├── certs/*.pem            # corporate CA certs → security.pki.certificateFiles
└── home.nix               # HM module: git email, work GitLab SSH host
```

- `hosts/work/configuration.nix` loads every `certs/*.pem`.
- `hosts/work/home.nix` imports `home.nix`.
- `flake.lock` stores only that folder's path and a content hash. The values themselves never reach Git.
- Only the `work` host uses this input. Nix fetches inputs lazily, so other hosts build fine without the folder. The exception: updating every input (`nix-update` with no arguments) on a machine without it fails. Name the inputs there instead, e.g. `nix-update nixpkgs nixpkgs-unstable home-manager`.

**After editing anything in `~/.config/nix-work`**, refresh the lock before rebuilding, or the old copy is used:

```sh
nix-update work-local
```

**Back this folder up yourself.** Git does not cover it. To rebuild it from scratch, create `certs/` with the CA `.pem` files and a `home.nix` like:

```nix
{ ... }:
{
  programs.git.settings.user.email = "you@work.example";

  programs.ssh.settings."gitlab.work.example" = {
    user = "git";
    identityFile = "~/.ssh/gitlab";
  };
}
```

## Everyday commands

These are shell functions from `home/shell.nix`. They always act on the **current host** and work from any directory.

```sh
rebuild                    # alias for nix-rebuild
nix-rebuild [args...]      # build and switch to this host's config
nix-dryrun  [args...]      # build without switching; show what would change
nix-update  [input...]     # update flake inputs (all by default), then rebuild
nix-revert                 # switch back to the previous generation
```

- After a successful `nix-rebuild`, `nix-update`, or `nix-revert`, the shell restarts itself in the same directory. That way new aliases, functions, and session variables take effect right away. Shell variables you set by hand are lost, but history is kept.
- Extra arguments are passed through, e.g. `nix-rebuild --show-trace`.
- **The current host** is `$NIX_FLAKE_HOST`, set per host in `hosts/<name>/home.nix`, falling back to the hostname. To target another host once, run e.g. `NIX_FLAKE_HOST=home nix-dryrun`.
- The flake lives at `$NIX_FLAKE_DIR`, defaulting to `~/.config/nix`.

Notes:

- **Flakes only see files Git tracks.** `git add` new files before building, or you get "file not found." Committing isn't required.
- The hostname is still `nixos`, so `NIX_FLAKE_HOST` is what selects the `work` config. If `networking.hostName` matched the config name, the variable wouldn't be needed.
- `/etc/nixos` is a symlink to this folder.
