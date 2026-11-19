# Work machine: NixOS-WSL on Windows.
{ lib, inputs, user, ... }:
{
  # WSL
  wsl.enable = true;
  wsl.defaultUser = user;
  wsl.useWindowsDriver = true;
  wsl.docker-desktop.enable = true;

  # Corporate CA certificates, kept outside the repo (see `work-local` in flake.nix)
  security.pki.certificateFiles =
    let
      dir = "${inputs.work-local}/certs";
      files = builtins.attrNames (builtins.readDir dir);
    in
    map (f: "${dir}/${f}") (builtins.filter (lib.hasSuffix ".pem") files);

  environment.variables = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
    REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data were taken. Leave it at the release of
  # this machine's first install.
  system.stateVersion = "26.05";
}
