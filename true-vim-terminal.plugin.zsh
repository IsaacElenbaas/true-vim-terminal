#!/bin/zsh

# this CANNOT be ^W
# vim really hates passing it through consistently
# use showkey -a to make sure it's something passed through properly
#TVT_ESCAPE=""
# decimal ASCII code for IPC delimiter (default is unit separator)
#TVT_DELIMITER=31
# how long to sleep to finish drawing BUFFER in 10ms increments
# can be modified on-the-fly
#TVT_DRAW_SLEEP=1
# how long to sleep to let vim get new content in 10ms increments
# can be modified on-the-fly
#TVT_REDRAW_SLEEP=1

#{{{ tvt.tapi_feedkeys()
# don't use the x flag, it breaks things with terminal mode
#tvt.tapi_feedkeys() {
#	text="$1"
#	text="${text//\\/\\\\\\\\}"
#	text="${text//\\\\\\\\</\\\\<}"
#	text="${text//\"/\\\\\\\"}"
#	printf '\033]51;["call","Tapi_TVT_Feedkeys",["%s","%s"]]\007' "$text" "$2"
#}
#}}}

#{{{ tvt.read()
# based on https://github.com/zsh-users/zsh/blob/master/Functions/Zle/read-from-minibuffer
tvt.read() {
	local tvt_UNDO_CHANGE_NO="$UNDO_CHANGE_NO"
	local tvt_UNDO_LIMIT_NO="$UNDO_LIMIT_NO"
	BUFFER=""
	printf "\r"
	zle recursive-edit -K main && {
		REPLY="$BUFFER"
		zle undo "$tvt_UNDO_CHANGE_NO"
		UNDO_LIMIT_NO="$tvt_UNDO_LIMIT_NO"
	} || { REPLY=""; return 1; }
}
zle -N tvt.read
#}}}

#{{{ tvt.escape()
tvt.escape() {
	local REPLY

	#{{{ variable validation and parsing
	[ "${TVT_DRAW_SLEEP#*[!0-9]}" = "$TVT_DRAW_SLEEP" ] || {
		printf "\nTVT_DRAW_SLEEP is not a positive integer! Defaulting back to 1" >&2
		TVT_DRAW_SLEEP=1
	}
	[ "${TVT_REDRAW_SLEEP#*[!0-9]}" = "$TVT_REDRAW_SLEEP" ] || {
		printf "\nTVT_REDRAW_SLEEP is not a positive integer! Defaulting back to 1" >&2
		TVT_REDRAW_SLEEP=1
	}
	local TVT_DRAW_SLEEP
	TVT_DRAW_SLEEP="00$TVT_DRAW_SLEEP"
	TVT_DRAW_SLEEP="${TVT_DRAW_SLEEP:0:-2}.${TVT_DRAW_SLEEP: -2}"
	TVT_DRAW_SLEEP="${TVT_DRAW_SLEEP#${TVT_DRAW_SLEEP%%[!0]*}}"
	[ "${TVT_DRAW_SLEEP:0:1}" != "." ] || TVT_DRAW_SLEEP="0$TVT_DRAW_SLEEP"
	# tvt.read moves cursor, we don't want vim to pick up on that
	local TVT_REDRAW_SLEEP_HERE
	TVT_REDRAW_SLEEP_HERE="00$((TVT_REDRAW_SLEEP+1))"
	TVT_REDRAW_SLEEP_HERE="${TVT_REDRAW_SLEEP_HERE:0:-2}.${TVT_REDRAW_SLEEP_HERE: -2}"
	TVT_REDRAW_SLEEP_HERE="${TVT_REDRAW_SLEEP_HERE#${TVT_REDRAW_SLEEP_HERE%%[!0]*}}"
	[ "${TVT_REDRAW_SLEEP_HERE:0:1}" != "." ] || TVT_REDRAW_SLEEP_HERE="0$TVT_REDRAW_SLEEP_HERE"
	#}}}

	printf '\033]51;["call","Tapi_TVT_Escape",[]]\007'
	while true; do
		zle tvt.read || { zle reset-prompt; return 1; }
		[ -n "$REPLY" ] || { zle reset-prompt; return 1; }
		while IFS= read -r -d "$TVT_DELIMITER" action; do

	#{{{ do action
			case "${action:0:1}" in
				*)
					action="${action:1}"
				;|
				0) # done and stay in shell
					zle reset-prompt
					return
				;;
				1) # done and go back to vim
					zle reset-prompt
					zle -R
					break
				;;
				2) # set or [inc/dec]rement cursor position
					[[ "${action:0:1}" =~ [+-] ]] && CURSOR=$(($CURSOR$action)) || CURSOR="$action"
				;;
				3) # set LBUFFER
					LBUFFER="$action"
				;;
				4) # set RBUFFER
					RBUFFER="$action"
				;;
				5) # append to LBUFFER
					LBUFFER="$LBUFFER$action"
				;;
				6) # prepend RBUFFER
					RBUFFER="$action$RBUFFER"
				;;
				*)
					zle reset-prompt
					return
				;;
			esac
	#}}}

		done <<< "$REPLY"
		sleep $TVT_DRAW_SLEEP
		printf '\033]51;["call","Tapi_TVT_Escape",[%d]]\007' "$TVT_REDRAW_SLEEP"
		sleep $TVT_REDRAW_SLEEP_HERE
	done
}
zle -N tvt.escape
#}}}

#{{{ tvt.escape_end()
tvt.escape_end() {
	zle self-insert
	[ $ZLE_RECURSIVE -gt 0 ] && {
		[[ "${LBUFFER: -2:-1}" =~ [01] ]] && \
		{ [ -z "${LBUFFER: -3:-2}" ] || [ "${LBUFFER: -3:-2}" = "$TVT_DELIMITER" ]; }
	} && zle accept-line
}
zle -N tvt.escape_end
#}}}

TVT_DRAW_SLEEP="${TVT_DRAW_SLEEP:-1}"
TVT_REDRAW_SLEEP="${TVT_REDRAW_SLEEP:-1}"
if [ "${TVT_DELIMITER#*[!0-9]}" = "$TVT_DELIMITER" ]; then
	printf '\033]51;["call","Tapi_TVT_Delimiter",[%d]]\007' ${TVT_DELIMITER:-31}
	TVT_DELIMITER="$(printf "$(printf "\\%o" ${TVT_DELIMITER:-31})")"
	if [ -n "$TVT_ESCAPE" ]; then
		bindkey "$TVT_ESCAPE" tvt.escape
	else
		printf "\nTVT_ESCAPE is not set!" >&2
	fi
	bindkey "$TVT_DELIMITER" tvt.escape_end
	bindkey -s -M isearch "$TVT_DELIMITER" "\026$TVT_DELIMITER"
else
	printf "\nTVT_DELIMITER is not a positive integer!" >&2
fi
