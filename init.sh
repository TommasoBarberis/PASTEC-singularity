#!/bin/bash

## Author: Tommaso Barberis
## Date: 07/04/2022
## Description: singularity container initizialisation for PASTEC (transposable elements classification tool)
## Dependencies:
# - singularity (tested with v.3.9)
## Parameters:
# -d|--directory: path to the directory that will contain singularity and PASTEC files (also the output of the program)
# -s|--sif: path to the .sif file with the PASTEC image (see the README.md for more information)

set -e
POSITIONAL_ARGS=()

## Parsing parameter
while [[ $# -gt 0 ]]; do
	case $1 in
		-d|--directory)
			WORK_DIR="$2"
			shift
			shift
			;;
		-s|--sif)
			SIF="$2"
			shift
			shift
			;;
		-*|--*)
			echo "Unknown option $1"
			exit 1
			;;
		*)
			POSITIONAL_ARGS+=("$1")
			shift
			;;
	esac
done


WORK_DIR=$(realpath $WORK_DIR)
echo -e "The following directory will be use for the PASTEC and singularity files:\n$WORK_DIR"

## create directories for mysql
rm -r $WORK_DIR/mysql 2> /dev/null
mkdir -p $WORK_DIR/mysql/var/lib/mysql
mkdir -p $WORK_DIR/mysql/run/mysqld

## initialize the container
singularity instance start --bind ${WORK_DIR}:/mnt --bind ${WORK_DIR}/mysql/var/lib/mysql:/var/lib/mysql --bind ${WORK_DIR}/mysql/run/mysqld:/run/mysqld $SIF pastec 

command="singularity run instance://pastec"
match="Version: '5.7.21'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server (GPL)"
log_file="log.txt"

$command > "$log" 2>&1 &
pid=$!

while sleep 30
do
    if fgrep --quiet "$match" "$log"
    then
        kill $pid
        # exit 0
    fi
done

echo "The container has been initialised"