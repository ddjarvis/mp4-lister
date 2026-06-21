#!/usr/bin/env bash

declare -i DEBUG=1
declare -i DRYRUN=1
declare -i FORCE=0
declare STARTING_DIR="/storage/emulated/0/Videos"
declare -a NEW_LIST=()
declare TIMESTAMP=""
STARTING_DIR2="/storage/emulated/0/Videos/X1/XV/XV (Blowbang -- 2026.05.30)"

function debug() {
	if (( DEBUG > 0 )); then
		if [[ "$1" == "." || "$1" == " " || "$1" == "" ]]; then {
			echo ""
		} else {
			printf "\e[1;96m%s\e[0m %s\n" "[DEBUG]" "${1:-Lorem ipsum dolor sit amet...}" 1>&2
		} fi
	fi
}
function log() {
	if [[ "$1" == "." || "$1" == " " || "$1" == "" ]]; then {
		echo ""
	} else {
		printf "\e[1;93m%s\e[0m %s\n" "[LOG]" "${1:-Lorem ipsum dolor sit amet...}" 1>&2
	} fi
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
	log "Parsing Dir: ${name}"
	
	if (( "${#vids[@]}" > 0 )); then {
		list="${name}.list.txt"
		listpath="${path}/${list}"
		debug "Directory has vids."
		if (ls -1N list*.txt &>/dev/null); then {
			debug "Found [Old] List. Deleting..."
			log "Deleting old list(s)..."
			if (( DRYRUN == 0 )); then {
				rm -f list*.txt 2>/dev/null
			} else {
				ls -1N list*.txt
			} fi
		} fi
		
		if [[ -f "${listpath}" ]] && (( FORCE == 0 )); then {
			debug "Found [New] List. Skipping..."
			log "Directory already has list. Moving forward..."
		} else {
			if (( FORCE == 0 )); then {
				debug "Unable to find [New] List. Generating list..."
			} else {
				debug "Force Mode is active. Generating list..."
			} fi
			log "Generating list..."
			printf -v entry "%s\t(%s)" "${name}" "${parent:-.}"
			debug "${entry}"
			
			if (( DRYRUN == 0 )); then {
				generateList "${name}" "${parent}" "${path}" "${vids[@]}" >"${listpath}" \
				&& log "Saved List: %s\n" "${list}" \
				&& debug "Saved List to: ${listpath}"
			} else {
				generateList "${name}" "${parent}" "${path}" "${vids[@]}"
				debug "Saved List to: ${listpath}"
			} fi
			
			NEW_LIST+=("${entry}")
		} fi
	} fi
	
	if (( "${#dirs[@]}" > 0 )); then {
		debug "Directory has subdirs!"
		log "Identified subdirectories. Parsing..."
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
	local path="${1}"
	local dirpath
	local datetime
	local filename
	local filepath
	
	if (( ${#NEW_LIST[@]} > 0 )); then {
		TIMESTAMP="$(date +"%Y-%m-%d %X")"
		datetime="$(date -d "$TIMESTAMP" +"%Y%m%d_%H%M%S")"
		dirpath="${path}/.lists"
		filename="newlists--${datetime}.list.txt"
		filepath="${dirpath}/${filename}"
		debug ""
		debug "TIMESTAMP : ${TIMESTAMP}"
		debug "datetime: ${datetime}"
		debug "path: ${path}"
		debug "dirpath: ${dirpath}"
		debug "filename: ${filename}"
		debug "filepath: ${filepath}"
		
		if (( DRYRUN == 0 )); then {
			if [[ ! -d "${dirpath}" ]]; then mkdir -p "${dirpath}"; fi
			printNewList_generate >"${filepath}" \
			&& printf "Saved List: %s\n" "${filename}" \
			&& debug "Saved List to: ${filepath}"
		} else {
			printNewList_generate
			debug "Saved List to: ${filepath}"
		} fi
	} fi
}

function printNewList_generate() {
	printf "%s: %s\n" "Date/Time" "${TIMESTAMP}"
	printf "%s: %s\n" "New List Items" "${#NEW_LIST[@]}"
	echo ""
	printf "• %s\n" "${NEW_LIST[@]}"
}

function parseArgs() {
	local debug=0
	local dryrun=0
	local force=0
	local dir=""
	# Options/Arguments Parser (getopt)...
	{
		local OPT="$(getopt -o "dnf" -l "debug,dry-run,force" -- "$@" )"
		eval set -- "${OPT}" && unset OPT
		while true; do {
			case "$1" in
				-d | --debug ) debug=1; shift ;;
				-n | --dry-run ) dryrun=1; shift ;;
				-f | --force) force=1; shift ;;
				-- ) shift ; break ;;
				* ) shift ;;
			esac
		} done
	}
	if (( $# > 0 )); then dir="$(realpath "$1")"; fi
	
	debug "debug: ${debug}"
	debug "dryrun: ${dryrun}"
	debug "force: ${force}"
	debug "dir: ${dir}"
	
	DEBUG="${debug}"
	DRYRUN="${dryrun}"
	FORCE="${force}"
	if [[ "${dir}" != "" && -d "${dir}" ]]; then STARTING_DIR="${dir}"; fi
}

function main() {
	parseArgs "$@"
	parseDir "${STARTING_DIR}"
	log "Done parsing directories. Outputting new lists..."
	printNewList "${STARTING_DIR}"
}

main "$@"


