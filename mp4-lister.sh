#!/usr/bin/env bash

declare STARTING_DIR="/storage/emulated/0/Videos"

function getVids() {
	ls -1Ntr *.mp4 2>/dev/null
}

function getDirs() {
	ls -d1N */ 2>/dev/null | sed -r 's/(.+)\//\1/g'
}

function parseDir() {
	local path="$1"
	local parent
	local name
	local dirs=()
	local vids=()
	
	parent="$(dirname "$(realpath "${path}")" | sed -r 's/.+\/0(\/.+)/\1/')"
	name="$(basename "${path}")"
	
	
}