REBOL [
    Title: "Rectangle-pack"
    Date: 27-Oct-2010/13:17:35+2:00
    Name: 'rectangle-pack
    Version: 1.0.0
    File: %rectangle-pack.r
    Home: http://box.lebeda.ws/~hmm/rebol/rectangle-pack.r
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
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
rectangle-pack: func[
	"Takes block of sizes and ids and tries to pack them to specified area, returns block with placed and skiped data"
	size-data   [block!] "block with [size1 id1 size2 id2 ...]"
	target-area [pair! ] "Size of the target area"
	/local placed skiped free-bins placed? rw rh rx ry width height
][
	sort/compare/skip size-data func[a b /local oa ob][
		;comment {
			;unused sorting based on sides
			case [
				a/x < b/x [ 1]
				a/x > b/x [-1]
				a/y < b/y [ 1]
				a/y > b/y [-1]
				true      [ 0]
			]
			
		;	case[
		;		(oa: a/x * a/y) > (ob: b/x * b/y) [-1]
		;		oa < ob                           [ 1]
		;		true                              [ 0]
		;	]
		;}
		;case[
		;	(oa: max a/x a/y) > (ob: max b/x b/y) [-1]
		;	oa < ob                           [ 1]
		;	true                              [ 0]
		;]
	] 2
	
	placed:    copy []
	skiped:    copy []
	free-bins: reduce [target-area/x target-area/y 0 0]
	
	foreach [size id] size-data [
		free-bins: head free-bins
		placed?: false
		while [not tail? free-bins][
			set [rw rh rx ry] free-bins
			width:  size/x + 2
			height: size/y + 2
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
	new-line/skip placed true 3
	reduce [placed skiped]
]


