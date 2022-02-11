#!/usr/bin/env bash

CONFIG_HOME="${HOME}/.kube"
CONFIG="${CONFIG_HOME}/config"

function usage(){
    printf "Usage

    [overview]
    Switch between Kubernetes configurations using a symbolic link ~/.kube/config

    [command]
    kubeswitch [options]

    [options]
    -s|--switch [name]    Switch to the given configuration name. 
    -u|--url              Display the URL of the Kube API for the current configuration.
    -l|--list             List the configuration names. Current configuration is pointed with '*'.
"
}

function check_config(){
  if [ -f "${CONFIG}" ]; then
    return 0
  else
    return 1
  fi
}

function list(){
  config_paths=$(find "${CONFIG_HOME}" -maxdepth 1 -type f)
  current_config=$(ls -l ~/.kube/config 2> /dev/null | sed -n 's+.*-> \(\/\)+\1+p')
  if ! check_config; then
    echo "! No current config selected yet : "
  fi
  for path in ${config_paths[*]}; do
    if [ "${current_config}" == "${path}" ]; then
      printf "* "
    fi
    echo "$(basename ${path})"
  done
}

# arg 1 must be the config name to select for kubeconfig
function switch(){
  config_name="$1"
  config="${CONFIG_HOME}/${config_name}"
  echo "Switch to ${config}"
  rm "${CONFIG}" > /dev/null 2>&1
  ln -s "${config}" "${CONFIG}"
}

function url(){
  kubectl config view | grep server | sed -n 's+.*\(http.*\)+\1+p'
}

# SETUP
if [ ! -d "${CONFIG_HOME}" ]; then
  echo "Create ${CONFIG_HOME}"
  mkdir -p "${CONFIG_HOME}"
fi

if [[ -f "${CONFIG}" && ! -L "${CONFIG}" ]]; then
  echo "ERROR: ${CONFIG} file exists. Move it to another name and re-run this"
  exit 1
fi


# PARSING
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -h | --help)
        usage
        exit 0
        ;;
    -l | --list)
        list
        shift
        exit 0
        ;;
    -s | --swith)
        switch "$2"
        shift 2
        exit 0
        ;;
    -u | --url )
        url
        shift
        exit 0
        ;;
    *) # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        echo "! Unknown parameter"
        usage
        shift              # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

exit 0
