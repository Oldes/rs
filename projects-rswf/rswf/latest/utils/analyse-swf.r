rebol [
	title: "SWF analyse"
	author: "Oldes"
	e-mail: oliva.david@seznam.cz
]

do %exam-swf.r
;graphfx: context load %/d/library/graph-fx2.r

streams-buffer: make block! 5
swfs-buffer: make block! 5

isRelative?: func[url [file! url! string!]][
	not parse url [some ["http://" | "ftp://" | "https://" | "file:" | "res:"] to end]
]
analyse-swf: func[
	/file swf-file [file! url!]
	/quiet
	/local total-time timdiff t err i frame-bytes frame-count
][
	swf: make object! [
		path: none
		header: make object! [
			version: none
			length: none
			frame-size: make block! []
			frame-rate: none
			frame-count: none
		]
		rect: none
		times-by-frames: make block! 100
		total-time: 0:0:0
		bytes-by-frames: make block! 100
	]
	if not swf-file [
		swf-file: either empty? swf-file: ask "SWF file:" [%new.swf][
			either "http://" = copy/part swf-file 7 [to-url swf-file][to-file swf-file]
		]
	]
	swf/path: either found? i: find/last/tail swf-file #"/" [
		copy/part swf-file i
	][	%./ ]
	time: now/time/precise
	swf-stream: open/direct/read/binary swf-file
	if error? err: try [
		parse-swf-header
		;-------- parsing the swf-tags --------
		frame-bytes: 0
		frame-count: 0
		foreach-stream-tag [
			frame-bytes: frame-bytes + length + rh-length
			switch tag [
				1 [;showFrame
					frame-count: frame-count + 1
					if not quiet [
						print [frame-count "=" frame-bytes]
					]
					insert tail swf/bytes-by-frames frame-bytes
					insert tail swf/times-by-frames timdiff: now/time/precise - time
					swf/total-time: swf/total-time + timdiff
					time: now/time/precise
					frame-bytes: 0
				]
				57 [;ImportAssets
					tag-bin: data
					assets: parse-Assets/Import
					insert streams-buffer reduce [swf-stream swf]
					analyse-swf/file/quiet either isRelative? first assets [
						join swf/path first assets
					][	first assets ]
					swf-stream: first streams-buffer 
					remove streams-buffer
					frame-bytes: frame-bytes + swf/header/length
					swf: first streams-buffer 
					remove streams-buffer
				]
			]
		]
	][
		close swf-stream
		throw err
	]
	if not quiet [
		probe swf
		;view center-face ;graphfx/graph reduce [swf/bytes-by-frames] [size 320x240 column 10x10]
		;layout [
		;	graph 150x240 (reduce [swf/bytes-by-frames])
		;]
	]
	close swf-stream
]



;go/swf/init do %analyse-swf.r
