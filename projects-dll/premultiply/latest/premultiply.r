REBOL [
    Title: "Premultiply"
    Date: 17-Feb-2012/10:51:29+1:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "David Oliva (commercial)"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: [
		;rs/run/usage 'premultiply
		system/options/binary-base: 32
		print ((probe demultiply #{5522ffaa}) = (probe demultiply2 #{5522ffaa}))
		print ((probe demultiply #{000000005522ffaa}) = (probe demultiply2 #{000000005522ffaa}))
		ARGB: #{
		00000000000000000000000000000000238A9292D7232724ED000000AD171914
		A3999E9E9AD6DBD881DADADC77BDBDC5765F5F637783837E79CFCFCF80ACB4B8
		96332C33A92A2727B15E6262A25D6565C7383C40FF0305069E515451156D6D6D}
		ARGB-ok: #{
		0000000000000000000000000000000023121414D71D201EED000000AD0F100D
		A36164649A818482816E6E6F7758585B762B2B2D773D3D3A7962626280565A5C
		961E191EA91B1919B1414444A23B4040C72B2E31FF0305069E32343215080808}

		print ARGB-ok = premultiply  copy ARGB
		print ARGB-ok = premultiply2 copy ARGB
	]
    Purpose: none
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: none
	Require: [
		rs-project 'memory-tools
	]
]

ctx-premultiply: context [
	*lib: load/library dir_lib/premultiply.dll
	r_premultiply: make routine! [*data [integer!] bytes [integer!]] *lib "premultiply"
	r_demultiply:  make routine! [*data [integer!] bytes [integer!]] *lib "demultiply"
	set 'premultiply func[ARGB [binary!] /local bytes][
		bytes: length? ARGB
		if 0 <> (bytes // 4) [make error! "invalid data size to premultiply"]
		r_premultiply address? ARGB bytes
		ARGB
	]
	set 'premultiply2 func[ARGB /local a bytes][
		bytes: length? ARGB
		if 0 <> (bytes // 4) [make error! "invalid data size to premultiply"]
		while [not tail? ARGB][
			a: ARGB/1 / 255
			ARGB: next ARGB
			ARGB: change ARGB to char! (a * ARGB/1)
			ARGB: change ARGB to char! (a * ARGB/1)
			ARGB: change ARGB to char! (a * ARGB/1)
		]
		ARGB: head ARGB
	]
	
	set 'demultiply func[ARGB [binary!] /local bytes][
		bytes: length? ARGB
		if 0 <> (bytes // 4) [make error! "invalid data size to demultiply"]
		r_demultiply address? ARGB bytes
		ARGB
	]
	set 'demultiply2 func[ARGB [binary!] /local bytes a][
		bytes: length? ARGB
		if 0 <> (bytes // 4) [make error! "invalid data size to demultiply"]
		loop bytes / 4 [
			either 0 = a: first ARGB [
				ARGB: skip ARGB 4
			][
				if error? try [
					a: a * 256
					ARGB: next ARGB
					ARGB: change ARGB to char! min 255 to integer! (shift/left first ARGB 16) / a
					ARGB: change ARGB to char! min 255 to integer! (shift/left first ARGB 16) / a
					ARGB: change ARGB to char! min 255 to integer! (shift/left first ARGB 16) / a
				][
					print ["ERR:" a mold copy/part ARGB 4]
					halt
				]
			]
		]
		ARGB: head ARGB
	]
]


