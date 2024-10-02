#!/bin/bash

# import: source "${BASH_SOURCE%/*}/_utils.bash"

function get_git_root_path () {
  # usage: root_path=$(get_git_root_path)
  git rev-parse --show-toplevel
}

function select_from_array () {
  # usage: target=$(select_from_array "false" "option1 option2 option3")
  local enable_select_all=$1
  local array=$2

  if [ $enable_select_all == "true" ]
  then
    select option in $array "SELECT_ALL"
    do
      case $option in
        SELECT_ALL)
          local selected=$array
          break;;
        *)
          local selected=$option
          break;;
      esac
    done
  fi

  if [ $enable_select_all == "false" ]
  then
    select option in $array
    do
      case $option in
        *)
          local selected=$option
          break;;
      esac
    done
  fi

  echo $selected
}

function get_json_keys () {
  # usage: keys_array=$( get_json_keys "$JSON_OBJECT")
  local json_string=$1
  echo $json_string | jq 'keys[]' -cr
}

function cp_file () {
  # usage: cp_file=$( "$src" "$dest")
  local src_file_path=$1
  local dst_file_path=$2

  echo -e "\nCopying $src_file_path -> $dst_file_path\n"
  
  mkdir -p $(dirname $dst_file_path)
  cp $src_file_path $dst_file_path
}
