Red [
	Title:		"ANSI C Library Binding"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2011-2013 Kaj de Vos. All rights reserved."
	License: {
		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:

		    * Redistributions of source code must retain the above copyright notice,
		      this list of conditions and the following disclaimer.
		    * Redistributions in binary form must reproduce the above copyright notice,
		      this list of conditions and the following disclaimer in the documentation
		      and/or other materials provided with the distribution.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
		ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
		WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
		FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
		CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
		OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	}
	Needs: {
		Red > 0.3.1
		%C-library/ANSI.reds
		%common/common.red
	}
	Tabs:		4
]


#system-global [#include %ANSI.reds]
#include %../common/common.red


; Type conversions

to-integer: routine ["Parse string to integer."
	text			[string!]
	return:			[integer!]
][
	system/words/to-integer as-c-string string/rs-head text
]


; Input/output

input: routine ["Read a line from standard input."
;	return:			[string! none!]
	/local			line
][
	line: system/words/input

	either as-logic line [
		SET_RETURN ((string/load line  1 + length? line))
;		free-any line
	][	; FIXME: report error
		RETURN_NONE
	]
]
ask: function ["Prompt for input."
	prompt			[string!]
	return:			[string! none!]
][
	prin prompt
	input
]


; Dates and time

now-with: routine ["Current time."
	precise?		[logic!]
	utc?			[logic!]
	zone?			[logic!]
	date?			[logic!]
	time?			[logic!]
	year?			[logic!]
	month?			[logic!]
	day?			[logic!]
	hour?			[logic!]
	minute?			[logic!]
	second?			[logic!]
	weekday?		[logic!]
	yearday?		[logic!]
;	return:			[string! integer! none!]
	/local			time date minutes zone sign day text
][
	time: now-time null

	either time = -1 [
		RETURN_NONE
	][
		either precise? [
			integer/box time
		][
			text: make-c-string 27

			either as-logic text [
				date: to-date :time

				either as-logic date [
					minutes: date/hour * 60 + date/minute

					date: to-local-date :time
					zone: date/hour * 60 + date/minute - minutes

					either zone > 720 [  ; 12 hours
						zone: zone - 1440  ; 24 hours
					][
						if zone <= -720 [zone: zone + 1440]
					]
					sign: either negative? zone [
						zone: negate zone
						#"-"
					][
						#"+"
					]

					if utc? [date: to-date :time]

					case [
						second?		[integer/box date/second]
						minute?		[integer/box date/minute]
						hour?		[integer/box date/hour]
						day?		[integer/box date/day]
						month?		[integer/box date/month + 1]
						year?		[integer/box date/year + 1900]
						yearday?	[integer/box date/yearday + 1]
						weekday? [
							day: date/weekday

							; REBOL has a wrong world view
							integer/box either as-logic day [day] [7]  ; Sunday
						]
						zone? [
							either 5 <= format-any [text "%c%i:%02i" sign  zone / 60  zone // 60] [
								SET_RETURN ((string/load text  1 + length? text))
							][	; FIXME: report error
								RETURN_NONE
							]
						]
						date? [
							either format-date text 27 "%d-%b-%Y" date [
								SET_RETURN ((string/load text  1 + length? text))
							][	; FIXME: report error
								RETURN_NONE
							]
						]
						time? [
							either format-date text 27 "%H:%M:%S" date [
								SET_RETURN ((string/load text  1 + length? text))
							][	; FIXME: report error
								RETURN_NONE
							]
						]
						yes [
							either format-date text 27 "%d-%b-%Y/%H:%M:%S" date [
								either any [utc?  25 <= format-any [text "%s%c%i:%02i" text sign  zone / 60  zone // 60]] [
									SET_RETURN ((string/load text  1 + length? text))
								][	; FIXME: report error
									RETURN_NONE
								]
							][	; FIXME: report error
								RETURN_NONE
							]
						]
					]
				][
					RETURN_NONE
				]
;				free-any text
			][	; FIXME: report error
				RETURN_NONE
			]
		]
	]
]
now: function ["Current time."
	/precise
	/utc /zone
	/date /time
	/year /month /day
	/hour /minute /second
	/weekday /yearday
	return:			[string! integer! none!]
][
	now-with
		precise
		utc zone
		date time
		year month day
		hour minute second
		weekday yearday
]

subtract-time: routine ["time-1 - time-2"
	time-1			[integer!]  "time!"
	time-2			[integer!]  "time!"
;	return:			[integer! none!]  "Seconds"
	/local			string
][
;	TODO: optimise

	string: make-c-string 38  ; Max 64 bits; FIXME?: enough?

	either as-logic string [
		format-any [string "%.0f"  system/words/subtract-time time-1 time-2]  ; FIXME?: error possible?
		integer/box system/words/to-integer string
		free-any string
	][
		RETURN_NONE
	]
]

get-process-seconds: routine ["CPU time used by process; wall-clock time on Windows!"
;	return:			[integer! none!]  ; TODO: return float!
	/local			time
][
	time: get-process-time

	either time = -1 [RETURN_NONE] [integer/box time / clocks-per-second]
]


; Random numbers

random-with: routine [
	number			[integer!]
	seed?			[logic!]
	secure?			[logic!]
;	return:			[integer! unset!]
][
	either seed? [
		either secure? [random-seed-secure] [random-seed number]
		RETURN_UNSET
	][
		integer/box random number
	]
]
random: function ["Pseudo-random number from 1 thru VALUE."
	number			[integer!]
	/seed			"Restart the sequence with new seed VALUE (initially 1)."
	/secure			"Use time based seed."
	return:			[integer! unset!]
][
	random-with number seed secure
]


; System interfacing

get-env: routine ["Get system environment variable."
	name			[string!]
;	return:			[string! none!]
	/local text value
][
	text: to-UTF8 name
	value: system/words/get-env text
	free-any text

	either as-logic value [
		SET_RETURN ((string/load value  1 + length? value))
;		free-any value  ; ?
	][
		RETURN_NONE
	]
]

call-wait: routine ["Execute external system command, await its return."
	command			[string!]
	return:			[integer!]
	/local text status
][
	text: to-UTF8 command
	status: system/words/call-wait text
	free-any text
	status
]
call: function ["Execute external system command."
	command			[string!]
	/wait			"Await command's return."
	return:			[integer!]
][
	call-wait command
]
