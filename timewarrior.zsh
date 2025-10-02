alias tw=timew

alias tws='timew_report_table'
alias twsy='tws :yesterday'
alias twsw='tws :week'
alias twsm='tws :month'
alias twds='timew day summary'
alias twws='timew week summary'
alias twms='timew month summary'

alias twa='timew_start_with_annotation'
alias two='timew stop'
alias twc='timew continue'
alias twt='timew track'
alias twl='timew lengthen'
alias twsh='timew shorten'
alias twm='timew modify'
alias twma='timew modify start'
alias twmo='timew modify end'
alias twrs='timew resize'
alias twz='timew undo'
alias twd='timew delete'
alias twg='timew tag'
alias twug='timew untag'
alias twn='timew annotate'
alias twna='timew_annotate_apend'
alias twx='timew export'
alias twxd='timew export :day'
alias twxy='timew export :yesterday'
alias twxm='timew export :month'

function timew_report_table() {
  if (( $# )); then
    timew report table "$@"
  else
    timew report table :day
  fi
}

function timew_annotate_apend() {
  local -a items annotation_words
  local arg item current_annotation new_annotation

  for arg in "$@"; do
    if [[ $arg == @* ]]; then
      items+=("$arg")
    else
      annotation_words+=("$arg")
    fi
  done

  if (( ! ${#annotation_words} )); then
    print -r -- 'Provide annotation text to append' >&2
    return 1
  fi

  if (( ! ${#items} )); then
    items+=("@1")
  fi

  new_annotation="${(j: :)annotation_words}"

  for item in "${items[@]}"; do
    current_annotation=$(timew export "$item" | jq -r '.[0].annotation // empty')
    if [[ -z $current_annotation ]]; then
      timew annotate "$item" "$new_annotation" || return $?
    else
      timew annotate "$item" "$current_annotation; $new_annotation" || return $?
    fi
  done
}

# twct == timewarrior change tag
function twct() {
  local -a items tags
  local arg item

  for arg in "$@"; do
    case $arg in
    @*)
      items+=("$arg")
      ;;
    *)
      tags+=("$arg")
      ;;
    esac
  done

  if (( ${#tags} != 2 )); then
    print -r -- 'Expected exactly two tags (old new)' >&2
    return 1
  fi

  if (( ! ${#items} )); then
    print -r -- 'Provide at least one @id' >&2
    return 1
  fi

  for item in "${items[@]}"; do
    timew untag "$item" "${tags[1]}" || return $?
    timew tag "$item" "${tags[2]}" || return $?
  done

  timew summary
}

timew_start_with_annotation() {
  local -a tags annotations
  local a current_annotation new_annotation

  for a in "$@"; do
    if [[ "$a" == *" "* ]]; then
      annotations+=("$a")
    else
      tags+=("$a")
    fi
  done

  if (( ${#tags} )); then
    timew start "${(@)tags}" || return $?
  else
    timew start || return $?
  fi

  (( ${#annotations} )) || return 0
  new_annotation="${(j:; :)annotations}"
  current_annotation=$(timew export @1 | jq -r '.[0].annotation // empty')

  if [[ -z "$current_annotation" ]]; then
    timew annotate "$new_annotation"
  else
    timew annotate "$current_annotation; $new_annotation"
  fi
}
