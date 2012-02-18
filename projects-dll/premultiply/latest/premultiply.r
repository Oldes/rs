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
		argb: #{
		00000000000000000000000000000000238A9292D7232724ED000000AD171914
		A3999E9E9AD6DBD881DADADC77BDBDC5765F5F637783837E79CFCFCF80ACB4B8
		96332C33A92A2727B15E6262A25D6565C7383C40FF0305069E515451156D6D6D}
		argb-ok: #{
		0000000000000000000000000000000023121414D71D201EED000000AD0F100D
		A36164649A818482816E6E6F7758585B762B2B2D773D3D3A7962626280565A5C
		961E191EA91B1919B1414444A23B4040C72B2E31FF0305069E32343215080808}

		print argb-ok = premultiply  copy argb
		print argb-ok = premultiply2 copy argb
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
	set 'premultiply func[data [binary!] /local bytes][
		bytes: length? data
		if 0 <> (bytes // 4) [make error! "invalid data size to premultiply"]
		r_premultiply address? data bytes
		data
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
]


