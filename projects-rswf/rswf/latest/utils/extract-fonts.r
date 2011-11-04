rebol []

swf-dir: to-rebol-file "J:\!!!!!!!!!!!!!!!!\fonty\swf-alphaomegadigital.com\"
files:  read swf-dir
foreach font-swf files [
	print font-swf
	if parse/all to-string font-swf [copy font-name to {[1].swf} to end][
		print font-name
		exam-swf/file/quiet/store swf-dir/:font-swf
		foreach tag swf/data [
			if tag/1 = 48 [
				write/binary rejoin [swf-dir/fnt_ font-name ".rfnt"] skip tag/3 2
				print ["....found!" stats]
			]
		]
	]
]
recycle

comment {
rs/run %rswf
go/pr 'rswf
do %utils/exam-swf-mod.r
do %utils/extract-fonts.r
}