#!/usr/bin/zsh

{ [ -z "$TVT_DEMO" ] && [ -z "$TVT_TEST" ]; } || PROMPT="[TVT Demo %~]%(!.#.$) "

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

[ -n "$VIM_TERMINAL" ] && {

#{{{ tvt.tapi_feedkeys()
tvt.tapi_feedkeys() {
	text="$1"
	text="${text//\\/\\\\\\\\}"
	text="${text//\\\\\\\\</\\\\<}"
	text="${text//\"/\\\\\\\"}"
	printf '\033]51;["call","Tapi_TVT_Feedkeys",[%d,"%s","%s"]]\007' $TVT_REDRAW_SLEEP "$text" "$2"
	TVT_FEEDING_KEYS=1
	zle tvt.escape
}
#}}}

#{{{ allow escape while running commands
autoload -Uz add-zsh-hook
TVT_RUNNING=""
tvt.preexec() {
	[ -z "$TVT_RUNNING" ] && {
		TVT_RUNNING="$(shuf -er -n 10 {0..9} {A..Z} {a..z} | tr -d "\n")"
		printf '\033]51;["call","Tapi_TVT_Running",["%s"]]\007' "$TVT_RUNNING"
	}
}
add-zsh-hook preexec tvt.preexec
tvt.precmd() {
	[ -n "$TVT_RUNNING" ] && printf '\033]51;["call","Tapi_TVT_Running",["%s"]]\007' "$TVT_RUNNING"
	TVT_RUNNING=""
}
add-zsh-hook precmd tvt.precmd
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
	[ -z "$TVT_TEST" ] || printf -- "-\n" >&4
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

	while true; do
		if [ -z "$TVT_FEEDING_KEYS" ]; then
			sleep $TVT_DRAW_SLEEP
			[ -z "$TVT_TEST" ] && printf '\033]51;["call","Tapi_TVT_Escape",[%d]]\007' "$TVT_REDRAW_SLEEP"
		else
			TVT_FEEDING_KEYS=
		fi
		sleep $TVT_REDRAW_SLEEP_HERE
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
					[ -z "$TVT_TEST" ] || printf -- "-\n" >&4
					return
				;;
				1) # done and go back to vim
					zle reset-prompt
					zle -R
					[ -z "$TVT_TEST" ] || printf -- "-\n" >&4
					break
				;;
				2) # set or [inc/dec]rement cursor position
					[[ "${action:0:1}" =~ [+-] ]] && CURSOR=$(($CURSOR$action)) || CURSOR=$action
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
	if [ -n "$TVT_ESCAPE" ]; then
		printf '\033]51;["call","Tapi_TVT_Init",[%d,"%s"]]\007' ${TVT_DELIMITER:-31} "$TVT_ESCAPE"
		bindkey "$TVT_ESCAPE" tvt.escape
	else
		printf '\033]51;["call","Tapi_TVT_Init",[%d," "]]\007' ${TVT_DELIMITER:-31}
		printf "\nTVT_ESCAPE is not set!" >&2
	fi
	TVT_DELIMITER="$(printf "$(printf "\\%o" ${TVT_DELIMITER:-31})")"
	bindkey "$TVT_DELIMITER" tvt.escape_end
	bindkey -s -M isearch "$TVT_DELIMITER" "\026$TVT_DELIMITER"
else
	printf "\nTVT_DELIMITER is not a positive integer!" >&2
fi
}
