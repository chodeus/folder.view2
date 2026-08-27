#!/usr/bin/env bash
# Enumerate EVERY CodeRabbit finding on a PR. Counting inline comments misses the
# collapsed review-body sections (outside-diff-range, nitpicks, duplicates).
# Usage: bash .githooks/cr-sweep.sh <pr-number> [repo]
set -uo pipefail
PR="${1:?usage: cr-sweep.sh <pr-number> [repo]}"
REPO="${2:-chodeus/folder.view3}"

echo "=== [1/4] Inline review comments (incl. outdated: position=null) ==="
gh api "repos/$REPO/pulls/$PR/comments" --paginate \
  --jq '.[] | (.body // "") as $b | ([$b | splits("\n") | select(test("^\\*\\*"))] | first) as $claim | [(.id|tostring), (if .position == null then "OUTDATED" else "line \(.line // 0)" end), .user.login, (.path | split("/") | last), ($claim // ($b[0:70] | gsub("\n"; " ")))] | @tsv'

echo
echo "=== [2/4] Review-body sections (the ones that hide in <details>) ==="
gh pr view "$PR" --repo "$REPO" --json reviews \
  --jq '.reviews[] | select(.body != "") | "--- review \(.submittedAt) ---\n\(.body)"' \
  | grep -E "Actionable comments posted|Outside diff range comments|Nitpick comments|Duplicate comments|Additional comments posted|^> ?\`[0-9]+(-[0-9]+)?\`:|^\`[0-9]+(-[0-9]+)?\`:|^> \*\*|^\*\*[A-Z]" \
  || echo "  (no section headers found)"

echo
echo "=== [3/4] Merge-risk banner (current) ==="
gh pr view "$PR" --repo "$REPO" --json comments \
  --jq '.comments[] | select(.author.login == "coderabbitai") | .body' \
  | sed -n '/final_review_risk_start/,/final_review_risk_end/p' | grep -v "^<!--" || echo "  (none)"

echo
echo "=== [4/4] Pre-merge checks ==="
gh pr view "$PR" --repo "$REPO" --json comments \
  --jq '.comments[] | select(.author.login == "coderabbitai") | .body' \
  | grep -oE "Pre-merge checks \| ✅ [0-9]+( \| ❌ [0-9]+)?" | tail -1 || echo "  (none)"

echo
echo "Reminder: an unresolved thread needs a reply; a section header with no reply is an UNSWEPT finding."
