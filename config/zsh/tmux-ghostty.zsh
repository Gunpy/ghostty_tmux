# tmux only in Ghostty
if [[ $- == *i* ]]; then
  # check that the terminal is Ghostty
  if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    if [ -z "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
      tmux attach -t main || tmux new -s main
    fi
  fi
fi
