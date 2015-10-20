#! /usr/bin/env rebol
REBOL [
	Title:		"Download or update all Red(/System) extensions"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013 Kaj de Vos"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	_Needs: {
		REBOL 2 or 3
		Fossil
	}
	Tabs:		4
]

credentials: ""  ; Anonymous access / "check+out+user[:password]"
user: ""  ; Anonymous access / "check-in user"

fossil: either any [exists? %fossil  exists? %fossil.exe] [
	to-local-file append what-dir %fossil
][
	"fossil"
]

foreach target [
	%test
	%common
	%C-library
	%cURL
	%ZeroMQ-binding
	%REBOL-3
	%Java
	%SQLite
	%SDL
	%OpenGL
	%GLib
	%GTK
	%GTK-WebKit
	%OSM-GPS-Map
	%GTK-Champlain
	%6502
][
	print ["Target" target]

	either exists? target [
		change-dir target

		unless zero? call/wait join fossil " update" [
			print ["Updating" target "failed"]
		]
		change-dir %..
	][
		either any [
			exists? archive: join name: join %Red- target  %.fossil
			(
				link: rejoin [http://
					either empty? credentials [""] [join credentials "@"]
					%red.esperconsultancy.nl/ name
				]
				zero? call/wait reform [
					fossil "clone"
						either empty? user [""] [rejoin ["--admin-user '" user "'"]]
						link archive
				]
			)(
				print ["Downloading" link "failed"]
				no
			)
		][
			make-dir target
			change-dir target

			unless zero? call/wait rejoin [fossil " open ../" archive] [
				print ["Opening" archive "failed"]
			]
			change-dir %..
		][
			print ["Database" archive "not available"]
		]
	]
]
