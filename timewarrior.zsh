# plugin for timewarrior
#
# this currently only includes aliases, but an attempt at completion shopuld follow
#

alias tw=timew

alias tws='timew summary :ids'
alias twsy='timew summary :ids :yesterday'
alias twsw='timew summary :ids :week'
alias twsm='timew summary :ids :month'
alias twds='timew day summary'
alias twws='timew week summary'
alias twms='timew month summary'

alias twa='timew start'
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
alias twx='timew export'
alias twxd='timew export :day'
alias twxy='timew export :yesterday'
alias twxm='timew export :month'

function twss() {
    timew table ${@:-:day}
}
alias twssy='twss :yesterday'
alias twssw='twss :week'
alias twssm='twss :month'

function twnn() {
    ITEMS=()
    for i in "$@"; do
        if [[ $i = @* ]]; then
            ITEMS+=("$i")
            shift
        fi
    done

    if [ ${#ITEMS[@]} -eq 0 ]; then
        ITEMS+=("@1")
    fi

    for i in "$ITEMS[@]"; do
        annotation=$(timew export "$i" | jq -r '.[0].annotation | select (.!=null)')
        if [[ -z "${annotation}" ]]; then
            timew annotate "$i" "${*}"
        else
            timew annotate "$i" "${annotation}; ${*}"
        fi
    done
}

# twct == timewarrior change tag
function twct() {
    ITEMS=()
    TAGS=()
    for a in "$@"; do
        case $a in
        @*)
            ITEMS+=("$a")
            ;;
        *)
            TAGS+=("$a")
            ;;
        esac
    done

    if [ $#TAGS -ne 2 ]; then
        echo 'Too few or too many tags'
        return
    fi
    if [ $#ITEMS -lt 1 ]; then
        echo 'To few ids'
        return
    fi

    for item in "$ITEMS"; do
        timew untag $item $TAGS[1]
        timew tag $item $TAGS[-1]
    done
    timew summary
}
