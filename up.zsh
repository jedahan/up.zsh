# up - upgrade everything

function up {
  local -A u
  function fun { cmd=${1##*::}; (( $+aliases[$cmd] || $+functions[$cmd] || $+commands[$cmd] )) && { $@; u[$cmd]=$? } }

  sudo -v

  up::config() { config pull }
  up::tldr() { tldr --update }
  up::zr() { zr update | rg 'Updating [a-f0-9]{6}\.\.[a-f0-9]{6}' -B1 }
  up::apt() { sudo apt update && sudo apt full-upgrade -y --autoremove && sed -n '/graded:$/,/graded,/{/graded:$/b;/graded,/b;p}' }
  up::nvim() { nvim +PlugUpdate! +PlugClean! +qall | rg 'Updated!\s+(.+/.+)' -r '$1' -N | paste -s - | head -c -1 }
  up::rustup() { rustup update | rg 'updated.*rustc' -N | cut -d' ' -f7 | paste -s - | head -c -1 }
  up::cargo() { cargo install-update --all | rg '(.*)Yes$' -r '$1' | paste -s - | head -c -1 }

  for update in up::{config,tldr,zr,apt,nvim,rustup,cargo}; do fun $update; done

  print ${(kv)u}
}
