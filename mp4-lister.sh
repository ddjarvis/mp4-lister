#!/usr/bin/env bash

declare -i DEBUG=1
declare STARTING_DIR="/storage/emulated/0/Videos"
declare -a NEW_LIST=()
declare TIMESTAMP=""
STARTING_DIR2="/storage/emulated/0/Videos/X1/XV/XV (Blowbang -- 2026.05.30)"

function debug() {
	if (( DEBUG > 0 )); then
		if [[ "$1" == "." || "$1" == " " || "$1" == "" ]]; then {
			echo ""
		} else {
			printf "\e[1;96m%s\e[0m %s\n" "[DEBUG]" "${1:-Lorem ipsum dolor sit amet...}"
		} fi
	fi
}
function getVids() {
	ls -1Ntr *.mp4 2>/dev/null
}
function getDirs() {
	ls -d1N */ 2>/dev/null | sed -r 's/(.+)\//\1/g'
}

function parseDir() {
	local path="$1"
	local prevPath="$PWD"
	local parent
	local name
	local list
	local listpath
	local dir
	local entry
	local err
	local dirs=()
	local vids=()
	
	cd "$path"
	
	parent="$(dirname "$(realpath "${PWD}")" | sed -r 's/.+\/0(\/.+)?/\1/')"
	name="$(basename "${PWD}")"
	
	mapfile -t vids < <(getVids)
	mapfile -t dirs < <(getDirs)
	
	debug " "
	debug "Name: ${name}"
	debug "Parent: ${parent}"
	debug "Path: ${path}"
	debug "Vids Count: ${#vids[@]}"
	debug "Dirs Count: ${#dirs[@]}"
	
	if (( "${#vids[@]}" > 0 )); then {
		list="${name}.list.txt"
		listpath="${path}/${list}"
		debug "Directory has vids."
		if (ls -1N list*.txt &>/dev/null); then {
			debug "Found [Old] List. Deleting..."
		} fi
		
		if [[ -f "${listpath}" ]]; then {
			debug "Found [New] List. Skipping..."
		} else {
			debug "Unable to find [New] List. Generating list..."
			printf -v entry "%s\t(%s)" "${name}" "${parent:-.}"
			debug "${entry}"
			
			generateList "${name}" "${parent}" "${path}" "${vids[@]}"
			
			NEW_LIST+=("${entry}")
		} fi
	} fi
	
	if (( "${#dirs[@]}" > 0 )); then {
		debug "Directory has subdirs!"
		for dir in "${dirs[@]}"; do {
			parseDir "${path}/${dir}"
		} done
	} fi
	
	cd "${prevPath}"
}

function generateList() {
	local name="$1"
	local parent="$2"
	local path="$3"
	shift 3
	
	local vids=("$@")
	echo "Name: ${name}"
	echo "Dir: ${parent}"
	echo "Path: ${path}"
	echo ""
	
	printf "%s\n" "${vids[@]}"
}

function printNewList() {
	local path="${STARTING_DIR}"
	local datetime
	local filename
	local filepath
	
	if (( ${#NEW_LIST[@]} > 0 )); then {
		TIMESTAMP="$(date +"%Y-%m-%d %X")"
		if (( $# > 0 )) && [[ -d "$1" ]]; then
			path="$1"
		fi
		datetime="$(date -d "$TIMESTAMP" +"%Y%m%d_%H%M%S")"
		filename="newlists--${datetime}.list.txt"
		filepath="${path}/${filename}"
		debug ""
		debug "TIMESTAMP : ${TIMESTAMP}"
		debug "datetime: ${datetime}"
		debug "path: ${path}"
		debug "filename: ${filename}"
		debug "filepath: ${filepath}"
		
		printf "%s: %s\n" "Date/Time" "${TIMESTAMP}"
		printf "%s: %s\n" "New List Items" "${#NEW_LIST[@]}"
		echo ""
		printf "• %s\n" "${NEW_LIST[@]}"
	} fi
}

parseDir "${STARTING_DIR}"

printNewList