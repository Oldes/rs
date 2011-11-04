rebol [
	title: "Drawing shapes"
	date: 19-4-2005
]

draw-shapes: func[swf-file][
	;if empty? swf-file: to-file ask "SWF file:" [swf-file: %new.swf]
	swf-bin: read/binary swf-file
	
	swf-bin: skip swf-bin 21
	
	
	dialect: make string! 50000
	shapes:  make block! 50
	offsets: make block! 50
	
	foreach-tag swf-bin [
		tagid: tag
		tag-bin: data
		either find [2 22] tagid [
				shp-drawing: parse-DefineShape tag-bin
				;probe reduce [obj-id obj-rect]
				new-drawing: make block! 10000
				foreach shp shp-drawing [
					insert tail new-drawing shp
				]
				append dialect rejoin [
					{^/shp_} obj-id {: shape } mold new-drawing {^/}
				]
				append shapes obj-id
				;id: to-integer tag-bin-part/rev 2
				;repend shapes [obj-id copy shp-drawing]
		][
			switch tagid [
				26 [
					probe tmp: parse-PlaceObject2 tag-bin
					;if find shapes tmp/id [
					;	repend offsets [tmp/id tmp/at]
					;]
					if find shapes tmp/id [
						append dialect rejoin [
							{^/place shp_} tmp/id { at } tmp/at
						]
					]
				]
			]
		]
	]
	insert dialect {rebol [
		title: "test"
		type: 'mx
		file: %test.swf
		background: 153.165.139
		rate: 25
		size: 865x600
		author: "Oldes"
		email: oliva.david@seznam.cz
		date: 30-8-2004
		purpose: {}
		comment: {}
	]
	rebol [rswf/twips?: true]}
		
		append dialect {
		stop showframe end}
	


]

go/pr 'sista
draw-shapes %photo.swf
write %drawing.rswf dialect