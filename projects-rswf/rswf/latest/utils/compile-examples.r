rebol [
	title: "Examples compiler"
	purpose: "Compiles all example files"
	author: "oldes"
]

use [edir fdir dirs files target tdir err print-error][
	print-error: func[err /local type id arg1 arg2 arg3][
		set [type id arg1 arg2 arg3] reduce [err/type err/id err/arg1 err/arg2 err/arg3]
		print [
			system/error/:type/type ": "
			reduce bind system/error/:type/:id 'arg1
		]
		print ["** Where: " mold err/where]
		print ["** Near: " mold err/near]
	]
	probe dirs: read edir: dirize rswf-root-dir/examples
	forall dirs [
		;probe type? dirs/1
		if dir? join edir dirs/1 [
			files: read fdir: join edir dirs/1
			forall files [
				if "rswf" = last parse files/1 "." [
					src: join fdir files/1
					hdr: first load/header src
					target: rejoin [edir %compiled/ hdr/file]
					if not exists? tdir: first split-path target [
						make-dir/deep tdir
					]
					if any [
						not exists? target
						(modified? src) > (modified? target)
					] [
						prin files/1
						either error? set/any 'err try [
							either any [
								none? find [swf5 mx mx2004] hdr/type
								all [
									not error? try [hdr/compressed]
									not hdr/compressed
								]
							][	make-swf/save/to src target
							][	make-swf/save/to/compressed src target ]
						][print "...ERROR!" print-error disarm err print "^/^/"][print "...DONE"]
					]
				]
			]
		]
	]
]