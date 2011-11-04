REBOL [
    Title: "Swf-parser"
    Date: 16-Sep-2007/15:31:26+2:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "David Oliva (commercial)"
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
    Email: oliva.david@seznam.cz
    require: [
		rs-project 'r2-forward
    	rs-project 'stream-io 'write
    	rs-project 'ajoin
    	rs-project 'binary-conversions
	]
	preprocess: true
]


swf-parser: make stream-io [
	tagId: tagLength: tagData: upd: none
	store?: false
	replaced-ids: make block! 200
	imported-names: make block! 200
	imported-labels: make block! 50
	imported-frames: 0
	wasDefineSceneAndFrameLabelDataTag: false
	export-dir: none
	
	write-tag: func[
		"Writes the SWF-TAG to outBuffer"
			id [integer!]	"Tag ID"
			data [binary!]	"Tag data block"
			/local len
	][
		;print ["WRITETAG" id]
			either any [
				62 < len: length? data
				not none? find [2 20 34 36 37 48] id
			] [
				;print ["Long tag:" len id]
				writeUI16 (63 or (id * 64))
				writeUI32 len
				writeBytes data
			][
				;print ["Short tag:" len id]
				writeUI16 (len or (id * 64))
				writeBytes data
			]
	]

	parse-swf-header: func[/local sig tmp][
		sig: readBytes 3
		case [
			sig = #{465753} [
				swf/header/version: readUI8
				readUI32 ;length
			]
			sig = #{435753} [
				;print ["This file is compressed Flash MX file!"]
				swf/header/version: readUI8
				if error? set/any 'err try [inBuffer:  as-binary decompress skip (join inBuffer (readBytes 4)) 4][
					clear tmp
					recycle
					print "Cannot decompress the data:("
					probe disarm err
					halt
				]
				;print ["3:" stats]
				;print length? inBuffer
			]
			true [
				print "Illegal swf header!"
				halt
			]
		]
		swf/header/frame-size: readRect
		byteAlign
		swf/header/frame-rate:  to integer! readBytes 2
		swf/header/frame-count: readUI16
	]
	
	open-swf-stream: func[swf-file [file! url! string!] "the SWF source file" /local f][
		if string? swf-file [swf-file: to-rebol-file swf-file]
		unless swf-file [
			swf-file: either empty? swf-file: ask "SWF file:" [%new.swf][
				either "http://" = copy/part swf-file 7 [to-url swf-file][to-file swf-file]
			]
		]
		unless exists? swf-file [
			f: join swf-file ".swf"
			either exists? f [swf-file: f][print ["Cannot found the file" swf-file "!"]]
		]
		swf: make object! [
			file:   swf-file
			header: make object! [version: frame-size: frame-rate: frame-count: none]
			data:   copy []
		]
		;open/direct/read/binary swf-file
		read/binary swf-file
	]
	
	foreach-swf-tag: func[ action /local tagAndLength][
		bind action 'tagAndLength
		while [not tail? inBuffer][
			;probe copy/part inBuffer 10
			tagAndLength: readUI16
			tagId:     to integer! ((65472 and tagAndLength) / (2 ** 6))
			tagLength: tagAndLength and 63
			if tagLength = 63 [tagLength: readUI32]
			tagData: either tagLength > 0 [readBytes tagLength][make binary! 0 ]
			;print ["TAG:" tagId tagLength tagData]
			do action
		]
	]
	
	set 'extract-swf-tags func[
		"Returns block of specified SWF tags"
		swf-file [file! url! string!] "the SWF source file"
		tagids [block!] "Tag IDs to extract"
		/local result
	][
		result: copy []
		setStreamBuffer swf-stream: open-swf-stream swf-file
		if error? set/any 'err try [
			;prin "Extractings SWF tags... "
			parse-swf-header
			;print "-------------------------"
			;probe swf/header
			foreach-swf-tag [
				if find tagids tagId [
					;print [tagId tagLength tagAndLength]
					repend result [tagId tagData]
				]
			]
		][
			throw err
		]
		result
	]
	

	readSWFTags: func[swfTagsStream /local storeBuffer results onlyTagIds][
		;print "=====>"
		storeBuffer: reduce [inBuffer availableBits bitBuffer]
		setStreamBuffer swfTagsStream
		results: copy []
		onlyTagIds: swf-tag-parser/onlyTagIds
		swf-tag-parser/spriteLevel: swf-tag-parser/spriteLevel + 1
		foreach-swf-tag [
			tagId
			if any [
				none? onlyTagIds
				find  onlyTagIds tagId
			][
			 	insert/only tail results reduce [
					tagId
					parse-swf-tag tagId tagData
				]
			]
		]
		inBuffer:  storeBuffer/1
		availableBits: storeBuffer/2
		bitBuffer: storeBuffer/3
		clear storeBuffer
		swf-tag-parser/spriteLevel: swf-tag-parser/spriteLevel - 1
		
		;print "<====="
		results

	]

	importSWFTags: func[swfTagsStream /local storeBuffer results importedResult][
		;print "=====>"
		;print index? inBuffer
		importedResult: make binary! 20000
		storeBuffer: reduce [inBuffer availableBits bitBuffer]
		setStreamBuffer swfTagsStream
		swf-tag-parser/spriteLevel: swf-tag-parser/spriteLevel + 1
		while [not tail? inBuffer][
			tagStart: index? inBuffer
			tagAndLength: readUI16
			tagId:     to integer! ((65472 and tagAndLength) / (2 ** 6))
			;print ["????????" tagId]
			tagLength: tagAndLength and 63
			if tagLength = 63 [tagLength: readUI32]
			tagData: either tagLength > 0 [readBytes tagLength][make binary! 0 ]
			insert tail importedResult import-swf-tag tagId tagData
		]
		inBuffer:  storeBuffer/1
		availableBits: storeBuffer/2
		bitBuffer: storeBuffer/3
		;print index? inBuffer
		clear storeBuffer
		swf-tag-parser/spriteLevel: swf-tag-parser/spriteLevel - 1
		;print "<====="
		importedResult
	]
	
	rescaleSWFTags: func[swfTagsStream /local storeBuffer results rescaledResult][
		;print "=====>"
		;print index? inBuffer
		rescaledResult: make binary! 20000
		storeBuffer: reduce [inBuffer availableBits bitBuffer  head swf-tag-parser/outBuffer ]
		
		
		setStreamBuffer swfTagsStream
		;probe head swf-tag-parser/outBuffer
		swf-tag-parser/outSetStreamBuffer copy #{}
		
		swf-tag-parser/spriteLevel: swf-tag-parser/spriteLevel + 1
		while [not tail? inBuffer][
			tagStart: index? inBuffer
			tagAndLength: readUI16
			tagId:     to integer! ((65472 and tagAndLength) / (2 ** 6))
			;print ["????????" tagId]
			tagLength: tagAndLength and 63
			if tagLength = 63 [tagLength: readUI32]
			tagData: either tagLength > 0 [readBytes tagLength][make binary! 0 ]
			insert tail rescaledResult rescale-swf-tag tagId tagData
		]
		inBuffer:      storeBuffer/1
		availableBits: storeBuffer/2
		bitBuffer:     storeBuffer/3
		swf-tag-parser/outBuffer:   tail  storeBuffer/4
		
		;probe head swf-tag-parser/outBuffer
		;print index? inBuffer
		clear storeBuffer
		swf-tag-parser/spriteLevel: swf-tag-parser/spriteLevel - 1
		;print "<====="
		rescaledResult
	]

	set 'exam-swf func[
		"Examines SWF file structure" [catch]
		/file swf-file [file! url! string!] "the SWF source file"
		/quiet "No visible output"
		/into out-file [file!]
		/store "If you want to store parsed tags in the swf/data block"
		/only onlyTagIds [block!]
		/parseActions pActions [block! hash!]
		/local err sysprint sysprin action
	][
		if all [file string? swf-file][swf-file: to-rebol-file swf-file]
		store?: store
		setStreamBuffer open-swf-stream swf-file	
		
		if error? set/any 'err try [
			prin "Searching the binary file... "
			parse-swf-header
			print "-------------------------"
			probe swf/header
			print stats
			swf-tag-parser/verbal?: not quiet ;all [not quiet not into]
			swf-tag-parser/output-file: either into [out-file: open/new/write out-file][none]
			swf-tag-parser/parseActions: either parseActions [pActions][swfTagParseActions]
			swf-tag-parser/onlyTagIds: onlyTagIds
			swf-tag-parser/swfVersion: swf/header/version
			;readSWFTags
			foreach-swf-tag [
				if any [
					none? onlyTagIds
					find  onlyTagIds tagId
				][
				 	if store [ repend/only swf/data [tagId tagData] ]
				 	;print ["----------" tagId]
					;probe tagData
				 	parse-swf-tag tagId tagData
				]
			]
		][
			clear head inBuffer
			error? try [close swf-tag-parser/output-file]
			recycle
			throw err
		]
		clear head inBuffer inBuffer: none
		recycle
		error? try [close out-file]
		swf
	]
	
	set 'import-swf func[
		"Reads SWF file, changes all IDs in the file not to conflict with given existing IDs and returns the new binary (without header)"
		[catch] swf-file [file! url! string!] "the SWF source file"
		used-tag-ids [block!]
		init-depth [integer!]
		/except except-tag-ids [block!]
		/local importedSWF tagStart tagAndLength tagLength importedTags importedDict importedResult importedLabels importedFrames
	][
		;probe used-tag-ids
		clear replaced-ids
		clear imported-names
		clear imported-labels
		importedFrames: 0
		importedTags:    make block!  2000
		importedDict:    make binary! 1000000
		importedCtrl:    make binary! 200000
		importedResult:  copy []
		
		tagsStartIndex: 0
		if all [string? swf-file][swf-file: to-rebol-file swf-file]
		setStreamBuffer open-swf-stream swf-file	
		
		if error? set/any 'err try [
			parse-swf-header
			
			;swf-tag-parser/verbal?: not quiet ;all [not quiet not into]
			swf-tag-parser/parseActions: swfTagImportActions
			;swf-tag-parser/onlyTagIds: onlyTagIds
			swf-tag-parser/swfVersion: swf/header/version
			swf-tag-parser/used-ids: used-tag-ids
			swf-tag-parser/init-depth: init-depth

			
			tagsStartIndex: index? inBuffer

			while [not tail? inBuffer][
				tagStart: index? inBuffer
				tagAndLength: readUI16
				tagId:     to integer! ((65472 and tagAndLength) / 64) ;64=2**6
				tagLength: tagAndLength and 63
				if tagLength = 63 [tagLength: readUI32]
				tagData: either tagLength > 0 [readBytes tagLength][make binary! 0 ]
				;print [">" tagId ">>>" index? tagData length? tagData  checksum tagData]
				;insert/only tail importedTags reduce [tagId tagData]
				case [
					find [65 69 77 9 ] tagId [];do not import ScriptLimits,FileAttributes,metaData, setBackgroundColor, DefineSceneAndFrameLabelData
					find [0 1 4 5 12 15 18 19 26 28 43 45 59 70 76 82 89] tagId [;controlTags
						insert tail importedCtrl import-swf-tag tagId tagData
						if tagId = 1 [
							repend importedResult [copy importedDict copy importedCtrl]
							clear importedCtrl
							clear importedDict
							importedFrames: importedFrames + 1
						]
					]
					tagId = 86 [
						unless wasDefineSceneAndFrameLabelDataTag [
							insert tail importedDict import-swf-tag tagId tagData
							wasDefineSceneAndFrameLabelDataTag: true
						]
					]
					true [
						insert tail importedDict import-swf-tag tagId tagData
					]
				]
				
				;print ["<" r/1 "<<<" index? r/2 length? r/2 checksum r/2]
			]
			repend importedResult [copy importedDict copy importedCtrl]
			clear importedCtrl
			clear importedDict
		][
			clear importedCtrl
			clear importedDict
			clear importedResult
			clear head inBuffer
			recycle
			throw err
		]
		imported-frames: importedFrames
	;	probe importedResult
		recycle
		print ["FRAMES:" imported-frames]
		reduce [
			;skip head inBuffer tagsStartIndex 
			;importedTags
			importedResult
			swf-tag-parser/last-depth
			imported-names
			;swf-tag-parser/used-ids
			imported-labels
			imported-frames
		]
	]
	
	set 'remove-blurs-from-swf func[
		"Reads SWF file, removes all blur effects and returns the new binary (without header)"
		[catch] swf-file [file! url! string!] "the SWF source file"
		/into out-file [file! url!]
		/local importedSWF tagStart tagAndLength tagLength importedDict importedResult importedLabels outBuffer
	][
		;probe used-tag-ids
		clear replaced-ids
		clear imported-names
		clear imported-labels
		importedDict:    make binary! 1000000
		importedCtrl:    make binary! 200000
		importedResult:  copy #{}
		
		tagsStartIndex: 0
		if all [string? swf-file][swf-file: to-rebol-file swf-file]
		setStreamBuffer open-swf-stream swf-file	
		
		if error? set/any 'err try [
			parse-swf-header
			
			;swf-tag-parser/verbal?: not quiet ;all [not quiet not into]
			swf-tag-parser/parseActions: swfTagImportActions
			;swf-tag-parser/onlyTagIds: onlyTagIds
			swf-tag-parser/swfVersion: swf/header/version
			swf-tag-parser/used-ids: copy []
			swf-tag-parser/init-depth: 0

			
			tagsStartIndex: index? inBuffer

			while [not tail? inBuffer][
				tagStart: index? inBuffer
				tagAndLength: readUI16
				tagId:     to integer! ((65472 and tagAndLength) / 64) ;64=2**6
				tagLength: tagAndLength and 63
				if tagLength = 63 [tagLength: readUI32]
				tagData: either tagLength > 0 [readBytes tagLength][make binary! 0 ]
				;print [">" tagId ">>>" index? tagData length? tagData  checksum tagData]
				;insert/only tail importedTags reduce [tagId tagData]
				case [
					;find [65 69 77 9 ] tagId [];do not import ScriptLimits,FileAttributes,metaData, setBackgroundColor, DefineSceneAndFrameLabelData
					find [0 1 4 5 12 15 18 19 26 28 43 45 59 70 76 82 89] tagId [;controlTags
						insert tail importedCtrl import-swf-tag tagId tagData
						if tagId = 1 [
							insert tail importedResult importedDict
							insert tail importedResult importedCtrl
							clear importedCtrl
							clear importedDict
						]
					]
					tagId = 86 [
						unless wasDefineSceneAndFrameLabelDataTag [
							insert tail importedDict import-swf-tag tagId tagData
							wasDefineSceneAndFrameLabelDataTag: true
						]
					]
					true [
						insert tail importedDict import-swf-tag tagId tagData
					]
				]
				
				;print ["<" r/1 "<<<" index? r/2 length? r/2 checksum r/2]
			]
			insert tail importedResult importedDict
			insert tail importedResult importedCtrl
			clear importedCtrl
			clear importedDict
		][
			clear importedCtrl
			clear importedDict
			clear importedResult
			clear head inBuffer
			recycle
			throw err
		]
		outBuffer: create-swf/rate/version/compressed
				as-pair (SWF/HEADER/FRAME-SIZE/2 / 20) (SWF/HEADER/FRAME-SIZE/4 / 20)
				importedResult
				swf/header/frame-rate
				swf/header/version
				true

		if into [write/binary out-file outBuffer]

		;clear head swfTags
		recycle

		outBuffer
	]
	
	set 'swf-to-rswf func[
		"Converts SWF into RSWF" [catch]
		swf-file [file! url! string!] "the SWF source file"
		/into out-file [file!]
		/local err sysprint sysprin action names-to-ids swfDir swfName
	][
		if string? swf-file [swf-file: to-rebol-file swf-file]
		
		swfName: copy find/last/tail swf-file #"/"
		unless swfDir: export-dir [
			swfDir: either url? swf-file [
				what-dir
			][	first split-path swf-file]
		]
			
		swfDir: rejoin [swfDir swfName %_export/]
		if not exists? swfDir [make-dir/deep swfDir]
		
		setStreamBuffer open-swf-stream swf-file	
		
		if error? set/any 'err try [
			prin "Searching the binary file... "
			parse-swf-header
			print "-------------------------"
			probe swf/header
			print stats

			swf-tag-parser/names-to-ids: copy []
			swf-tag-parser/JPEGTables: none
			swf-tag-parser/swfDir:  swfDir
			swf-tag-parser/swfName: swfName
			swf-tag-parser/output-file: either into [out-file: open/new/write out-file][none]
			swf-tag-parser/parseActions: swfTagToRSWFActions
			swf-tag-parser/swfVersion: swf/header/version
			;readSWFTags
			foreach-swf-tag [
				;probe reduce [tagId tagData]
				swf-tag-to-rswf tagId tagData
			]
		][
			clear head inBuffer
			error? try [close swf-tag-parser/output-file]
			recycle
			throw err
		]
		clear head inBuffer inBuffer: none
		recycle
		error? try [close out-file]
		swf
	]
	
	set 'swf-optimize func[
		"Optimize SWF file" ;[catch]
		swf-file [file! url! string!] "the SWF source file"
		/into out-file [file!]
		/local origBytes noBBids err sysprint sysprin action names-to-ids swfDir swfName result swfTags ext bmp crops w h x y md5 noCrops bin1 bin2 shapeStyles
	][
		if string? swf-file [swf-file: to-rebol-file swf-file]
		swfName: copy find/last/tail swf-file #"/"
		unless swfDir: export-dir [
			swfDir: either url? swf-file [
				what-dir
			][	first split-path swf-file]
		]
			
		swfDir: rejoin [swfDir swfName %_export/]
		if not exists? swfDir [make-dir/deep swfDir]
		
		setStreamBuffer open-swf-stream swf-file

		clearOutBuffer
		
		frames: 0
		swfTags:    copy []
		swfBitmaps: copy []
		swfBitmapFills: copy []
		noCrops: copy []
		shapeStyles: copy []

		noBBids: copy []
		origBytes: 0
		
		if error? set/any 'err try [
			prin "Searching the binary file... "
			parse-swf-header
			origBytes: length? inBuffer
			print "-------------------------"
			probe swf/header
			print stats

			swf-tag-parser/names-to-ids: copy []
			swf-tag-parser/JPEGTables: none
			swf-tag-parser/swfDir:  swfDir
			swf-tag-parser/swfName: swfName
			;swf-tag-parser/output-file: either into [out-file: open/new/write out-file][none]
			swf-tag-parser/parseActions: swfTagOptimizeActions
			swf-tag-parser/swfVersion: swf/header/version
			;readSWFTags
			
			foreach-swf-tag [
				;probe reduce [tagId tagData]
				;probe tagId
				repend swfTags [tagId tagData]
				switch tagId [
					6 20 21 36 [
						;== bitmaps
						probe md5: enbase/base checksum/method skip tagData 2 'md5 16
						result: swf-tag-optimize tagId tagData
						swf-tag-parser/export-image-tag tagId md5 result
						append result md5
						change/only back tail swfTags copy/deep result
						append swfBitmaps result/1
						repend/only swfBitmaps head change result tagId
					]
					35 [
						;== bitmaps
						probe md5: enbase/base checksum/method skip tagData 2 'md5 16
						result: swf-tag-optimize tagId tagData
						swf-tag-parser/export-image-tag tagId md5 result
						swf-tag-parser/export-image-tag/alpha tagId md5 result
						append result md5
						change/only back tail swfTags copy/deep result
						append swfBitmaps result/1
						repend/only swfBitmaps head change result tagId
					]
					2 22 32 67 83 [
						if result: swf-tag-optimize tagId tagData [
							append swfBitmapFills result/1
							;ask ""
							append append shapeStyles result/2 result/3
						]
					]
					
					1 [frames: frames + 1]
					56 [
						print ["EXPORT"]
						foreach [id name] swf-tag-optimize tagId tagData [
							 ;if experted name starts with "noBB", than BB optimization is not used
							if find/part name #{6E6F4242} 4 [
								append noBBids id
								;ask reform ["noBB:" id as-string name] 
							]
						]
						;probe noBBids
					]
				]
				
			]
		][
			clear head inBuffer
			clear head swfTags
			error? try [close swf-tag-parser/output-file]
			recycle
			throw err
		]
		print ["BITMAPS:" (length? swfBitmaps) / 2]
		
		print ["BITMAP FILLS" mold swfBitmapFills]
		crops: copy []
		
		mat: func[x y a b c d tx ty /local nx ny][
			nx: (x * a) + (y * c) + tx
			ny: (x * b) + (y * d) + ty
			reduce [nx ny]
		]

		

		xxx: copy []
		foreach [id minx miny maxx maxy sx sy rx ry tx ty] swfBitmapFills [
		;	print ["???" id minx miny maxx maxy sx sy rx ry tx ty]
			unless find noCrops id [
				unless rx [rx: 0]
				unless ry [ry: 0]
				minx: minx / 20
				miny: miny / 20
				maxx: maxx / 20
				maxy: maxy / 20
				a: sx / 20
				c: ry / 20
				b: rx / 20
				d: sy / 20
				tx: tx / 20
				ty: ty / 20

				tmp: (a * d) - (b * c)
				ai:   d / tmp
				bi: - b / tmp
				ci: - c / tmp
				di:   a / tmp
				txi: ((c * ty) - (d * tx)) / tmp
				tyi: -((a * ty) - (b * tx)) / tmp
				
				xA: (minx * ai) + (miny * ci) + txi
				yA: (minx * bi) + (miny * di) + tyi
				
				xB: (maxx * ai) + (miny * ci) + txi
				yB: (maxx * bi) + (miny * di) + tyi
				
				xC: (maxx * ai) + (maxy * ci) + txi
				yC: (maxx * bi) + (maxy * di) + tyi
				
				xD: (minx * ai) + (maxy * ci) + txi
				yD: (minx * bi) + (maxy * di) + tyi
				
			;	print "============="
			;	print [xA yA]
			;	print [xB yB]
			;	print [xC yC]
			;	print [xD yD]
				
				nminx: to-integer min xD min xC min xA xB
				nmaxx: to-integer max xD max xC max xA xB
				nminy: to-integer min yD min yC min yA yB
				nmaxy: to-integer max yD max yC max yA yB
				
				
				
				;print [nminx nminy nmaxx nmaxy]
				x: xc: round/floor nminx
				y: yc: round/floor nminy
				w: round/ceiling(nmaxx - x)
				h: round/ceiling(nmaxy - y)
				
				
				if bmp: select swfBitmaps id [
					imgsz: swf-tag-parser/get-image-size-from-tagData bmp
					if xc < 0 [xc: imgsz/1 + (xc // imgsz/1)]
					if yc < 0 [yc: imgsz/2 + (yc // imgsz/2)]
					if xc > imgsz/1 [xc: xc // imgsz/1]
					if yc > imgsz/2 [yc: yc // imgsz/2]
					if xc > 0 [x: x - 1 xc: xc - 1 w: w + 1]
					if yc > 0 [y: y - 1 yc: yc - 1 h: h + 1]
					if (xc + w) < imgsz/1 [w: w + 1]
					if (yc + h) < imgsz/2 [h: h + 1]
					;print [xc yc w h]
				]
				
				print ["crop:" x y w h tab "===" tab nminx nminy nmaxx nmaxy]
;ask ""
			;	print ["===" x y w h sx sy rx ry tx ty]
			
				either tmp: select xxx id [
					repend tmp [xc yc (xc + w) (yc + h) x y]
				][
					append xxx id
					repend/only xxx [xc yc xc + w yc + h x y]
				]
			
				either none? tmp: select crops id [
					append crops id
					repend/only crops [xc yc xc + w yc + h x y]
				][
					change tmp reduce [
						min tmp/1 xc
						min tmp/2 yc
						max tmp/3 (xc + w)
						max tmp/4 (yc + h)
						min tmp/5 x
						min tmp/6 y
					]
				]
				if error? try [md5: last select swfBitmaps id][md5: none]
				print ["BMP" id md5 w h as-pair x y as-pair x + w y + h]
			]
		]
		print "============CROP=============="
		probe xxx
		save %crops.rb xxx
		
		
		comment {		
				
		foreach [id szs] xxx [
			crops: copy []

			foreach [xc1 yc1 xc2 yc2 x y] szs [
				joined?: false
				
				while [not tail? crops] [
					;probe crops
					set [cx1 cy1 cx2 cy2 cx cy] crops
					print ["?xc" xc1 yc1 xc2 yc2 x y]
					print ["?cx" cx1 cy1 cx2 cy2 cx cy]
					print ["cx1 <= xc1" cx1 <= xc1]
					print ["cx2 <= xc2" cx2 <= xc2]
					print ["cy1 <= yc1" cy1 <= yc1]
					print ["cy2 <= yc2" cy2 <= yc2]
					if any [
						all [
							cx1 <= xc1
							cx2 >= xc1
							cy1 <= yc1
							cy2 >= yc1
						]
						all [
							cx1 <= xc2
							cx2 >= xc2
							cy1 <= yc1
							cy2 >= yc1
						]
						all [
							cx1 <= xc1
							cx2 >= xc1
							cy1 <= yc2
							cy2 >= yc2
						]
						all [
							cx1 <= xc2
							cx2 >= xc2
							cy1 <= yc2
							cy2 >= yc2
						]
						
						all [
							xc1 <= cx1
							xc2 >= cx1
							yc1 <= cy1
							yc2 >= cy1
						]
						all [
							xc1 <= cx1
							xc2 >= cx1
							yc1 <= cy2
							yc2 >= cy2
						]
						all [
							xc1 <= cx2
							xc2 >= cx2
							yc1 <= cy1
							yc2 >= cy1
						]
						all [
							xc1 <= cx2
							xc2 >= cx2
							yc1 <= cy2
							yc2 >= cy2
						]
					] [
						;ask ""
						change/part crops reduce [
							min cx1 xc1
							min cy1 yc1
							max cx2 xc2
							max cy2 yc2
							min cx  x
							min cy  y
						] 6
						joined?: true
						break
					] 
					crops: skip crops 6
				]
				crops: head crops
				unless joined? [
					repend crops [xc1 yc1 xc2 yc2 x y]
				]
			]
			probe crops
			clear szs
			insert szs crops
		]
		probe xxx
				
		cache-bmp-sizes: copy []
		foreach [id szs] xxx [
			if bmp: select swfBitmaps id [
				print ["crop bitmap type:" bmp/1 last bmp]
				ext: either find [20 36] bmp/1 [%.png][%.jpg]
				size: swf-tag-parser/get-image-size-from-tagData bmp ;get-image-size rejoin [swfDir %tag35  %_ last bmp %.jpg]
				
				;test range for all szs
				in-range?: true
				foreach [xc1 yc1 xc2 yc2 x y] szs [
					if any [
						xc1 < 0
						yc1 < 0
						xc2 > size/x
						yc2 > size/y
					][
						in-range?: false
						append noCrops id
						print ["!! Crop out of bounds!" xc1 yc1 xc2 yc2 "with size:" size]
						clear szs
						break
					]
				]
				if in-range? [
					repend cache-bmp-sizes [id size] 
					probe szs
					foreach [xc1 yc1 xc2 yc2 x y] szs [
						switch bmp/1 [
							35 [
								
								unless crop-images
									reduce [
										rejoin [swfDir %tag35  %_ last bmp %.jpg]
										rejoin [swfDir %tag35  %_ last bmp %.png]
									]
									xc1
									yc1
									xc2 - xc1
									yc2 - yc1
								[
									print ["!!!" id]
									append noCrops id
								]
									
							]
							6 20 21 36 [
								unless crop-images
									reduce [
										rejoin [swfDir %tag bmp/1  %_ last bmp ext]
									]
									xc1
									yc1
									xc2 - xc1
									yc2 - yc1
								[
									print ["!!!" id]
									append noCrops id
								]
							]
						]
					]
				]
				
			]
		]	
		probe xxx
		ask "croping done"
		}	
		;comment {
				foreach [id sizes] crops [
					if bmp: select swfBitmaps id [
						print ["crop bitmap type:" bmp/1 last bmp]
						probe sizes
						;change sizes reduce [
						;	round/floor (sizes/1 / 20)
						;	round/floor (sizes/2 / 20) 
						;	round/ceiling  (sizes/3 / 20)
						;	round/ceiling  (sizes/4 / 20)
						;]
						ext: either find [20 36] bmp/1 [%.png][%.jpg]
						switch bmp/1 [
							35 [
								
								unless crop-images
									reduce [
										rejoin [swfDir %tag35  %_ last bmp %.jpg]
										rejoin [swfDir %tag35  %_ last bmp %.png]
									]
									sizes/1
									sizes/2
									sizes/3 - sizes/1
									sizes/4 - sizes/2
								[
									print ["!!!" id]
									append noCrops id
								]
									
							]
							6 20 21 36 [
								unless crop-images
									reduce [
										rejoin [swfDir %tag bmp/1  %_ last bmp ext]
									]
									sizes/1
									sizes/2
									sizes/3 - sizes/1
									sizes/4 - sizes/2
								[
									print ["!!!" id]
									append noCrops id
								]
							]
						]
					]
				]


		;}
		;probe crops: xxx

		print "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
		probe noCrops: unique noCrops
		probe crops
		foreach id sort/reverse noCrops [
			print ["noCrop:" id]
			;probe select swfBitmaps id
			if tmp: find crops id [
				print ["noCrop:" mold tmp/2]
				remove/part tmp 2
			]
		]
		probe crops
		
		;ask ""
		clear head inBuffer inBuffer: none
		
		swf-tag-parser/parseActions: swfTagOptimizeActions2
		swf-tag-parser/use-BB-optimization?: true
		swf-tag-parser/data: context compose/only [
			crops:     (crops)
			shapeStyles: (shapeStyles)
			noBBids:   (noBBids)
			shapeReduction: 0
		]
		
		print ["noBBids:" mold noBBids]
		;ask ""
		
		rob-parts: [
		;	194x234	["hlava_zboku1"   613x52	"4C1447FA88E3FF7948EE17E488504B15"]
		;	193x210	["hlava_zepredu"  584x80	"44A588C3DFAE46757ABB53484BBEF4CE"]
		;	190x202	["hlava_zezadu"   597x82	"CA72BBAAA141E4E8FBADBC77BC9F5BAF"]
		;	97x50	["rob_clanek1"    412x446	"C8A1BBD44C99562860B7F9B373AE4361"]
		;	95x50	["rob_clanek2"    416x462	"4E979CAAC3A1286F8863E3A731ECBCFE"]
		;	91x48	["rob_clanek3"    414x483	"3F789582ED9EB4E0132F0B2A2B3218E2"]
		;	94x52	["rob_clanek4"    414x520	"5666B12A1AD994D53422AD7FBF6FD210"]
		;	101x161	["rob_nohy"       410x516	"7C185BFEF392BBFEE91D8BA958D94E87"]
		;	153x56	["rob_ramena"     382x429	"5B752891AEF5639FAF4D7E5A9BE1288B"]
		;	156x80	["rob_ruka"       176x445	"559FF962C35C61AE3098544A6ACCBFB3"]
		;	39x38	["rob_ramena2"    496x440	"5B752891AEF5639FAF4D7E5A9BE1288B"]
			"4C1447FA88E3FF7948EE17E488504B15" ["hlava_zboku1"   613x52]
				"833CDDDC6E0E92A4CEB86DE946CE6D9C" ["hlava_zboku1"   613x52]
			"44A588C3DFAE46757ABB53484BBEF4CE" ["hlava_zepredu"  584x80]
				"83CAA93D0452AA443BA2C49F3C985DE0" ["hlava_zepredu"  584x80]
			"CA72BBAAA141E4E8FBADBC77BC9F5BAF" ["hlava_zezadu"   597x82]
				"C9DD1E9CD54DDF0703C1F6C90172496E" ["hlava_zezadu"   597x82]
			"C8A1BBD44C99562860B7F9B373AE4361"  ["rob_clanek1"  412x446]
				"96304CC31FFD00FC38CB79E329785585" ["rob_clanek1"  412x446]
			"4E979CAAC3A1286F8863E3A731ECBCFE"  ["rob_clanek2"  416x462]
				"18E09D32E378101A68FA52B18E1B5078" ["rob_clanek2"  416x462]
			"3F789582ED9EB4E0132F0B2A2B3218E2"  ["rob_clanek3"  414x483]
				"D347F7A1183289093C48AA56FFECE305" ["rob_clanek3"  414x483]
			"5666B12A1AD994D53422AD7FBF6FD210"  ["rob_clanek4"  414x520]
				"779DE1ADBC02C33F135CFCA332E9B38A" ["rob_clanek4"  414x520]
			"7C185BFEF392BBFEE91D8BA958D94E87"  ["rob_nohy" 410x516]
				"8568E78B9DF61D95096CD66DCBC0D5E8" ["rob_nohy" 410x516]
			;"5B752891AEF5639FAF4D7E5A9BE1288B"  ["rob_ramena"   382x429]
			"559FF962C35C61AE3098544A6ACCBFB3"  ["rob_ruka" 176x445]
				"C869CF3DAE5FA462133B4D9A7F8DE032" ["rob_ruka" 176x445]

			
		]
		
		rob-parts: [] ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		
		foreach [Id tagData] swfTags [
			tagId: id
			;print [tagId type? tagData]

			switch/default tagId [
				21 [
					either tmp: select crops tagData/1 [
						;print ["cropbmp" tagId tagData/1 mold tmp]
						;foreach [xc1 yc1 xc2 yc2 x y] tmp [
						
						write-tag 21 abin [
							int-to-ui16 tagData/1
							read/binary rejoin [swfDir %tag21_ tagData/3 %_crop_ tmp/1 %x tmp/2 %_ (tmp/3 - tmp/1) %x (tmp/4 - tmp/2) %.jpg]
						]
					][
						write-tag 21 abin [
							int-to-ui16 tagData/1
							tagData/2
						]
					]
				]
				35 [
					either tmp: select crops tagData/1 [
						;tmpId: as-pair (tmp/3 - tmp/1) (tmp/4 - tmp/2)
						;probe select rob-parts tmpId
						;print ["====IMG" swf-file tagData/1 tab last tagData tab tmpId]
						

						either tmp2: select rob-parts last tagData [
							either find swf-file %rob-include [
								print ["Adding ExportAssets for" tmp2 as-pair tmp/1 tmp/2 mold tmp]
								file: rejoin [swfDir %tag35_ last tagData %_crop_ tmp/1 %x tmp/2 %_ (tmp/3 - tmp/1) %x (tmp/4 - tmp/2)]
								bin1: read/binary join file %.jpg
								bin2: load join file %.png
								write-tag 35 abin [
									int-to-ui16 tagData/1
									int-to-ui32 length? bin1
									bin1
									head head remove/part tail compress bin2/alpha -4
								]
								
								write-tag 56 abin [
									#{0100}
									int-to-ui16 tagData/1
									tmp2/1
									#{00}
								]
							][
								print ["Adding ImportAssets for" tmp2 "as" tagData/1 as-pair tmp/1  tmp/2]
								change/part skip tmp 4 reduce [tmp2/2/x tmp2/2/y] 2
								;ask ""
								write-tag 71 abin [
									as-binary "00/11111100.011"
									#{00 0100 0100}
									int-to-ui16 tagData/1
									tmp2/1
									#{00}
								]
							]
						][
							;print ["cropbmp" tagId tagData/1 mold tmp]
							file: rejoin [swfDir %tag35_ last tagData %_crop_ tmp/1 %x tmp/2 %_ (tmp/3 - tmp/1) %x (tmp/4 - tmp/2)]
							bin1: read/binary join file %.jpg
							bin2: load join file %.png
							write-tag 35 abin [
								int-to-ui16 tagData/1
								int-to-ui32 length? bin1
								bin1
								head head remove/part tail compress bin2/alpha -4
							]
						]
							
					][
						write-tag 35 abin [
							int-to-ui16 tagData/1
							int-to-ui32 length? tagData/2
							tagData/2
							tagData/3
							;head head remove/part tail compress tagData/3 -4
						]
					]
						
				]
				36 [
					either tmp: select crops tagData/1 [
						;print ["cropbmp" tagId tagData/1 mold tmp]
						write-tag 36 abin [
							int-to-ui16 tagData/1
							ImageCore/ARGB2BLL ImageCore/load rejoin [swfDir %tag36_ last tagData %_crop_ tmp/1 %x tmp/2 %_ (tmp/3 - tmp/1) %x (tmp/4 - tmp/2) %.png]
						]
					][
						write-tag 36 abin [
							int-to-ui16 tagData/1
							ImageCore/ARGB2BLL ImageCore/load rejoin [swfDir %tag36_ last tagData  %.png]
						]
					]
				]
				20 [
					either tmp: select crops tagData/1 [
						;print ["cropbmp" tagId tagData/1 mold tmp]
						write-tag 20 abin [
							int-to-ui16 tagData/1
							ImageCore/ARGB2BLL ImageCore/load rejoin [swfDir %tag20_ last tagData %_crop_ tmp/1 %x tmp/2 %_ (tmp/3 - tmp/1) %x (tmp/4 - tmp/2) %.png]
						]
					][
						write-tag 20 abin [
							int-to-ui16 tagData/1
							ImageCore/ARGB2BLL ImageCore/load rejoin [swfDir %tag20_ last tagData  %.png]
						]
					]
				]
				6 [
					either tmp: select crops tagData/1 [
						;print ["cropbmp" tagId tagData/1 mold tmp]
						write-tag 6 abin [
							int-to-ui16 tagData/1
							read/binary rejoin [swfDir %tag6_ last tagData %_crop_ tmp/1 %x tmp/2 %_ (tmp/3 - tmp/1) %x (tmp/4 - tmp/2) %.jpg]
						]
					][
						write-tag 6 abin [
							int-to-ui16 tagData/1
							read/binary rejoin [swfDir %tag6_ last tagData  %.jpg]
						]
					]
				]
				2 22 32 67 83 [
					;print ["updateShape" tagId]
					if result: swf-tag-optimize tagId tagData [
						write-tag tagId result
					]
				]
			][
				
				write-tag tagId tagData
			]
		]
		print length? outBuffer: head outBuffer
		rswf/frames: frames
		print ["TOTAL REDUCTION:" origBytes - (length? head outBuffer) "bytes"]
		outBuffer: create-swf/rate/version/compressed
				as-pair (SWF/HEADER/FRAME-SIZE/2 / 20) (SWF/HEADER/FRAME-SIZE/4 / 20)
				outBuffer
				swf/header/frame-rate
				swf/header/version
				true

		if into [write/binary out-file outBuffer]

		;clear head swfTags
		recycle
		print ["SHAPE REDUCTION:" negate swf-tag-parser/data/shapeReduction "bytes"]
		;ask ""
		outBuffer
	]
	set 'rescale-swf func[
		"Rescale SWF file" [catch]
		swf-file [file! url! string!] "the SWF source file"
		/into out-file [file!]
		/compact "Uses bitmap packing"
		/local err sysprint sysprin action  swfDir swfName rescaleResult frames px py swfTags tmp images-to-compact
	][
		frames: 0
		rescaleResult: make binary! 20000
		tagsStartIndex: 0
		if all [string? swf-file][swf-file: to-rebol-file swf-file]
		
		swfName: copy find/last/tail swf-file #"/"
		unless swfDir: export-dir [
			swfDir: either url? swf-file [
				what-dir
			][	first split-path swf-file]
		]
		

		
		
		probe swfDir: rejoin [swfDir swfName %_export/]
		;if not exists? swfDir [make-dir/deep swfDir]
		
		px: to-integer (swf-tag-parser/rswf-rescale-index-x * 100)
		py: to-integer (swf-tag-parser/rswf-rescale-index-y * 100)
		unless exists? scDir: rejoin [swfDir %_sc either px = py [px][rejoin [px "x" py]] #"/"][
			make-dir/deep scDir
		]
		
		;unless exists? tmp: rejoin [swfDir %_sc to-integer (swf-tag-parser/rswf-rescale-index * 100) #"/"] [make-dir/deep tmp]
		
		setStreamBuffer open-swf-stream probe swf-file	
		
		if error? set/any 'err try [
			parse-swf-header
			
			swf-tag-parser/parseActions: swfTagRescaleActions
			swf-tag-parser/swfVersion: swf/header/version
			swf-tag-parser/swfDir:  swfDir
			swf-tag-parser/swfName: swfName

			tagsStartIndex: index? inBuffer
			
			either compact [
				swfTags: copy []
				images-to-compact:  context [
					jpeg3: copy []
					jpeg2: copy []
				]

				swf-tag-parser/parseActions: swfTagParseImages
				foreach-swf-tag [
					;probe reduce [tagId tagData]
					;probe tagId
					repend swfTags [tagId tagData]
					switch tagId [
						
						6 21 [
							md5: enbase/base checksum/method skip tagData 2 'md5 16
							with swf-tag-parser [
								setStreamBuffer tagData
								clearOutBuffer
								tmp: switch tagId [
									21 [parse-DefineBitsJPEG2]
									 6 [parse-DefineBits]
								]
								file: export-image-tag tagId md5 tmp
								repend images-to-compact/jpeg3 [
									get-image-size file
									reduce [tmp/1 file]
								]
							]
						]
						6 20 21 36 [
							;== bitmaps
						;	probe md5: enbase/base checksum/method skip tagData 2 'md5 16
						;	result: swf-tag-optimize tagId tagData
						;	swf-tag-parser/export-image-tag tagId md5 result
						;	append result md5
						;	change/only back tail swfTags copy/deep result
						;	append swfBitmaps result/1
						;	repend/only swfBitmaps head change result tagId
						]
						35 [
							;== bitmaps
							md5: enbase/base checksum/method skip tagData 2 'md5 16
							with swf-tag-parser [
								setStreamBuffer tagData
								clearOutBuffer
								tmp: parse-DefineBitsJPEG3
								file: export-image-tag tagId md5 tmp
								repend images-to-compact/jpeg3 [
									get-image-size file
									reduce [tmp/1 file]
								]
							]
						]
						8 [	with swf-tag-parser [JPEGTables: parse-JPEGTables] ]
					]
				]
				unless empty? images-to-compact/jpeg3 [
					maxpair: 0x0
					foreach [size id] images-to-compact/jpeg3 [
						maxpair: max maxpair size
					]
					
					maxi: max maxpair/x maxpair/y
					
					size: case [
						maxi < 64  [  64x64  ]
						maxi < 128 [ 128x128 ]
						maxi < 256 [ 256x256 ]
						maxi < 512 [ 512x512 ]
						true       [1024x1024]
					]

					
					while [not empty?  second result: rectangle-pack images-to-compact/jpeg3 size][
						if size/x >= 1024 [
							print "images too big to fit in one bmp"
							ask ""
							break
						] 
						size: size * 2
					]
		
					?? images-to-compact
					probe result
					combine-files result/1 size %/f/test.jpg
					combine-files result/1 size %/f/test.png
					ask ""
				]
			][
				while [not tail? inBuffer][
					tagStart: index? inBuffer
					tagAndLength: readUI16
					tagId:     to integer! ((65472 and tagAndLength) / (2 ** 6))
					tagLength: tagAndLength and 63
					if tagLength = 63 [tagLength: readUI32]
					tagData: either tagLength > 0 [readBytes tagLength][make binary! 0 ]
					;print [">" tagId ">>>" index? tagData length? tagData  checksum tagData]
					;insert/only tail importedTags reduce [tagId tagData]
					insert tail rescaleResult rescale-swf-tag tagId tagData
					if tagId = 1 [
						frames: frames + 1
					]
					
					;print ["<" r/1 "<<<" index? r/2 length? r/2 checksum r/2]
				]
			]
			

		][
			clear head inBuffer
			recycle
			throw err
		]
	;	probe importedResult
		;write/binary %xxx.swf 
		rswf/frames: frames
		rescaleResult: create-swf/rate/version/compressed
				as-pair (swf-tag-parser/rsci-x SWF/HEADER/FRAME-SIZE/2 / 20) (swf-tag-parser/rsci-y SWF/HEADER/FRAME-SIZE/4 / 20)
				rescaleResult
				swf/header/frame-rate
				swf/header/version
				true
		if into [write/binary out-file rescaleResult]
		recycle
		rescaleResult
	]
	
	set 'combine-swf-bmps func[
		"Tries to pack bitmaps into more compact texture map(s)" ;[catch]
		swf-file [file! url! string!] "the SWF source file"
		/into out-file [file!]
		/compact "Uses bitmap packing"
		/local err sysprint sysprin action  swfDir swfName rescaleResult frames px py swfTags
		       tmp images-to-compact file md5 maxpair maxi round-to-pow2
	][
		frames: 0
		tagsStartIndex: 0
		if all [string? swf-file][swf-file: to-rebol-file swf-file]
		
		swfName: copy find/last/tail swf-file #"/"
		unless swfDir: export-dir [
			swfDir: either url? swf-file [
				what-dir
			][	first split-path swf-file]
		]
		
		round-to-pow2: func[v /local p][ repeat i 12 [if v <= (p: 2 ** i) [return p]] none]
		remove-img-with-id: func[imgs id][
			while [not tail? imgs][
				if id = imgs/2/1 [
					remove/part imgs 2
					break
				]
				imgs: skip imgs 2
			]
			imgs: head imgs
		]
		
		probe swfDir: rejoin [swfDir swfName %_export/]
		if not exists? swfDir [make-dir/deep swfDir]
		

		;unless exists? tmp: rejoin [swfDir %_sc to-integer (swf-tag-parser/rswf-rescale-index * 100) #"/"] [make-dir/deep tmp]
		
		setStreamBuffer open-swf-stream probe swf-file	
		clearOutBuffer
		
		if error? set/any 'err try [
			parse-swf-header
			
			swf-tag-parser/parseActions: swfTagRescaleActions
			swf-tag-parser/swfVersion: swf/header/version
			swf-tag-parser/swfDir:  swfDir
			swf-tag-parser/swfName: swfName

			tagsStartIndex: index? inBuffer
			

				swfTags: copy []
				images-to-compact:  context [
					jpeg3: copy []
					jpeg2: copy []
				]

				swf-tag-parser/parseActions: swfTagParseImages
				foreach-swf-tag [
					;probe reduce [tagId tagData]
					;probe tagId
					repend swfTags [tagId tagData]
					switch tagId [
						;57 [ask "::::"]
						;71 [ask "71"]
						76 [
							with swf-tag-parser [
								setStreamBuffer tagData
								clearOutBuffer
								foreach [id name] parse-SymbolClass [
									remove-img-with-id images-to-compact/jpeg3 id
									remove-img-with-id images-to-compact/jpeg2 id
								]
								;probe images-to-compact
								;ask "??>"
							]
						]
						56 [
							with swf-tag-parser [
								setStreamBuffer tagData
								clearOutBuffer
								tmp: parse-ExportAssets
								;ask "??"
							]
						]
						6 21 [
							md5: enbase/base checksum/method skip tagData 2 'md5 16
							with swf-tag-parser [
								setStreamBuffer tagData
								clearOutBuffer
								tmp: switch tagId [
									21 [parse-DefineBitsJPEG2]
									 6 [parse-DefineBits]
								]
								file: export-image-tag tagId md5 tmp
								repend images-to-compact/jpeg2 [
									get-image-size file
									reduce [tmp/1 file]
								]
							]
						]
						6 20 21 36 [
							;== bitmaps
						;	probe md5: enbase/base checksum/method skip tagData 2 'md5 16
						;	result: swf-tag-optimize tagId tagData
						;	swf-tag-parser/export-image-tag tagId md5 result
						;	append result md5
						;	change/only back tail swfTags copy/deep result
						;	append swfBitmaps result/1
						;	repend/only swfBitmaps head change result tagId
						]
						35 [
							;== bitmaps
							md5: enbase/base checksum/method skip tagData 2 'md5 16
							with swf-tag-parser [
								setStreamBuffer tagData
								clearOutBuffer
								tmp: parse-DefineBitsJPEG3
								file: export-image-tag tagId md5 tmp
								export-image-tag/alpha tagId md5 tmp
								
								size: get-image-size file
								print ["??" size file] 
								if all [size/x <= 2048 size/y <= 2048][ 
									repend images-to-compact/jpeg3 [
										size
										reduce [tmp/1 file]
									]
								]
								change/only back tail swfTags copy/deep tmp
							]
						]
					;	8 [	with swf-tag-parser [probe tagData JPEGTables: parse-JPEGTables] ]
					]
				]
				
				swf-tag-parser/data: context compose/only [
					combined-bitmaps:  copy []
					combined-bmp-id: none 	
				]

				
				if 10 < length? images-to-compact/jpeg3 [
					get-comp-size: func[data /local maxpair maxi][
						maxpair:  0x0
						foreach [size id] data [
							maxpair: max maxpair size
						]
						
						
						;maxi: max maxpair/x maxpair/y
						;print ["MAXI:" maxi]
						maxpair/x: to-integer round-to-pow2 maxpair/x
						maxpair/y: to-integer round-to-pow2 maxpair/y
						print ["MAXPAIR:" maxpair] ;ask "[ENTER]"
						comment {
						case [
							maxi < 64   [  64x64  ]
							maxi < 128  [ 128x128 ]
							maxi < 256  [ 256x256 ]
							maxi < 512  [ 512x512 ]
							maxi < 1024 [1024x1024]
							true        [2048x2048]
						]}
						maxpair
					]

					probe size: get-comp-size images-to-compact/jpeg3
					data-to-process: images-to-compact/jpeg3
					while [
						10 < length? data-to-process
						not empty?  probe second result: rectangle-pack data-to-process size
					][
						;if size/x > 1024 [
						;	print "images too big to fit in one bmp"
						;	ask "[ENTER TO BREAK]"
							;break
						;] 
						probe data-to-process
						;either empty? second result: rectangle-pack data-to-process size
						;print ["--------" size]
						either size/x > size/y [
							size/y: size/y * 2
						][	size/x: size/x * 2 ]
						if any [
							size/x > 1024
							size/y > 1024
						][	
							print ["Coumponed bitmap would be too large! Excluding bitmap.." copy/part data-to-process 2]
							remove/part data-to-process 2
							size: get-comp-size images-to-compact/jpeg3
							size/x: min 1024 size/x
							size/y: min 1024 size/y

						]
							
						;probe size: size * 2
						;ask
						print reform ["new size:" size "^/[ENTER to CONTRINUE]"]
					]
		
					;?? images-to-compact
					
					maxi: 0
					foreach [pos size data] result/1 [
						maxi: max maxi (pos/y + size/y)
					]
					;size/y: maxi
					;probe result
					md5:  enbase/base checksum/method mold result/1 'md5 16
					probe combined-bmp-file: rejoin [swfDir %combined_ md5]
					swf-tag-parser/combine-files result/1 size join combined-bmp-file %.jpg
					swf-tag-parser/combine-files result/1 size join combined-bmp-file %.png
					foreach [pos size data] result/1 [
						repend swf-tag-parser/data/combined-bitmaps [data/1 pos]
					]
					new-line/skip swf-tag-parser/data/combined-bitmaps true 2
					;probe swf-tag-parser/data/combined-bitmaps
					;ask ""
				]

			;make error! "not finished!"
			
			swf-tag-parser/parseActions: swfTagOptimizeActions2	
			swf-tag-parser/use-BB-optimization?: false
			
				if empty? swf-tag-parser/data/combined-bitmaps [print "No compacting needed" return none]
						
							
				foreach [Id tagData] swfTags [
					tagId: id
					;print [tagId type? tagData]
		
					switch/default tagId [
						35 [
							either tmp: select swf-tag-parser/data/combined-bitmaps tagData/1 [
								unless swf-tag-parser/data/combined-bmp-id [
									swf-tag-parser/data/combined-bmp-id: tagData/1
									bin1: read/binary join combined-bmp-file %.jpg
									bin2: load join combined-bmp-file %.png
									write-tag 35 abin [
										int-to-ui16 tagData/1
										int-to-ui32 length? bin1
										bin1
										head head remove/part tail compress bin2/alpha -4
									]
								]
							][
								write-tag 35 abin [
									int-to-ui16 tagData/1
									int-to-ui32 length? tagData/2
									tagData/2
									tagData/3
									;head head remove/part tail compress tagData/3 -4
								]
							]
								
						]
						
						2 22 32 67 83 [
							;print ["combineShape" tagId]
							with swf-tag-parser [
								setStreamBuffer tagData
								clearOutBuffer
								result: combine-updateShape
							]
							write-tag tagId result
							
						]
						56 [
							print ["EXPORT"]
							with swf-tag-parser [
								setStreamBuffer probe tagData
								clearOutBuffer
								id:   readUI16
								probe name: readSTRING
							]
						]
					][
						
						write-tag tagId tagData
					]
				]
		][
			clear head inBuffer
			recycle
			throw err
		]
	;	probe importedResult
		;write/binary %xxx.swf 
		rswf/frames: swf/header/frame-count
		rescaleResult: create-swf/rate/version/compressed
				as-pair (SWF/HEADER/FRAME-SIZE/2 / 20) (SWF/HEADER/FRAME-SIZE/4 / 20)
				head outBuffer
				swf/header/frame-rate
				swf/header/version
				true
		if into [write/binary out-file rescaleResult]
		recycle
		rescaleResult
	]
	
	#include %parsers/swf-tags.r
	#include %parsers/swf-to-rswf-actions.r
	#include %parsers/swf-optimize-actions.r
	#include %swf-tag-parser.r
]


save-jpgs: func[[catch] swf-file /local tmpdata swfDir swfName jpegTables][
	swfName: copy find/last/tail swf-file #"/"
	unless swfDir: export-dir [
		swfDir: either url? swf-file [
			what-dir
		][	first split-path swf-file]
	]
		
	
	probe swfDir: rejoin [swfDir swfName %_export/]
	if not exists? swfDir [make-dir/deep swfDir]
	swf-parser/swf-tag-parser/swfDir:  swfDir
		
	if not error? try [
		swfName: copy/part swfname find/last swfname %.swf
	][
		exam-swf/file/parseActions/only swf-file [
			6 [
				tmpdata: parse-DefineBits
				write/binary rejoin [swfDir swfname %_id tmpdata/1 %.jpg] join jpegTables skip tmpdata/2 2
				tmpdata
			]
			8 [ 
				jpegTables: parse-JPEGTables
				head remove/part skip tail jpegTables -2 2
				
			]
			21 [
				;use [tmp][
				
					tmpdata: parse-DefineBitsJPEG2
					;write/binary rejoin [swfdir swfname %_id tmpdata/1 %.jpg] tmpdata/2
					write/binary  probe rejoin [swfDir %tag21 %_id tmpdata/1 %.jpg] tmpdata/2

					tmpdata
				;]
			]
			35 [
				;use [tmp][
					tmpdata: parse-DefineBitsJPEG3
					replace tmpdata/2 #{FFD9FFD8} #{}
					write/binary rejoin [swfdir swfname %_id tmpdata/1 %.jpg] tmpdata/2
					alphaimg: make image! jpg-size tmpdata/2
					alphaimg/alpha:	as-binary zlib-decompress tmpdata/3 (alphaimg/size/1 * alphaimg/size/2)
					save/png rejoin [swfdir swfname %_id tmpdata/1 %.png] alphaimg
					
					
					tmpdata
				;]
			]
			39 [parse-DefineSprite]
			
		][6 8 20 21 35 36 39] 
	]
	
]

save-mp3-samples: func[swf-file /local tmpdata swfDir swfName jpegTables][
	swfName: copy find/last/tail swf-file #"/"
	unless swfDir: export-dir [
		swfDir: either url? swf-file [
			what-dir
		][	first split-path swf-file]
	]
		
	print ".."
	probe swfDir: rejoin [swfDir swfName %_export/]
	if not exists? swfDir [make-dir/deep swfDir]
	swf-parser/swf-tag-parser/swfDir:  swfDir
		
	;if not error? try [
	;	probe swfName: copy/part swfname find/last swfname %.swf
	;][
		exam-swf/file/parseActions/only probe swf-file [
			14 [
				print "..sound..."
				tmpdata: parse-DefineSound
				if tmpdata/2 = 2 [
					print tmpdata/1
					write/binary rejoin [swfdir swfname %_id tmpdata/1 %.mp3] tmpdata/7
				]
				tmpdata
			]
			
		][14] 
	;]
	
]
;save-jpgs "I:\rebol\rs\projects-mm\robotek\latest\ftp\LEVELY\00_intro\flash\00_intro_2.swf"


;exam-swf/file/only "I:\rebol\rs\projects-mm\robotek\latest\rob21.swf" [77 9 10 26 2]
;probe stats
;tm 1 [probe gbl-test [
;	exam-swf/file/quiet/into "I:\rebol\rs\projects-mm\robotek\latest\ftp\LEVELY\00_intro\flash\00_intro_2.swf" %/f/test/x2b.txt
	;exam-swf/file %/i/rebol/rs/projects-rswf/rswf/new/test.swf
;]]
;recycle
;probe stats
;exam-swf/file "F:\test\x.swf" 
;probe import-swf "F:\test\x.swf" []
;exam-swf/file "I:\rebol\rs\projects-mm\robotek\latest\rob21.swf" 