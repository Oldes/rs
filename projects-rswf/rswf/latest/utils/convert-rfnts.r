rebol []

go/rswf
do %utils/exam-swf.r
do %utils/exam-swf-mod.r

convert-rfnt: func[file][
	tag-bin: read/binary  join %fonts/ file
	insert tag-bin #{0000}
	font: parse-DefineFont2
	font/file: file
	save rejoin [%fonts/ file ".ro"] font
]

;convert-rfnt %fnt_nadador.rfnt
;halt

fonts: read %fonts/
foreach file fonts [
	if parse form file [thru ".rfnt" end] [
		probe file
		convert-rfnt file
	]
]