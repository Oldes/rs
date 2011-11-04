rebol [
	title: "SWF sprites and movie clip related parse functions"
	purpose: "Functions for parsing sprites and movie clip related tags in SWF files"
]

set 'swf-tag-optimize func[tagId tagData /local err action st st2][
	reduce either none? action: select parseActions tagId [
		;tagData
		;print ["importing tag:"  tagId]
		form-tag tagId tagData
	][
		setStreamBuffer tagData
		;print ["IMP>" index? inBuffer length? inBuffer]
		;print [tagId select swfTagNames tagId]
		
		if error? set/any 'err try [
			set/any 'result do bind/copy action 'self
		][
			print ajoin ["!!! ERROR while importing tag:" select swfTagNames tagId "(" tagId ")"]
			throw err
		]
		result
		;head inBuffer
		;print ["IMP<" index? inBuffer length? head inBuffer]
		;form-tag tagId head inBuffer
	]

]


optimize-detectBmpFillBounds: has[shape result fillStyles lineStyles pos st dx dy tmp lineStyle fillStyle0 fillStyle1 hasBitmapFills? p fill] [
	probe shape: parse-DefineShape
	probe fillStyles: shape/4/1
	foreach fill fillStyles [
		if find [64 65 66 67] fill/1 [
			hasBitmapFills?: true
			append fill [1000000 1000000 -1000000 -1000000]
		]
	]
	if none? hasBitmapFills? [return none]
	lineStyles: shape/4/2
	lineStyle: fillStyle0: fillStyle1: none
	pos: 0x0
	fill: fill0pos: fill1pos: none
	fill0min: fill1min:  1000000x1000000
	fill0max: fill1max: -1000000x-1000000
	parse shape/4/3 [
		any [
			'style set st block! p: (
				print ["style:" mold st]
				if all [fill0pos fill0bmp] [
					print ["end fill0" fill0pos]
					repend bmpFills probe reduce [fill0bmp/2/1 fill0bmp/2/2/3  fill0bmp/3 fill0bmp/4 fill0bmp/5 fill0bmp/6]
				]
				if all [fill1pos fill1bmp] [
					print ["end fill1" fill1pos]
					repend bmpFills probe reduce [fill1bmp/2/1 fill1bmp/2/2/3  fill1bmp/3 fill1bmp/4 fill1bmp/5 fill1bmp/6]
				]
				;if fill1pos [fill1pos: fill1pos + as-pair dx dy]
				fill0bmp: either fill0: st/2 [fillStyles/(fill0)][none]
				fill1bmp: either fill1: st/3 [fillStyles/(fill1)][none]
				if st/1 [pos: as-pair st/1/1 st/1/2]
				print ["POS:" pos]
				either any [
					all [fill0bmp find [64 65 66 67] fill0bmp/1]
					all [fill1bmp find [64 65 66 67] fill1bmp/1]
				][
					print ["bmpfill" mold fill0bmp mold fill1bmp]
					probe fill0pos: either fill0bmp [pos + as-pair fill0bmp/2/2/3/1 fill0bmp/2/2/3/2 pos][none]
					probe fill1pos: either fill1bmp [pos + as-pair fill1bmp/2/2/3/1 fill1bmp/2/2/3/2 pos][none]
					
					if fill0pos [
						fill0bmp/3: min fill0bmp/3 fill0pos/x
						fill0bmp/5: max fill0bmp/5 fill0pos/x
						fill0bmp/4: min fill0bmp/4 fill0pos/y
						fill0bmp/6: max fill0bmp/6 fill0pos/y
					]
					if fill1pos [
						fill1bmp/3: min fill1bmp/3 fill1pos/x
						fill1bmp/5: max fill1bmp/5 fill1pos/x
						fill1bmp/4: min fill1bmp/4 fill1pos/y
						fill1bmp/6: max fill1bmp/6 fill1pos/y
					]
			;		probe fill0bmp
				][
					print "nobmpfill"
					either tmp: find p 'style [p: tmp][p: tail p]
				]
			) :p
			| 'line some [
				set dx integer! set dy integer! (
					if fill0pos [
						fill0pos: fill0pos + as-pair dx dy
						either dx < 0 [
							fill0bmp/3: min fill0bmp/3 fill0pos/x
						][
							if dx > 0 [
								fill0bmp/5: max fill0bmp/5 fill0pos/x
							];[
							;	fill0bmp/3: min fill0bmp/3 fill0pos/x
							;	fill0bmp/5: max fill0bmp/5 fill0pos/x
							;]
						]
						either dy < 0 [
							fill0bmp/4: min fill0bmp/4 fill0pos/y
						][
							if dy > 0 [
								fill0bmp/6: max fill0bmp/6 fill0pos/y
							];[
							;	fill0bmp/3: min fill0bmp/3 fill0pos/x
							;	fill0bmp/5: max fill0bmp/5 fill0pos/x
							;]
						]
					]
					if fill1pos [
						fill1pos: fill1pos + as-pair dx dy
						either dx < 0 [
							fill1bmp/3: min fill1bmp/3 fill1pos/x
						][
							if dx > 0 [
								fill1bmp/5: max fill1bmp/5 fill1pos/x
							];[
							;	fill1bmp/3: min fill1bmp/3 fill1pos/x
							;	fill1bmp/5: max fill1bmp/5 fill1pos/x
							;]
						]
						either dy < 0 [
							fill1bmp/4: min fill1bmp/4 fill1pos/y
						][
							if dy > 0 [
								fill1bmp/6: max fill1bmp/6 fill1pos/y
							];[
							;	fill1bmp/3: min fill1bmp/3 fill1pos/x
							;	fill1bmp/5: max fill1bmp/5 fill1pos/x
							;]
						]
					]
				;	probe fill0bmp
					pos: pos + as-pair dx dy
				;	print ["pos:" pos]
					;append result ajoin [pos " "]
				)] ;(append result lf)
			|
			'curve some [
				;set cx integer! set cy integer!
				set dx integer! set dy integer! (
					;dx: dx + cx
					;dy: dy + cy
					pos: pos + as-pair dx dy
					;print ["pos:" pos]
					if fill0pos [
						fill0pos: fill0pos + as-pair dx dy
						;probe fill0bmp
						either dx < 0 [
							fill0bmp/3: min fill0bmp/3 fill0pos/x
						][
							if dx > 0 [
								fill0bmp/5: max fill0bmp/5 fill0pos/x
							];[
							;	fill0bmp/3: min fill0bmp/3 fill0pos/x
							;	fill0bmp/5: max fill0bmp/5 fill0pos/x
							;]
						]
						either dy < 0 [
							fill0bmp/4: min fill0bmp/4 fill0pos/y
						][
							if dy > 0 [
								fill0bmp/6: max fill0bmp/6 fill0pos/y
							];[
							;	fill0bmp/3: min fill0bmp/3 fill0pos/x
							;	fill0bmp/5: max fill0bmp/5 fill0pos/x
							;]
						]
					]
					if fill1pos [
						fill1pos: fill1pos + as-pair dx dy
						probe fill1bmp
						either dx < 0 [
							fill1bmp/3: min fill1bmp/3 fill1pos/x
						][
							if dx > 0 [
								fill1bmp/5: max fill1bmp/5 fill1pos/x
							];[
							;	fill1bmp/3: min fill1bmp/3 fill1pos/x
							;	fill1bmp/5: max fill1bmp/5 fill1pos/x
							;]
						]
						either dy < 0 [
							fill1bmp/4: min fill1bmp/4 fill1pos/y
						][
							if dy > 0 [
								fill1bmp/6: max fill1bmp/6 fill1pos/y
							];[
							;	fill1bmp/3: min fill1bmp/3 fill1pos/x
							;	fill1bmp/5: max fill1bmp/5 fill1pos/x
							;]
						]
					]
					if fill1pos [fill1pos: fill1pos + as-pair dx dy]
					;append result ajoin [pos " "]
				)
				] ;(append result lf)
			
		]
		
	]
	probe fill0bmp

	bmpFills: copy []
	foreach fill fillStyles [
		if find [64 65 66 67] fill/1 [
			repend bmpFills probe reduce [fill/2/1 fill/2/2/3  fill/3 fill/4 fill/5 fill/6]
		]
	]
	bmpFills
]
