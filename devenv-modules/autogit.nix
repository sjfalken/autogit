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

    git-hooks.default_stages = [ "prepare-commit-msg" ];

    git-hooks.hooks.autogit = {
      enable = true;
      stages = [ "prepare-commit-msg" ];
      entry = toString (pkgs.writeShellScript "autogit-hook" ''
        LOG=/tmp/autogit-hook.log
        echo "--- $(date) ---" >> "$LOG"
        echo "ARGS: $@" >> "$LOG"
        echo "ARG1: $1" >> "$LOG"
        echo "PRE_COMMIT_COMMIT_MSG_SOURCE: $PRE_COMMIT_COMMIT_MSG_SOURCE" >> "$LOG"

        COMMIT_MSG_FILE="$1"

        if [ -n "$PRE_COMMIT_COMMIT_MSG_SOURCE" ]; then
          echo "Skipping: source=$PRE_COMMIT_COMMIT_MSG_SOURCE" >> "$LOG"
          exit 0
        fi

        DIFF=$(git diff -U20 --cached --no-color)
        echo "DIFF length: ''${#DIFF}" >> "$LOG"
        MESSAGE=$(${autogit}/bin/autogit "$DIFF")
        echo "MESSAGE: $MESSAGE" >> "$LOG"

        if [ -n "$MESSAGE" ]; then
          printf '%s\n\n' "$MESSAGE" | cat - "$COMMIT_MSG_FILE" > /tmp/commit_msg_tmp
          mv /tmp/commit_msg_tmp "$COMMIT_MSG_FILE"
        fi
      '');
      pass_filenames = true;
    };
  };
}
