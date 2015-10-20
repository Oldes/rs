#! /usr/bin/env rebol
REBOL [
	Title:		"Build all Red(/System) examples"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2012,2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	_Needs: {
		REBOL 2 or 3
		Red > 0.3.2
	}
	Tabs:		4
]


modules: %~/Red/

; Common configuration in home directory:
Red: modules/Red/red
RedSystem: modules/Red/red-system
Red-compiler: join "r2 -sw " to-local-file modules/Red/red.r
RedSystem-compiler: join "r2 -sw " to-local-file RedSystem/rsc.r

; Common configuration on Syllable Server:
;Red: %/resources/Red
;RedSystem: Red/framework/REBOL/red-system
;Red-compiler: "redc"
;RedSystem-compiler: "rsc"
;Red-compiler: join "r2 -sw " Red/framework/REBOL/red.r
;RedSystem-compiler: join "r2 -sw " RedSystem/rsc.r


either system/version >= 2.99.0 [
	dir-exists?: func ["Test for existing directory."
		node	[file! url!]
	][
		all [node: info? node  node/type = 'dir]
	]
	read-binary: func ["Read a file as binary."
		file	[file! url!]
	][
		read file
	]
	write-binary: func ["Write a binary file."
		file	[file! url!]
		data	[binary!]
	][
		write file data
	]
][
	dir-exists?: :dir?

	read-binary: func ["Read a file as binary."
		file	[file! url!]
	][
		read/binary file
	]
	write-binary: func ["Write a binary file."
		file	[file! url!]
		data	[binary!]
	][
		write/binary file data
	]
]


build-RedSystem: func [
	target		[file!]
	path		[file!]
	program		[file!]
	options		[string! none!]
	type		[word! none!]
	/local dir file
][
	unless dir-exists? dir: target/RedSystem [
		make-dir/deep dir
	]
	file: dir/:program

	either zero? call/wait rejoin [
		RedSystem-compiler
			" -t " any [type target]
			" " any [options ""]
			" -o " to-local-file file
			" " to-local-file path/:program %.reds
	][
		if find [%MSDOS %Windows] target [
			; Kill time stamp
			write-binary append file case [options = "-dlib" %.dll  type = 'WinDRV %.sys  'else %.exe]
				head change at read-binary file 137 #{00000000}
		]
	][
		print [join program %.reds  "for" target "failed"]
	]
]

build-Red: func [
	target		[file!]
	path		[file!]
	program		[file!]
	options		[string! none!]
	type		[word! none!]
	/local dir file
][
	unless dir-exists? dir: target/Red [
		make-dir dir
	]
	change-dir dir

	either zero? call/wait rejoin [
		Red-compiler
			" -t " any [type target]
			" " any [options ""]
			" " to-local-file path/:program %.red
	][
		if find [%MSDOS %Windows] target [
			; Kill time stamp
			write-binary append file either options = "-dlib" [%.dll] [%.exe]
				head change at read-binary file 137 #{00000000}
		]
	][
		print [join program %.red  "for" target "failed"]
	]
	change-dir %../..
]

build: func [
	target		[file!]
][
	print [newline "Target" target]

	foreach spec [
		[RedSystem/tests						%empty]
		[RedSystem/tests						%hello]
		[modules/common/examples				%hello-Unicode]
		[modules/C-library/examples/Fibonacci	%Fibonacci]
		[modules/C-library/examples/Mandelbrot	%Mandelbrot]
		[modules/cURL/examples					%read-web-page]
		[modules/ZeroMQ-binding/examples		%0MQ-reply-server]
		[modules/ZeroMQ-binding/examples		%0MQ-request-client]
		[modules/REBOL-3/examples				%hello-REBOL-3-extension		"-dlib"]
		[modules/SQLite/examples				%do-sql]
		[modules/SDL/examples					%PeterPaint-SDL]
		[modules/SDL/examples					%play-SDL-WAV]
		[modules/OpenGL/examples				%GL-spin]
		[modules/OpenGL/examples				%GL-textures]
		[modules/OpenGL/examples				%GLUT-triangle]
		[modules/GTK/examples					%goodbye-cruel-GTK-world]
		[modules/GTK/examples					%hello-GTK-world]
		[modules/GTK/examples					%hello-GTK-world-with-title]
		[modules/GTK/examples					%dressed-up-hello-GTK-world]
		[modules/GTK/examples					%GTK-input-field]
		[modules/GTK/examples					%GTK-widgets]
		[modules/GTK-WebKit/examples			%LazySundayAfternoon-Browser]
		[modules/OSM-GPS-Map/examples			%OSM-GPS-Map-browser]
		[modules/GTK-Champlain/examples			%Champlain-map-browser]
		[modules/6502/examples					%6502]
	][
		spec: reduce spec
		build-RedSystem target spec/1 spec/2 spec/3 spec/4
	]
	foreach spec [
		[modules/common/examples				%empty]
		[Red/tests								%hello]
		[Red/tests								%demo]
		[Red/tests								%console]
		[modules/common/examples				%red-base]
		[modules/common/examples				%red-core]
		[modules/common/examples				%red]
		[modules/common/examples				%red-core-message]
		[modules/common/examples				%red-message]
		[modules/C-library/examples/Fibonacci	%Fibonacci]
		[modules/C-library/examples/Fibonacci	%Fibonacci-fast]
		[modules/ZeroMQ-binding/examples		%0MQ-reply-server]
		[modules/ZeroMQ-binding/examples		%0MQ-request-client]
		[modules/ZeroMQ-binding/examples		%0MQ-ventilator]
		[modules/ZeroMQ-binding/examples		%0MQ-ventilator-worker]
		[modules/ZeroMQ-binding/examples		%0MQ-ventilator-sink]
		[modules/REBOL-3/examples				%hello-REBOL-3-extension		"-dlib"]
		[modules/SQLite/examples				%do-sql]
		[modules/GTK/examples					%hello-GTK-world]
		[modules/GTK/examples					%hello-GTK-world-with-title]
		[modules/GTK/examples					%dressed-up-hello-GTK-world]
		[modules/GTK/examples					%GTK-input-field]
		[modules/GTK/examples					%GTK-widgets]
		[modules/GTK/examples					%GTK-text-editor]
		[modules/GTK/examples					%GTK-IDE]
		[modules/GTK/examples					%GTK-browser]
	][
		spec: reduce spec
		build-Red target spec/1 spec/2 spec/3 spec/4
	]
]


either target: system/script/args [
	build to-file undirize target
][
	print [newline "Target MSDOS"]

	foreach spec [
;		[modules/Windows/examples				%hello-kernel-driver			none		'WinDRV]
	][
		spec: reduce spec
		build-RedSystem %MSDOS spec/1 spec/2 spec/3 spec/4
	]

	foreach target [
		%Linux
		%MSDOS
		%Syllable
		%Linux-ARM
		%Android-x86
		%Windows
		%Android
		%Darwin
	][
		build target
	]
]
