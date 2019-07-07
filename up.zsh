# up - upgrade everything

(( $+functions[up] )) && return

function up {
  uplog=/tmp/up; echo > $uplog

  (( $+commands[tmux] )) && {
    window_name=`tmux list-windows -F '#{?window_active,#{window_name},}'`
    tmux select-window -t  2>/dev/null || tmux rename-window 
    tmux split-window -h -d -t  "tail -f $uplog"
  }

  function e { if [ $? -eq 0 ]; then command cat <<< $1; else echo ":("; fi }
  function fun { (( $+aliases[$1] || $+functions[$1] || $+commands[$1] )) && echo -n "updating $2..." }

  sudo -v; command cat <<< "  $uplog"
  fun config 'dotfiles' && { config pull }                          &>> $uplog; e 
  fun zr 'zsh plugins'  && { zr update }                            &>> $uplog; e ▲ && rg 'Updating [a-f0-9]{6}\.\.[a-f0-9]{6}' -B1 $uplog
  fun tldr 'tldr'       && { tldr --update }                        &>> $uplog; e ⚡
  fun apt 'apt'         && { sudo apt update; sudo apt -y upgrade; sudo apt autoremove } &>> $uplog; e  && sed -n '/graded:$/,/graded,/{/graded:$/b;/graded,/b;p}' $uplog
  fun nvim 'neovim'     && { nvim +PlugUpdate! +PlugClean! +qall  } &>> $uplog; e  && rg 'Updated!\s+(.+/.+)' -r '$1' -N $uplog | paste -s - | head -c -1
  fun rustup 'rust'     && { rustup update }                        &>> $uplog; e  && rg 'updated.*rustc' -N $uplog | cut -d' ' -f7 | paste -s - | head -c -1
  fun cargo 'crates'    && { cargo install-update --all }           &>> $uplog; e  && rg '(.*)Yes$' --replace '$1' $uplog | paste -s - | head -c -1

  (( $+commands[tmux] )) && {
    tmux kill-pane -t :.{right}
    tmux rename-window ${window_name//[[:space:]]/}
  }
}
