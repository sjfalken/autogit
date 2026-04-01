{
  pkgs,
  ...
}:

{
  imports = [ ./devenv-modules/autogit.nix ];

  autogit = {
    enable = true;
    apiKeyFile = "$ANTHROPIC_API_KEY_FILE";
  };

  packages = with pkgs; [
    # nix tools
    nixd
    nixfmt
  ];
}
