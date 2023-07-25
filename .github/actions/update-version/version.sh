#!/bin/bash

# Sets GitHub Action with error message to ease troubleshooting
function error() {
    echo "::error file=${FILENAME}::$1"
    exit 1
}

function debug() {
    TIMESTAMP=$(date -u "+%FT%TZ") # 2023-05-10T07:53:59Z
    echo ""${TIMESTAMP}" - $1"
}

function notice() {
    echo "::notice file=${FILENAME}::$1"
}

function start_span() {
    echo "::group::$1"
}

function end_span() {
    echo "::endgroup::"
}

function files_list_parser() {
  for p in $(echo $1 | sed "s/,/ /g"); do
    echo $p
  done
}


function main() {
  files_list_parser "${files}"
}

main "$@"