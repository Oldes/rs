rebol [
	title: "Drawing shapes"
	date: 19-4-2005
]

draw-shapes: func[swf-file /local segment-points][
	;if empty? swf-file: to-file ask "SWF file:" [swf-file: %new.swf]
	swf-bin: read/binary swf-file
	
	swf-bin: skip swf-bin 21
	
	
	dialect: make string! 50000
	shapes:  make block! 50
	offsets: make block! 50
	
	foreach-tag swf-bin [
		tagid: tag
		tag-bin: data
		either find [2 22 32] tagid [
				shp-drawing: parse-DefineShape tag-bin
				;probe reduce [obj-id obj-rect]
				
				;append dialect rejoin [
				;	{^/shp_} obj-id {: shape [^/ units twips } shp-drawing {^/]^/}
				;]
				;append shapes obj-id
				;id: to-integer tag-bin-part/rev 2
				repend shapes [obj-id copy shp-drawing]
		][
			switch tagid [
				26 [
					tmp: parse-PlaceObject2 tag-bin
					if find shapes tmp/id [
						repend offsets [tmp/id tmp/at]
					]
					;if find shapes tmp/id [
					;	append dialect rejoin [
					;		{^/place shp_} tmp/id { at } tmp/at
					;	]
					;]
				]
			]
		]
	]
	
	objects: 0 segments: 0
	tmp-shape: make block! 300
	
	prepare-points: func[points ofs][
		fp: first points
		forall points [change points points/1 - fp]
		head points
	]
	draw-shape: func[][
		objects: objects + 1
		;probe tmp-shape
		parse tmp-shape [['curve | 'line] set fp pair! to end]
		;probe fp
		append dialect rejoin [
			{^/shp_} objects {: shape [^/^-edge } mold edge-spec newline
		]
		parse tmp-shape [any[
			'curve copy points some pair! (
				forall points [change points points/1 - fp]
				append dialect rejoin [{^/^-curve } head points]
			)
			| 'line  copy points some pair! (
				forall points [change points points/1 - fp]
				append dialect rejoin [{^/^-line } head points]
			)
		]]
		append dialect rejoin [
			{^/]^/place shp_} objects { at } (fp + ofs)
			{^/showframe^/}
		]
		clear tmp-shape			
		segments: 0
			
	]
	
	draw-orig-shape: func[shape][
		objects: objects + 1
		append dialect rejoin [
			{^/shp_} objects {: shape [^/^-edge } mold edge-spec newline
		]
		parse shape [any[
			'curve copy points some pair! (
				append dialect rejoin [{^/^-curve } head points]
			)
			| 'line  copy points some pair! (
				append dialect rejoin [{^/^-line } head points]
			)
		]]
		append dialect rejoin [
			{^/]^/place shp_} objects { at } (ofs)
			{^/showframe^/}
		]
	]
	edge-spec: [width 40 color #FF0000]
	max-segments: 3
	foreach [id shps] shapes [
		if not none? ofs: select offsets id [
			print ["Drawing shape" id "at" ofs]
			foreach shape shps [
				;probe shape
				;draw-orig-shape shape
				
				;[
				parse shape [any[
					  'edge set new-edge-spec block! (
					  	;replace new-edge-spec 253.14.254 253.14.254.200
					  
					  	;replace new-edge-spec 97.246.157 100.187.147
					  	;replace new-edge-spec 249.128.19 255.127.0
					  	;replace new-edge-spec 0.0.0 60.60.60
					  	if not empty? tmp-shape [draw-shape]
					  	edge-spec: copy new-edge-spec
					)
					| 'curve copy curve-points some pair! (
						;print ["CURVE" mold curve-points]
						while [(length? curve-points) >= 3] [
							segment-points: copy/part curve-points 3
							append tmp-shape compose [curve (segment-points)]
							segments: segments + 1 
							if segments >= max-segments [draw-shape]
							curve-points: skip curve-points 2
						]
						;prepare-points points ofs
						;print ["curve" fp ":" points ]
					)
					| 'line  copy points some pair! (
						append tmp-shape compose [line (points)]
						segments: segments + 1 ;((length? points) / 2)
						if segments >= max-segments [draw-shape]
						;prepare-points points ofs
						;print ["line " fp ":" points]
					)
				]]
				if not empty? tmp-shape [draw-shape]
				;]
			]
		]
	]
	;probe offsets
	
	
	
	
	
	

		insert dialect rejoin [{rebol [
		title: "test"
		type: 'mx
		file: %web/} dr-swf-file {
		background: 153.165.139
		rate: 5
		size: 800x600 ;213x350 ;780x495 ;510x330
		author: "Oldes"
		email: oliva.david@seznam.cz
		compressed: false
		date: 30-8-2004
		purpose: {}
		comment: {}
	]
	rebol [rswf/twips?: true]}]
		
		append dialect {
		stop showframe end}
	


]

{
dr-swf-file: "dr-photo.swf"
go/pr 'sista
draw-shapes %all2.swf
write %photo.rswf dialect
make-swf/save %photo.rswf
}
{
dr-swf-file: "dr-graphic.swf"
go/pr 'sista
draw-shapes %graphic.swf
write %graphic.rswf dialect
make-swf/save %graphic.rswf
}
{
dr-swf-file: "dr-stage.swf"
go/pr 'sista
draw-shapes %stage.swf
write %stage.rswf dialect
make-swf/save %stage.rswf
}