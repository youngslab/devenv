#!/usr/bin/env zsh

# ------------------------------------------------------------------------------
# Pure-inspired minimal theme for oh-my-zsh
# Based on Sindre Sorhus's Pure prompt
# ------------------------------------------------------------------------------

# Enable prompt substitution
setopt prompt_subst

# Parse git branch name
parse_git_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  echo " ($branch)"
}

# Check if git repo is dirty
git_dirty() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  command git diff --quiet --ignore-submodules HEAD &>/dev/null
  [ $? -eq 1 ] && echo "*"
}

# Display command execution time if > 5 seconds
cmd_exec_time() {
  local stop=$(date +%s)
  local start=${cmd_timestamp:-$stop}
  local elapsed=$((stop - start))
  [ $elapsed -gt 5 ] && echo " ${elapsed}s"
}

# Store timestamp before command execution
preexec() {
  cmd_timestamp=$(date +%s)
}

# Output path, git info, hostname before each prompt
precmd() {
  print -P "\n%F{250}%~%F{cyan}$(parse_git_branch)%F{red}$(git_dirty)%F{237} | $(hostname)%F{yellow}$(cmd_exec_time)%f"
}

# Prompt character (magenta on success, red on failure)
PROMPT="%(?.%F{magenta}.%F{red})>%f "

# Right prompt: show user@host if connected via SSH
RPROMPT="%F{8}${SSH_TTY:+%n@%m}%f"
