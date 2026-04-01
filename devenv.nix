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

    # lua tools
    stylua
    lua-language-server

    # build tools
    openssl.dev
    pkg-config

    # shell tools
    jq

    # python tools
    uv
    python3
    pyright
    ruff
  ];
}
