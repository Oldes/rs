REBOL [
    Title: "Wav-to-mp3"
    Date: 24-Sep-2013/13:41:18+2:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "A Rebol"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: none
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: none
]

camelize-wav-name: func[name][
	name: uppercase/part name 1
	parse/all name [
		any [
			  s: "_16bit" e: (s: remove/part s e) :s
			| s: "_16b"   e: (s: remove/part s e) :s
			;| s: ".wav" end e: (s: remove/part s e) :s
			| s: some [#" " | #"_"] e: (s: remove/part s e uppercase/part s 1) :s
			|
			1 skip	
		]
	]
	probe name
]


wav-to-mp3: func[source [file! string!] /local wavs cmd][
	wavs: copy []
	if string? source [source: to-rebol-file source]
	if #"/" <> first source [ insert source what-dir ]
	either dir? source [
		foreach file read source [
			append wavs rejoin [source file]
		]
	][
		append wavs source
	]
	foreach wav wavs [
		if parse wav [thru ".wav" end][
			parts: split-path wav
			mp3: join parts/1 camelize-wav-name replace parts/2 ".wav" ".mp3"
			print join "==> " cmd: rejoin [{c:\dev\utils\lame\lame -b 320 -h --silent -t "} to-local-file wav {" "} to-local-file mp3 {"}]
			call/console cmd
		]
	]
]
wmc: does [wav-to-mp3 read clipboard://]