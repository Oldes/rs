rebol [title: "swf-tag-parser"]

swf-tag-parser: make stream-io [
	verbal?: on
	output-file: none
	parseActions:   copy []
	tagSpecifications: copy []
	onlyTagIds: none
	swfVersion: none
	swfDir: swfName: none
	tmp: none
	file: none
	
	data: none
	used-ids: none
	last-depth: none
	init-depth: 0
	tag-checksums: copy []
	;result: none

	set 'parse-swf-tag func[tagId tagData /local err action st st2][
		;st: stats
		;store: reduce [inBuffer availableBits bitBuffer]  ;store previous buffer for recursion
	
		either none? action: select parseActions tagId [
			result: none
		][
			setStreamBuffer tagData
			if error? set/any 'err try [
				set/any 'result do bind/copy action 'self
			][
				print ajoin ["!!! ERROR while parsing tag:" select swfTagNames tagId "(" tagId ")"]
				throw err
			]
		]
		if spriteLevel = 0 [
			if verbal? [
				prin getTagInfo tagId result
			]
			if port? output-file [
				insert tail output-file getTagInfo tagId result
				;insert tail output-file ajoin [tagId mold result LF]
			]
		]
		;inBuffer:  store/1
		;availableBits: store/2
		;bitBuffer: store/3
		;clear store
		;recycle
		;print [tagId st2: stats st2 - st]
		;probe
		result
	]
	
	set 'swf-tag-to-rswf func[tagId tagData /local err action st st2  ][
		either none? action: select parseActions tagId [
			result: none
		][
			setStreamBuffer tagData
			if error? set/any 'err try [
				set/any 'result do bind/copy action 'self
			][
				print ajoin ["!!! ERROR while parsing tag:" select swfTagNames tagId "(" tagId ")"]
				throw err
			]
		]
		if spriteLevel = 0 [
			switch/default type?/word result [
				string! [print result]
				none!   []
			;	block!  [probe result]
				;binary! [probe result]
			][
				print select swfTagNames tagId
			]
		]
		result
	]

	
	readID:     :readUI16
	readUsedID: :readUI16
	spriteLevel: 0
	
	names-to-ids: copy []
	JPEGTables: none
	
	export-file: func[tag id ext data /local file][
		write/binary probe file: rejoin [swfDir %tag tag %_id id ext] data
		file
	]
	
	StreamSoundCompression: none
	comment {
	StreamSoundCompression -
		defined in SoundStreamHead tag
		used in SoundStreamBlock
	}
		
	tabs:    copy ""
	tabsspr: copy ""
	tabind+: does [append tabs "^-"]
	tabind-: does [remove tabs]
	tabspr+: does [append tabsspr "^-"]
	tabspr-: does [remove tabsspr]
	
	getTagInfo: func[tagId data /local fields][
		;print ["====================" tagId]
		ajoin [
			tabsspr select swfTagNames tagId "(" either tagId < 10 [join "0" tagId][tagId] "):"
			either fields: select tagFields tagId [
				join LF getTagFields data :fields true
			][	join either none? data ["x"][join " " mold data] LF	]
			
		]
	]
	getTagFields: func[data fields indent? /local result fld res p name ind l][
		unless data [return ""]
		if indent? [tabind+]
		result: copy ""
		unless block? data [data: reduce [data]]
		
		;probe data
		;probe fields
		;print type? fields
		either function? :fields [
			insert tail result fields data
		][
			parse fields [any [
				p: (if any [not block? data tail? data] [p: tail p]) :p
				[
					 set fld string! (
						res: either none? data/1 [""][
							ajoin [
								tabs fld ": "
								either all [
									binary? data/1
									20 < l: length? data/1
								][
									ajoin [ l " Bytes = " head remove back tail mold copy/part data/1 10 "..." ]
								][	mold data/1 ]
								LF
							]
						]
					)
					| set fld block! set ind ['noIndent | none] (
						res:  getTagFields data/1 fld (ind <> 'noIndent)
					)
					| set fld function! ( res: fld data/1 )
					| 'group set name string! set fld block!  set ind ['noIndent | none](
						res: either none? data/1 [""][
							ajoin [tabs name ": [^/" getTagFields data/1 fld (ind <> 'noIndent) tabs "]^/"]
						]
					)
					| 'get set name [lit-word! | word!] set ind ['noIndent | none] (
						if ind = 'noIndent [tabind-]
						res: ajoin [tabs name ": " getFieldData name data/1 LF]
						if ind = 'noIndent [tabind+]
					)
				] (
					insert tail result res
					data: next data
				)
			]]
	
			data:   head data
			fields: head fields
		]
		if indent? [tabind-]
		result
	]	

	#include %parsers/swf-tags-fields.r
	#include %parsers/basic-datatypes.r
	#include %parsers/font-and-text.r
	#include %parsers/shape.r
	#include %parsers/button.r
	#include %parsers/sprite.r
	#include %parsers/sound.r
	#include %parsers/bitmap.r
	#include %parsers/actions.r
	#include %parsers/morphing.r
	#include %parsers/control-tags.r
	
	#include %parsers/swf-importing.r
	#include %parsers/swf-rescaling.new.r
	;#include %parsers/swf-rescaling.r
	#include %parsers/swf-optimize.r
	#include %parsers/swf-combine-bmps.r
]