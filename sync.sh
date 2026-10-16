#!/usr/bin/env bash
# Put a symbol before the label of tabs 1 to 5 in every workspace, and remove
# it from all other tabs. The script renames a tab only when its label is not
# correct, so the tab.renamed events from its own renames do not cause a loop.
set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
symbols=("★" "♠" "♣" "♦" "❤")

for workspace in $("$herdr" workspace list | jq -r '.result.workspaces[].workspace_id'); do
  "$herdr" tab list --workspace "$workspace" |
    jq -r '.result.tabs | to_entries[] | "\(.value.tab_id)\t\(.key + 1)\t\(.value.label)"' |
    while IFS=$'\t' read -r tab_id position label; do
      name="$label"
      for symbol in "${symbols[@]}"; do
        if [[ "$name" == "$symbol "* ]]; then
          name="${name#"$symbol "}"
          break
        fi
      done

      # Herdr shows the tab position when a tab has no name. After a rename that
      # position is fixed text, so replace it with the position the tab has now.
      # The tab_id and "number" fields do not change when tabs move or close.
      if [[ "$name" =~ ^[0-9]+$ ]]; then
        name="$position"
      fi

      want="$name"
      if ((position <= ${#symbols[@]})); then
        want="${symbols[position - 1]} $name"
      fi

      if [[ "$want" != "$label" ]]; then
        "$herdr" tab rename "$tab_id" "$want" >/dev/null
      fi
    done
done
