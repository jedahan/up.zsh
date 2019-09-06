# up - upgrade everything

function up {
  up::config() { config pull }
  up::tldr() { tldr --update }
  up::zr() { zr update }
  up::apt() { sudo apt update -qq && sudo apt full-upgrade -y --autoremove | sed -n '/graded:$/,/graded,/{/graded:$/b;/graded,/b;p}' }
  up::nvim() { nvim +PlugUpdate! +PlugClean! +qall | rg 'Updated!\s+(.+/.+)' -r '$1' -N | paste -s - | head -c -1 }
  up::rustup() { rustup update | rg 'updated.*rustc' -N | cut -d' ' -f7 | paste -s - | head -c -1 }
  up::cargo() { cargo install-update --all | rg '(.*)Yes$' -r '$1' | paste -s - | head -c -1 }
  up::flatpak() { flatpak update --user -y; flatpak update --system -y }
  up::snap() { sudo snap refresh }
  up::fwupdmgr() { fwupdmgr refresh && fwupdmgr get-updates }

  local -A u
  sudo -v
  function fun { cmd=${1##*::}; (( $+aliases[$cmd] || $+functions[$cmd] || $+commands[$cmd] )) && { echo \# $1; $@; u[$cmd]=$? } }
  for update ($(functions | rg '(up::\w+).*' -r '$1')) fun $update
  print ${(kv)u}
}
