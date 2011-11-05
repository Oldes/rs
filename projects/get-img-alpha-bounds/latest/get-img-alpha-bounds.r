REBOL [
    Title: "Get-img-alpha-bounds"
    Date: 30-Nov-2010/10:51:04+1:00
    Author: "Oldes"
	purpose: {finds the smallest area which contains alpha information (not transparent)}
]
get-img-alpha-bounds: func[
	{Returns the smallest area which contains alpha information (not transparent)
	 in format [ofsx ofsy width height]}
	img [image!] "Image to examine"
	/local h w h- w- c r p vertical-b horizontal-b
][
	h: img/size/y
	w: img/size/x
	w-: w - 1
	h-: h - 1
	horizontal-b: copy []
	c: 0
	parse/all/case img/alpha [
		w [
			p: [
				h- [#{FF} w- skip] #{FF} (c: c + 1) [end | (p: next p) :p]
				|
				(
					either c > 0 [
						append horizontal-b c
						c: 0
					][	if empty? horizontal-b [insert horizontal-b 0] ]
					p: next p
				) :p
			]
		]
		(
			if c > 0 [append horizontal-b c]
			if 2 > length? horizontal-b [append horizontal-b 0]
		) to end
	]
	vertical-b: copy []
	r: 0
	parse/all/case img/alpha [
		h [
			[
				w #{FF} (r: r + 1)
				|
				w skip  (
					either r > 0 [
						append vertical-b r
						r: 0
					][	if empty? vertical-b [insert vertical-b 0] ]
				)
			]
		]
		(
			if r > 0 [append vertical-b r]
			if 2 > length? vertical-b [append vertical-b 0]
		)
	]
	;probe vertical-b
	;probe horizontal-b
	reduce [
		first horizontal-b
		first vertical-b
		img/size/x - (first horizontal-b) - (last horizontal-b)
		img/size/y - (first vertical-b)   - (last vertical-b)
	]
]