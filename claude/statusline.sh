#!/bin/bash
# Claude Code status line
# Shows: model │ repo │ cost │ context

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "claude"')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# Extract repo name from project path
repo=""
if [ -n "$project_dir" ]; then
    repo=$(basename "$project_dir")
fi

# Format cost (show cents if under $1, otherwise dollars)
if (( $(echo "$cost < 1" | bc -l) )); then
    cost_fmt=$(printf "%.0f¢" "$(echo "$cost * 100" | bc -l)")
else
    cost_fmt=$(printf "\$%.2f" "$cost")
fi

# Format context as compact percentage
ctx_fmt=$(printf "%.0f%%" "$ctx_pct")

# Build status line with dim separators
# Use $'...' quoting for escape sequences (portable in bash, interpreted at parse time)
dim=$'\e[90m'
reset=$'\e[0m'
sep="${dim} │ ${reset}"
printf '%s\n' "${dim}◈${reset} ${model}${sep}${repo}${sep}${cost_fmt}${sep}${ctx_fmt}"
