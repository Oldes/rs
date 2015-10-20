Red [
	Title:		"Red Console"
	Author:		["Nenad Rakocevic" "Kaj de Vos"]
	Rights:		"Copyright (c) 2012-2013 Nenad Rakocevic. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
	}
	Needs: {
		Red > 0.3.2
		%C-library/input-output.red | %common/input-output.red
	}
	Tabs:		4
]


Windows?: system/platform = 'Windows

#system-global [
	#if dynamic-linker <> "/system/bin/linker" [  ; Not Android
		#switch OS [
			Windows [
				#import [
					"kernel32.dll" stdcall [
						AttachConsole: "AttachConsole" [
							processID		[integer!]
							return:			[integer!]
						]
						SetConsoleTitle: "SetConsoleTitleA" [
							title			[c-string!]
							return:			[integer!]
						]
						ReadConsole: "ReadConsoleA" [
							consoleInput	[integer!]
							buffer			[byte-ptr!]
							charsToRead		[integer!]
							numberOfChars	[int-ptr!]
							inputControl	[int-ptr!]
							return:			[integer!]
						]
					]
				]
			]
			#default [
				#either OS = 'MacOSX [
					#define ReadLine-library "libreadline.dylib"
				][
					#define ReadLine-library "libreadline.so.6"
					#define History-library "libhistory.so.6"
				]
				#import [
					ReadLine-library cdecl [
						read-console: "readline" [			"Read a line from the console."
							prompt			[c-string!]
							return:			[c-string!]
						]
						rl-bind-key: "rl_bind_key" [
							key				[integer!]
							command			[integer!]
							return:			[integer!]
						]
						_rl-insert: "rl_insert" [
							count			[integer!]
							key				[integer!]
							return:			[integer!]
						]
					]
					#if OS <> 'MacOSX [
						History-library cdecl [
							add-history: "add_history" [	"Add line to the history."
								line		[c-string!]
							]
						]
					]
				]

				rl-insert: function [
					[cdecl]
					count		[integer!]
					key			[integer!]
					return:		[integer!]
				][
					_rl-insert count key
				]
			]
		]
	]
]

begin-console: routine [
	title		[string!]
][
	#if dynamic-linker <> "/system/bin/linker" [  ; Not Android
		#switch OS [
			Windows [
				;if zero? AttachConsole -1 [print-line "AttachConsole failed!"  halt]

				if zero? SetConsoleTitle as-c-string string/rs-head title [
					print-line "SetConsoleTitle failed."
					;halt
				]
			]
			#default [
				rl-bind-key as-integer tab  as-integer :rl-insert
			]
		]
	]
]

input-line: routine [
	prompt		[string!]
;	return:		[string! none!]
	/local
		line
		buffer size
][
	#either dynamic-linker = "/system/bin/linker" [  ; Android
		line: ask as-c-string string/rs-head prompt

		either as-logic line [
			SET_RETURN ((string/load line  1 + length? line))
;			free-any line
		][	; EOF or error
			RETURN_NONE
		]
	][
		#switch OS [
			Windows [
				prin as-c-string string/rs-head prompt

				size: 0
				buffer: allocate 80h

				either as-logic buffer [
					either all [
						as-logic ReadConsole stdin buffer 127 :size null
						size >= 2
					][
						size: size - 1  ; Remove CR/LF
						buffer/size: null-byte
						SET_RETURN ((string/load as-c-string buffer  size))
;						free buffer
					][	; EOF or error
						free buffer
						RETURN_NONE
					]
				][
					print-line "Failed to allocate input memory!"
					RETURN_NONE
				]
			]
			#default [
				line: read-console as-c-string string/rs-head prompt

				either as-logic line [
					#if OS <> 'MacOSX [add-history line]

					SET_RETURN ((string/load line  1 + length? line))
;					free-any line
				][	; EOF
					RETURN_NONE
				]
			]
		]
	]
]

do-input: function [
	script		[string!]
][
	unless unset? set/any 'result do script [
		if 69 = length? result: mold/part result 69 [
			; Truncate for display width 72
;			FIXME?: tabs & newlines
			clear at result 66
			append result "..."
		]
		print ["==" result]
	]
]

do-console: function [] [
	if all [
		file: get-argument 1
		script: read file
		not unset? set/any 'result do script
	][
		print ["==" mold result]
	]


	begin-console "Red Console"

	print {
-=== Red Console alpha version ===-
(only ASCII input supported)
}

	buffer: make string! 10'000
	literal?: no  ; string! or char!
	strings: 0
	blocks: 0
	parens: 0

	while [
		line: input-line case [
			strings > 0	["{^-"]
			parens > 0	["(^-"]
			blocks > 0	["[^-"]
			yes			["red>> "]
		]
	][
		forall line [
			switch line/1 [
				#"^"" [if zero? strings [literal?: not literal?]]
				#"{" [unless literal? [strings: strings + 1]]
				#"}" [unless any [literal?  zero? strings] [strings: strings - 1]]
				#";" [if all [zero? strings  not literal?] [clear line]]  ; Comment
				#"[" [if all [zero? strings  not literal?] [blocks: blocks + 1]]
				#"]" [unless any [literal?  not zero? strings  zero? blocks] [blocks: blocks - 1]]
				#"(" [if all [zero? strings  not literal?] [parens: parens + 1]]
				#")" [unless any [literal?  not zero? strings  zero? parens] [parens: parens - 1]]
			]
		]
		append  append buffer line  newline

		if all [zero? blocks  zero? parens  zero? strings] [
			do-input buffer
			clear buffer
			literal?: no
		]
	]
	unless empty? buffer [  ; Invalid rest
		do-input buffer
	]
]

q: :quit

about: does [
	print [
		"Red" system/version newline
		"Platform:" system/platform {

Copyright (c) 2011-2013 Nenad Rakocevic and contributors. All rights reserved.
Licensed under the Boost Software License, Version 1.0.
Copyright (c) 2011-2013 Kaj de Vos. All rights reserved.
Licensed under the BSD license.

Use LICENSE for full license text.
}
	]
]
license: does [
	print
{Copyright (c) 2011-2013 Nenad Rakocevic and contributors. All rights reserved.
Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.


Copyright (c) 2011-2013 Kaj de Vos. All rights reserved.

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
]

do-console
