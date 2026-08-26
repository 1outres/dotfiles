{ inputs, pkgs, ... }:

let
  claude-code = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

  schema = builtins.toJSON {
    type = "object";
    required = [ "candidates" ];
    additionalProperties = false;
    properties.candidates = {
      type = "array";
      minItems = 4;
      maxItems = 4;
      items = {
        type = "object";
        required = [
          "label"
          "message"
        ];
        additionalProperties = false;
        properties = {
          label = {
            type = "string";
            enum = [
              "conventional-polite"
              "conventional-simple"
              "conventional-mimic"
              "scribble"
            ];
          };
          message = {
            type = "string";
            minLength = 1;
          };
        };
      };
    };
  };

  git-ai-commit = pkgs.writeShellApplication {
    name = "git-ai-commit";
    runtimeInputs = [
      claude-code
      pkgs.git
      pkgs.gum
      pkgs.jq
    ];
    text = ''
      if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "error: not inside a git work tree." >&2
        exit 1
      fi

      if git diff --cached --quiet; then
        echo "error: no staged changes. stage something with 'git add' first." >&2
        exit 1
      fi

      diff=$(git diff --cached)
      if recent_log=$(git log -20 --pretty=format:'- %s' 2>/dev/null) && [[ -n "$recent_log" ]]; then
        recent_section="Recent commits (newest first):
      $recent_log"
      else
        recent_section="Recent commits: (none yet)"
      fi

      prompt=$(cat <<EOF
      You generate commit messages for staged git changes. Return EXACTLY 4 candidates
      with the labels below.

      - conventional-polite: Conventional Commits (type(scope): subject). Well-formed,
        clear English. Subject <= 72 chars. Include a short body only if the change
        genuinely needs it; otherwise subject only.
      - conventional-simple: Conventional Commits, simple short English. Subject only,
        very concise.
      - conventional-mimic: Conventional Commits, but mimic the style, tone, and
        language of the recent commits listed below as closely as possible.
      - scribble: casual scribble commit, <= 5 words, lowercase, no period. Think
        "wip", "fix typo", "bump deps".

      $recent_section

      Staged diff:
      \`\`\`diff
      $diff
      \`\`\`
      EOF
      )

      echo "generating commit messages..." >&2
      if ! raw=$(claude -p --output-format text --json-schema ${pkgs.lib.escapeShellArg schema} "$prompt"); then
        echo "error: claude invocation failed." >&2
        exit 1
      fi

      if ! echo "$raw" | jq -e '.candidates | length == 4' >/dev/null 2>&1; then
        echo "error: unexpected response from claude:" >&2
        echo "$raw" >&2
        exit 1
      fi

      mapfile -t labels < <(echo "$raw" | jq -r '.candidates[].label')
      mapfile -t messages < <(echo "$raw" | jq -r '.candidates[].message')

      display=()
      for i in "''${!labels[@]}"; do
        first_line=''${messages[$i]%%$'\n'*}
        display+=("[''${labels[$i]}] $first_line")
      done

      selected_display=$(printf '%s\n' "''${display[@]}" \
        | gum choose --header "Select a commit message")
      if [[ -z "$selected_display" ]]; then
        echo "aborted." >&2
        exit 1
      fi

      msg=""
      for i in "''${!display[@]}"; do
        if [[ "''${display[$i]}" == "$selected_display" ]]; then
          msg=''${messages[$i]}
          break
        fi
      done

      if [[ -z "$msg" ]]; then
        echo "error: could not resolve selected message." >&2
        exit 1
      fi

      echo >&2
      gum style --border normal --padding "0 1" --margin "0" "$msg" >&2
      if gum confirm "Commit with this message?"; then
        git commit -m "$msg"
      else
        echo "aborted." >&2
        exit 1
      fi
    '';
  };
in
{
  home.packages = [ git-ai-commit ];
}
