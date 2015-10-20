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
			| s: some [#" " | #"_" | #"-"] e: (s: remove/part s e uppercase/part s 1) :s
			|
			1 skip	
		]
	]
	probe name
]


wav-to-mp3: func[source [file! string!] /local dir name wavs cmd loop?][
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
	foreach wav-file wavs [
		if parse wav-file [thru ".wav" end][
			set [dir name] split-path wav-file
			parse name ["_loop_" to end (loop?: true)]
			
			either loop? [
				mp3: join dir replace name ".wav" ".mp3"
				
				print join "==> " cmd: rejoin [{x:\utils\mp3loop --encoder=x:\utils\lame\lame.exe -V0 -h --silent "} to-local-file wav-file {"}]
			][
				mp3: join dir camelize-wav-name replace name ".wav" ".mp3"
				print join "==> " cmd: rejoin [
					{x:\utils\lame\lame }
					either 50000 > size? wav-file ["-b 320"]["-V 0"]
					{ -h --silent -t "} to-local-file wav-file {" "} to-local-file mp3 {"}
				]
				;print join "==> " cmd: rejoin [{x:\utils\lame\lame -V 0 -h --silent -t "} to-local-file wav-file {" "} to-local-file mp3 {"}]
			
			]
			call/console cmd
			if loop? [
				rename mp3 camelize-wav-name copy skip name 6
			]
		]
	]
]
wmc: does [wav-to-mp3 read clipboard://]