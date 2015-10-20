Red [
	Title:		"Common Definitions"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013 Kaj de Vos. All rights reserved."
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
		Red > 0.3.2
		%C-library/ANSI.reds
	}
	Tabs:		4
]


#system-global [#include %../C-library/ANSI.reds]


; Program arguments

args-count: routine ["Get number of program arguments, including program name."
	return:			[integer!]
][
	system/args-count
]
get-argument: routine ["Get a program argument."
	offset			[integer!]  "0: program file name"
;	return:			[string! none!]  "Argument, or NONE"
	/local			argument
][
	either offset < system/args-count [
		argument: system/args-list + offset
		SET_RETURN ((string/load argument/item  1 + length? argument/item))
	][
		RETURN_NONE
	]
]
arguments: function ["Get program arguments, excluding program name."
	return:			[block! none!]
][
	either 2 > count: args-count [
		none
	][
		list: []

		repeat i  count - 1 [
			append list  get-argument i
		]
		list
	]
]


; Common functions

zero?: routine [
	value			[integer!]
	return:			[logic!]
][
	zero? value
]


; Unicode

#system [

	Latin1-to-UTF8: function ["Return UTF-8 encoding of Latin-1 text."
		series			[red-string!]
		return:			[c-string!]
		/local
			text tail char
			out index
	][
		text: string/rs-head series
		tail: string/rs-tail series

		out: allocate (as-integer tail - text) * 2 + 1
		unless as-logic out [return null]
		index: out

		while [
			char: text/value  ; FIXME: tail overflow
			all [text < tail  char <> as-byte 0]
		][
			either char < as-byte 80h [
				index/1: char
				index: index + 1
			][
				index/2: char and (as-byte 3Fh) or as-byte 80h
				index/1: char >>> 6 or as-byte C0h
				index: index + 2
			]
			text: text + 1
		]
		index/1: null-byte
		as-c-string resize out  (as-integer index - out) + 1
	]

	UCS2-to-UTF8: function ["Return UTF-8 encoding of UCS-2 Unicode text."
		series			[red-string!]
		return:			[c-string!]
		/local
			text tail char
			pointer
			out index
	][
		text: string/rs-head series
		tail: string/rs-tail series

		out: allocate (as-integer tail - text) / 2 * 3 + 1 + 3  ; Safety padding
		unless as-logic out [return null]
		index: out

		while [
			pointer: as pointer! [integer!] text
			char: pointer/value and FFFFh  ; FIXME: tail overflow
			all [text < tail  char <> 0]
		][
			case [  ; Basic Multilingual Plane
				char < 80h [
					index/1: as-byte char
					index: index + 1
				]
				char < 0800h [
					index/2: as-byte char and 3Fh or 80h
					index/1: as-byte char >>> 6 or C0h
					index: index + 2
				]
				yes [
					pointer: as pointer! [integer!] index
					pointer/value:
						char << 16 and 3F0000h
						or (char << 2 and 3F00h)
						or (char >>> 12)
						or 008080E0h
					index: index + 3
				]
			]
			text: text + 2
		]
		index/1: null-byte
		as-c-string resize out  (as-integer index - out) + 1
	]

	UCS4-to-UTF8: function ["Return UTF-8 encoding of UCS-4 Unicode text."
		series			[red-string!]
		return:			[c-string!]
		/local
			text tail char
			out index pointer
	][
		text: as pointer! [integer!] string/rs-head series
		tail: string/rs-tail series

		out: allocate (as-integer tail - text) + 1 + 3  ; Safety padding
		unless as-logic out [return null]
		index: out

		while [
			char: text/value  ; FIXME: tail overflow
			all [text < tail  char <> 0]
		][
			case [
				char < 80h [
					index/1: as-byte char
					index: index + 1
				]
				char < 0800h [
					index/2: as-byte char and 3Fh or 80h
					index/1: as-byte char >>> 6 or C0h
					index: index + 2
				]
				char <= FFFFh [
					pointer: as pointer! [integer!] index
					pointer/value:
						char << 16 and 3F0000h
						or (char << 2 and 3F00h)
						or (char >>> 12)
						or 008080E0h
					index: index + 3
				]
				char < 00200000h [  ; Above BMP
					pointer: as pointer! [integer!] index
					pointer/value:
						char << 24 and 3F000000h
						or (char << 10 and 3F0000h)
						or (char >>> 4 and 3F00h)
						or (char >>> 18)
						or 808080F0h
					index: index + 4
				]
				yes [
					print-line "Error in UCS4-to-UTF8: codepoint above 1FFFFFh"
				]
			]
			text: text + 1
		]
		index/1: null-byte
		as-c-string resize out  (as-integer index - out) + 1
	]

	to-UTF8: function ["Return UTF-8 encoding of a Red string."
		text			[red-string!]
		return:			[c-string!]
		/local			series
	][
		series: GET_BUFFER (text)

		switch GET_UNIT (series) [
			Latin1	[Latin1-to-UTF8 text]
			UCS-2	[UCS2-to-UTF8 text]
			UCS-4	[UCS4-to-UTF8 text]
			default	[
				print-line ["Error: unknown text encoding: " GET_UNIT (series)]
				null
			]
		]
	]

	to-local-file: function ["Return file name encoding for local system."
		name			[red-string!]
		return:			[c-string!]
		/local series head size out
	][
		#switch OS [
			Windows [
				series: GET_BUFFER (name)

				unless Latin1 = GET_UNIT (series) [
					print-line ["Error: invalid file name encoding: " GET_UNIT (series)]
					return null
				]

				head: string/rs-head name
				size: as-integer (string/rs-tail name) - head + 1  ; Closing null seems to be at tail

;				if zero? size [return null]

				out: allocate size

				if as-logic out [
					copy-part head out size
					out/size: null-byte  ; For safety
				]
				as-c-string out
			]
			#default [
				to-UTF8 name
			]
		]
	]

]
