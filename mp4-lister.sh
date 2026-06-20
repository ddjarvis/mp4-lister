#!/usr/bin/env bash

declare STARTING_DIR="/storage/emulated/0/Videos"
declare -a NEW_LIST=()
STARTING_DIR2="/storage/emulated/0/Videos/X1/XV/XV (Blowbang -- 2026.05.30)"
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
	local dir
	local entry
	local dirs=()
	local vids=()
	
	cd "$path"
	
	parent="$(dirname "$(realpath "${PWD}")" | sed -r 's/.+\/0(\/.+)?/\1/')"
	name="$(basename "${PWD}")"
	
	mapfile -t vids < <(getVids)
	mapfile -t dirs < <(getDirs)
	
	echo ""
	printf "%s: %s\n" "Name" "${name}"
	printf "%s: %s\n" "Parent" "${parent}"
	printf "%s: %s\n" "Path" "${path}"
	printf "%s: %s\n" "Vids Count" "${#vids[@]}"
	printf "%s: %s\n" "Dirs Count" "${#dirs[@]}"
	
	if (( "${#vids[@]}" > 0 )); then {
		list="${name}.list.txt"
		echo "Has Vids!"
		if (ls -1N list*.txt &>/dev/null); then {
			echo "Found Old List"
		} fi
		
		if [[ -f "${path}/${list}" ]]; then {
			echo "Found New List"
		} else {
			echo "No New List"
			printf -v entry "%s (%s)" "${name}" "${parent:-.}"
			NEW_LIST+=("${entry}")
		} fi
	} fi
	
	if (( "${#dirs[@]}" > 0 )); then {
		echo "Has Dirs!"
		for dir in "${dirs[@]}"; do {
			parseDir "${path}/${dir}"
		} done
	} fi
	
	cd "${prevPath}"
}


parseDir "${STARTING_DIR}"