{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.autogit;
  autogit = pkgs.callPackage ../pkgs/autogit { };
in
{
  options.autogit = {
    enable = lib.mkEnableOption "autogit AI commit message generator";

    apiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Shell expression that resolves to the path of a file containing ANTHROPIC_API_KEY (e.g. \"\$ANTHROPIC_API_KEY_FILE\").";
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [ autogit ];

    enterShell = lib.optionalString (cfg.apiKeyFile != null) ''
      export ANTHROPIC_API_KEY="$(cat ${cfg.apiKeyFile})"
    '';

    git-hooks.hooks.prepare-commit-msg = {
      enable = true;
      entry = toString (pkgs.writeShellScript "autogit-hook" ''
        COMMIT_MSG_FILE="$1"
        COMMIT_SOURCE="$2"

        if [ -n "$COMMIT_SOURCE" ]; then
          exit 0
        fi

        DIFF=$(git diff -U20 --cached --no-color)
        MESSAGE=$(autogit "$DIFF")

        if [ -n "$MESSAGE" ]; then
          printf '%s\n\n' "$MESSAGE" | cat - "$COMMIT_MSG_FILE" > /tmp/commit_msg_tmp
          mv /tmp/commit_msg_tmp "$COMMIT_MSG_FILE"
        fi
      '');
      pass_filenames = false;
    };
  };
}
