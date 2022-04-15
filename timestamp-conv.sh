#!/bin/bash

usage() {
    cat << EOF

    usage: $0 OPTIONS

    OPTIONS:
      -h        help
      -w WINSEC Windows timestamp (nano seconds since Jan 1 1601)
      -e EPOCH  Epoch timestamp (seconds since Jan 1 1970) 

    OUTPUT OPTIONS:
      -u        Show ISO time in UTC
      -l        Show ISO time in Local TZ
      -o        Show original input time
EOF
}

ISO_UTC=false
ISO_LOCAL=false
ORIG=false

while getopts "hw:e:ulo" OPTION
do
    case $OPTION in
        h)
            usage; exit 0;;
        w)
            WINSTAMP=$OPTARG;;
        e)
            EPOCH=$OPTARG;;
        u)
            ISO_UTC=true;;
        l)
            ISO_LOCAL=true;;
        o)
            ORIG=true;;
    esac
done

win_to_epoch() {
    local ARG1=$1
    local WINSECS=$(($ARG1 / 10000000))
    local EPOCH=$((WINSECS - 11644473600))

    echo $EPOCH
}

epoch_to_win() {
    local ARG1=$1
    local WINSECS=$(($ARG1 + 11644473600))
    local WINSTAMP=$(($WINSECS * 10000000))

    echo $WINSTAMP
}

display_date() {
    CONV_TIMESTAMP=$1
    TIMESTAMP=$2

    if $ORIG; then
        echo "${TIMESTAMP}"
    fi

    echo "${CONV_TIMESTAMP}"

    if $ISO_UTC; then
        DATE=$(date -u -r "${TIMESTAMP}" +"%Y-%m-%dT%H:%M:%S%z" 2> /dev/null) || DATE=$(date -u -d "@${TIMESTAMP}" --iso-8601=seconds)
        echo "${DATE}"
    fi

    if $ISO_LOCAL; then
        DATE=$(date -r "${TIMESTAMP}" +"%Y-%m-%dT%H:%M:%S+%z" 2> /dev/null) || DATE=$(date -d "@${TIMESTAMP}" --iso-8601=seconds)
        echo "${DATE}"
    fi
}

if [[ ! -z $WINSTAMP ]]; then
    CONV=$(win_to_epoch WINSTAMP)
    display_date ${CONV} ${CONV}
fi

if [[ ! -z $EPOCH ]]; then
    CONV=$(epoch_to_win EPOCH)
    display_date ${CONV} ${EPOCH}
fi
