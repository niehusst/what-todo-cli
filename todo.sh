#!/bin/bash
# A simple tool to help pick an activity or chore when i need something todo
# (loosely inspired by https://github.com/todotxt/todo.txt)

set -euo  pipefail

TODO_FILE_PATH=~/todo.txt

function add_activity () (
  local id="$RANDOM"
  local priority="B" # default mid priority
  local time_limit="1h"
  local description=""
  local categories=()

  while getopts "hp:d:c:t:" flag; do
    case "$flag" in
    h)
      echo "$0 add [-h] [-p A|B|C...] [-d 'description'] [-c 'category'] [-t '30min']"
      echo "  -d  description, any string [required]"
      echo "  -p  priority, capital letter (e.g. '-p A') [optional]"
      echo "  -c  category, 1 word no spaces. can be passed multiple times [optional]"
      echo "  -t  time limit, string [optional]"
      echo "  -h  print usage details"
      exit 0
      ;;
    d)
      description="$OPTARG"
      ;;
    p)
      priority="$OPTARG"
      ;;
    c)
      categories+=("$OPTARG")
      ;;
    t)
      time_limit="$OPTARG"
      ;;
    *)
      echo "WARN: Skipping unknown flag $flag" >&2
      ;;
    esac
  done

  if [ -z "$description" ];
  then
    echo "ERROR: -d flag is required" >&2
    exit 1
  fi

  local entry="$id ($priority) $description [$time_limit]"

  for category in "${categories[@]}";
  do
    entry="$entry @$category"
  done

  echo "$entry" | tee -a $TODO_FILE_PATH
)

function get_activity () (
  local categories=()

  while getopts "hc:" flag;
  do
    case "$flag" in
      h)
        echo "$0 get [-h] [-c 'projects']"
        echo "  -c  Name of category to get activity from. Can be passed multiple times. Selects from all activities by default. [optional]"
        echo "  -h  print usage details"
        exit 0
        ;;
      c)
        categories+=("$OPTARG")
        ;;
      *)
        echo "WARN: Skipping unknown flag $flag" >&2
        ;;
    esac
  done

  local cat_pat=""
  for category in "${categories[@]}";
  do
    if [ -z "$cat_pat" ];
    then
      cat_pat="@$category"
    else
      cat_pat="$cat_pat|@$category"
    fi
  done

  local selected_content=""
  if [ ! -z "$cat_pat" ];
  then
    selected_content="$(grep -E -e "$cat_pat" $TODO_FILE_PATH)"
  else
    selected_content="$(cat $TODO_FILE_PATH)"
  fi

  echo "$selected_content" | sort -R | head -n1
)

function list_activities () (
  local categories=()

  while getopts "hc:" flag;
  do
    case "$flag" in
      h)
        echo "$0 list [-h] [-c 'projects']"
        echo "  -c  Name of category list entries from. Can be passed multiple times. Selects from all activities by default. [optional]"
        echo "  -h  print usage details"
        exit 0
        ;;
      c)
        categories+=("$OPTARG")
        ;;
      *)
        echo "WARN: Skipping unknown flag $flag" >&2
        ;;
    esac
  done

  local cat_pat=""
  for category in "${categories[@]}";
  do
    if [ -z "$cat_pat" ];
    then
      cat_pat="@$category"
    else
      cat_pat="$cat_pat|@$category"
    fi
  done

  local selected_content=""
  if [ ! -z "$cat_pat" ];
  then
    grep -E -e "$cat_pat" $TODO_FILE_PATH
  else
    cat $TODO_FILE_PATH
  fi
)

function print_usage () (
  echo "Usage: $0 cmd [flags]"
  echo
  add_activity -h
  echo
  get_activity -h
  echo
  list_activities -h
)

function main () (
  if [ ! -f $TODO_FILE_PATH ];
  then
    touch $TODO_FILE_PATH
  fi

  if [ ! "$#" -gt 0 ];
  then
    print_usage
    exit 1
  fi

  local cmd="$1"
  shift 1
  case "$cmd" in
    "add")
      add_activity "$@"
      ;;
    "get")
      get_activity "$@"
      ;;
    "list")
      list_activities "$@"
      ;;
    *)
      print_usage
      ;;
  esac
)

main "$@"
