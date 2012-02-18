REBOL [
    Title:   "Rectangle-pack"
    Date:    14-Feb-2012/20:39:44+1:00
    Name:    'rectangle-pack
    Version: 1.0.0
	History: [
		1.0.0 27-Oct-2010 {Initial version}
		1.1.0 14-Feb-2012 {
			Added pow2-rectangle-pack and pow2-box-pack functions.
			It's possible to specify pre-sorting method} 
	]
    File: %rectangle-pack.r
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: [
		probe pow2-rectangle-pack [
			120x10 "img1"
			125x5  "img2"
			100x4  "img3"
		]
		probe pow2-box-pack [
			120x10 "img1"
			125x5  "img2"
			100x4  "img3"
		]
	]
    Purpose: none
    Comment: {
    This code was inspired by this page:
    http://www.blackpawn.com/texts/lightmaps/default.html
    It's not exactly the same as this one is not using recursion, but works fine for my purposes.
    Here are for example packed bitmaps into 256x256 texture:
    http://box.lebeda.ws/~hmm/rebol/rectangle-pack-result.jpg
    }
    History: none
    Language: none
    Type: none
    Email: none
]

ctx-rectangle-pack: context [
	padding: 0x0
	verbose: 0
	
	round-to-pow2: func[v /local p][ repeat i 14 [if v <= (p: 2 ** i) [return p]] none]
	
	max-pow2-size: func[data /local maxpair ][
		maxpair:  0x0
		foreach [size id] data [
			maxpair: max maxpair size
		]
		maxpair/x: to-integer round-to-pow2 maxpair/x
		maxpair/y: to-integer round-to-pow2 maxpair/y
		maxpair
	]
	min-pow2-size: func[data /local minpair ][
		minpair:  0x0
		foreach [size id] data [
			minpair: max minpair size
		]
		minpair/x: to-integer round-to-pow2 minpair/x
		minpair/y: to-integer round-to-pow2 minpair/y
		minpair
	]
	pow2-area: func[size][
		(round-to-pow2 size/x) * (round-to-pow2 size/y)
	]
	
	set 'pow2-box-pack func[images /method sort-method /local size data-to-process result][

		size: min-pow2-size images
		size: as-pair tmp: min size/x size/y tmp
		
		data-to-process: copy images

		while [
			not empty? second result: rectangle-pack/method data-to-process size sort-method
		][
			size: size * 2
			;print reform ["retry with size:" size]
		]
		reduce [size result]
	]
	
	set 'pow2-rectangle-pack func[images /method sort-method /local size data-to-process result][

		minsize: min-pow2-size images
		data-to-process: copy images

		minArea:   to-integer #{7FFFFFFF}
		minResult: none
		
		size: minsize
		until [
			until [
				result: rectangle-pack/method data-to-process size sort-method
				area: size/x * size/y
				;print ["test size:" size]
				if empty? second result [
					if minArea >= area [
						;print ["???" result/3  ]
						if any [
							none? minResult
							minArea > area
							(pow2-area size) < (pow2-area minResult/1)
							all [
								(pow2-area size) = (pow2-area minResult/1)
								any [
									size/x = size/y
									(max size/x size/y) < (max minResult/1/x minResult/1/y)
								]
							]
						][
							minArea: area
							minResult: reduce [size result]
							;print ["NEW MIN AREA:" area]
						]
					]
					break
				]
				size/x: size/x * 2
				;print ["?X" area minArea]
				not all [
					area < minArea
					size/x <= 8192
				]
			]
			size/y: size/y * 2
			size/x: minsize/x
			area: pow2-area size
			;print ["?Y" area minArea size/y]
			not all [
				area <= minArea
				size/y <= 8192
			]
		]
		
		;print "-----------"
		;probe minArea
		minResult
	]

	set 'rectangle-pack func[
		"Takes block of sizes and ids and tries to pack them to specified area, returns block with placed and skiped data"
		size-data   [block!] "block with [size1 id1 size2 id2 ...]"
		target-area [pair! ] "Size of the target area"
		/method sort-method 
		/local placed skiped free-bins free-area placed? rw rh rx ry width height
	][
		if verbose > 0 [print ["RECTPACK to size:" target-area]]
		sort/compare/skip size-data func[a b /local oa ob][
			switch/default sort-method [
				2 [
					;precedence: side Y
					case [
						a/y < b/y [ 1]
						a/y > b/y [-1]
						a/x < b/x [ 1]
						a/x > b/x [-1]
						true      [ 0]
					]
				]
				3 [
					;predecence: area
					case[
						(oa: a/x * a/y) > (ob: b/x * b/y) [-1]
						oa < ob                           [ 1]
						true                              [ 0]
					]
				]
				4 [
					;precedence: any side's size
					case[
						(oa: max a/x a/y) > (ob: max b/x b/y) [-1]
						oa < ob                           [ 1]
						true                              [ 0]
					]
				]
			][;default = 1:
				;precedence: side X
				case [
					a/x < b/x [ 1]
					a/x > b/x [-1]
					a/y < b/y [ 1]
					a/y > b/y [-1]
					true      [ 0]
				]
			]
		] 2
		
		placed:    copy []
		skiped:    copy []
		free-bins: reduce [target-area/x target-area/y 0 0]
		
		foreach [size id] size-data [
			free-bins: head free-bins
			placed?: false
			while [not tail? free-bins][
				set [rw rh rx ry] free-bins
				width:  size/x + padding/x
				height: size/y + padding/y
				either all [
					width <= rw
					height <= rh
				][
					repend placed [as-pair rx ry size id]
					placed?: true
					change/part free-bins reduce either (rw  - width) > (rh - height) [
						[
							free-bins/1 - width
							free-bins/2
							free-bins/3 + width
							free-bins/4
							width
							free-bins/2 - height
							free-bins/3
							free-bins/4 + height
						]
					][
						[
							free-bins/1 - width
							height
							free-bins/3 + width
							free-bins/4
							free-bins/1
							free-bins/2 - height
							free-bins/3
							free-bins/4 + height
						]
					] 4
					break
				][
					free-bins: skip free-bins 4
				]
			]
			unless placed? [
				;print ["NOT FOUND SPACE FOR:" size "^/^-" id]
				repend skiped [size id]
			]
		]
		free-area: 0
		foreach [rw rh rx ry] free-bins [
			free-area: free-area + (rw * rh)
		]

		new-line/skip placed true 3
		reduce [placed skiped free-area]
	]
]

