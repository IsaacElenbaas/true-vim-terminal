#!/usr/bin/bash

[ -z "$TVT_DEMO" ] || PS1="[TVT Demo \\W]\\$ "

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
# don't use the x flag, it breaks things with terminal mode
#tvt.tapi_feedkeys() {
#	text="$1"
#	text="${text//\\/\\\\\\\\}"
#	text="${text//\\\\\\\\</\\\\<}"
#	text="${text//\"/\\\\\\\"}"
#	printf '\033]51;["call","Tapi_TVT_Feedkeys",["%s","%s"]]\007' "$text" "$2"
#}
#}}}

#{{{ tvt.escape()
tvt.escape() {
	local REPLY
	local LBUFFER
	local RBUFFER

	#{{{ variable validation and parsing
	[ "${BASH_VERSION::1}" != "4" ] && {
		LBUFFER="${READLINE_LINE::$READLINE_POINT}"
		RBUFFER="${READLINE_LINE:$READLINE_POINT}"
	} || {
		LBUFFER="$(printf "%s" "$READLINE_LINE" | head -c $READLINE_POINT)"
		RBUFFER="$(printf "%s" "$READLINE_LINE" | { head -c $READLINE_POINT > /dev/null; cat; })"
	}
	[ "${TVT_DRAW_SLEEP#*[!0-9]}" = "$TVT_DRAW_SLEEP" ] || {
		printf "TVT_DRAW_SLEEP is not a positive integer! Defaulting back to 1\n" >&2
		TVT_DRAW_SLEEP=1
	}
	[ "${TVT_REDRAW_SLEEP#*[!0-9]}" = "$TVT_REDRAW_SLEEP" ] || {
		printf "TVT_REDRAW_SLEEP is not a positive integer! Defaulting back to 1\n" >&2
		TVT_REDRAW_SLEEP=1
	}
	local TVT_DRAW_SLEEP
	TVT_DRAW_SLEEP="00$TVT_DRAW_SLEEP"
	TVT_DRAW_SLEEP="${TVT_DRAW_SLEEP::-2}.${TVT_DRAW_SLEEP: -2}"
	TVT_DRAW_SLEEP="${TVT_DRAW_SLEEP#${TVT_DRAW_SLEEP%%[!0]*}}"
	[ "${TVT_DRAW_SLEEP::1}" != "." ] || TVT_DRAW_SLEEP="0$TVT_DRAW_SLEEP"
	#}}}

	printf "${PS1@P}$LBUFFER"
	printf "\033[6n"
	IFS= read -r -d "R"
	printf "$RBUFFER${REPLY}H"
	while true; do
		sleep $TVT_DRAW_SLEEP
		printf '\033]51;["call","Tapi_TVT_Escape",[%d]]\007' "$TVT_REDRAW_SLEEP"
		REPLY=
		while IFS= read -r -d "$TVT_DELIMITER" action; do
			REPLY="$REPLY$action$TVT_DELIMITER"
			[[ "${action::1}" =~ [01] ]] && break
		done
		while IFS= read -r -d "$TVT_DELIMITER" action; do

	#{{{ do action
			case "${action::1}" in
				*)
					action="${action:1}"
				;;&
				0) # done and stay in shell
					printf "\r\033[K"
					READLINE_LINE="$LBUFFER$RBUFFER"
					[ "${BASH_VERSION::1}" != "4" ] && READLINE_POINT="${#LBUFFER}" || READLINE_POINT=$(printf "%s" "$LBUFFER" | wc -c)
					return
				;;
				2) # set or [inc/dec]rement cursor position
					READLINE_LINE="$LBUFFER$RBUFFER"
					[[ "${action::1}" =~ [+-] ]] && READLINE_POINT=$((${#LBUFFER}$action)) || READLINE_POINT=$action
					[ $READLINE_POINT -lt 0 ] && READLINE_POINT=0
					LBUFFER="${READLINE_LINE::$READLINE_POINT}"
					RBUFFER="${READLINE_LINE:$READLINE_POINT}"
				;&
				1|2) # redraw
					printf "\r\033[K${PS1@P}$LBUFFER"
					printf "\033[6n"
					IFS= read -r -d "R" <&3
					printf "$RBUFFER${REPLY}H"
				;;&
				1) # done and go back to vim
					break
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
			esac
	#}}}

		done <<< "$REPLY" 3<&1
	done
}
#}}}

TVT_DRAW_SLEEP="${TVT_DRAW_SLEEP:-1}"
TVT_REDRAW_SLEEP="${TVT_REDRAW_SLEEP:-1}"
if [ "${TVT_DELIMITER#*[!0-9]}" = "$TVT_DELIMITER" ]; then
	printf '\033]51;["call","Tapi_TVT_Delimiter",[%d]]\007' ${TVT_DELIMITER:-31}
	TVT_DELIMITER="$(printf "$(printf "\\%o" ${TVT_DELIMITER:-31})")"
	if [ -n "$TVT_ESCAPE" ]; then
		TVT_ESCAPE="${TVT_ESCAPE/^\[/\\033}"
		TVT_ESCAPE="${TVT_ESCAPE/^/\\C-}"
		bind -x "\"$TVT_ESCAPE\":tvt.escape"
	else
		printf "TVT_ESCAPE is not set!\n" >&2
	fi
else
	printf "TVT_DELIMITER is not a positive integer!\n" >&2
fi
}
