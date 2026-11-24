#!/bin/bash

dir="${1:-skills}"

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "Not inside a git repository." >&2
  exit 2
}

if [ "${dir#/}" = "$dir" ]; then
  cd "$root" || exit 2
fi

if [ ! -d "$dir" ]; then
  echo "No skills folder. Nothing to check."
  exit 0
fi

names=$(find "$dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | paste -sd'|' -)

edge="(^|[[:space:]\`\"'(])"
paths="${edge}(agents/|scripts/|hooks/|qa/|docs/(spec|plan|grill)/[A-Za-z0-9_.-]+\\.(md|html)|skills/($names)/)"
decisions='decisions\.md|(^|[^A-Za-z0-9_])D[0-9]+([^A-Za-z0-9_]|$)'
skill_names="\`($names)\`"

work=$(mktemp -d "${TMPDIR:-/tmp}/check-skills.XXXXXX") || {
  echo "Cannot create a temporary directory." >&2
  exit 2
}
cleanup() {
  rm -rf "$work"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

scan() {
  grep -rInE "$2" "$dir" > "$work/out"
  status=$?
  if [ "$status" -gt 1 ]; then
    echo "Skill scan failed." >&2
    exit 2
  fi
  sed "s/\$/  [$1]/" "$work/out" >> "$work/hits"
}

: > "$work/hits"
scan "repo-only path" "$paths"
scan "old decisions log" "$decisions"
if [ -n "$names" ]; then
  scan "skill name without studio-201:" "$skill_names"
fi

find "$dir" -mindepth 2 -maxdepth 2 -name SKILL.md | sort | while IFS= read -r file; do
  awk -v file="$file" '
    function flush() {
      if (step != "" && step !~ /`/ && tolower(lead) ~ verbs) {
        print file ":" start ":" step "  [step names no command]"
      }
      step = ""
    }
    BEGIN {
      verbs = "(^|[.!?] +|then +|and +|, +|^(if|when|after)[^,]*, +)(run|count|check|post|open|create|merge|delete)"
    }
    /^[0-9]+\. / {
      flush()
      start = NR
      step = $0
      lead = $0
      sub(/^[0-9]+\. +/, "", lead)
      infence = 0
      next
    }
    /^ *```/ {
      if (step != "") {
        infence = !infence
        step = step " `"
      }
      next
    }
    infence { next }
    /^[ \t]+[^ \t]/ {
      if (step != "") {
        line = $0
        sub(/^[ \t]+/, "", line)
        step = step " " line
        lead = lead " " line
      }
      next
    }
    /^$/ { next }
    { flush() }
    END { flush() }
  ' "$file"
done >> "$work/hits"

if [ -s "$work/hits" ]; then
  sort -t: -k1,1 -k2,2n "$work/hits"
  count=$(wc -l < "$work/hits" | tr -d ' ')
  echo "$count skill problem(s) found."
  exit 1
fi

echo "No skill problems found."
exit 0
