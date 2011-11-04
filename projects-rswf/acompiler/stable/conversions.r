rebol []

if error? try [
	ui32-struct: make struct! [value [integer!]] none
	ui16-struct: make struct! [value [short]] none
	int-to-ui32: func[i][ui32-struct/value: to integer! i copy third ui32-struct]
	int-to-ui16: func[i][ui16-struct/value: to integer! i copy third ui16-struct]
	int-to-ui8: func[i][ui16-struct/value: to integer! i copy/part third ui16-struct 1]
	int-to-bits: func[i [number!] bits][skip enbase/base reverse int-to-ui32 i 2 32 - bits]
][
	;for Rebol versions where the struct! datatype is not available
	int-to-ui32: func[i [number!]][reverse load rejoin ["#{" to-hex to-integer i "}"]]
	int-to-ui16: func[i [number!]][reverse load rejoin ["#{" skip mold to-hex to integer! i 5 "}"]]
	int-to-ui8:  func[i [number!]][load rejoin ["#{" skip mold to-hex to integer! i 7 "}"]]
	int-to-bits: func[i [number!] bits][skip enbase/base load rejoin ["#{" to-hex to integer! i "}"] 2 32 - bits]
]


issue-to-binary: func[clr] [debase/base clr 16]
issue-to-decimal: func[i [issue!] /local e d][
	i: reverse issue-to-binary i
	e: 0 d: 0
	forall i [
		d: d + (i/1 * (2 ** e))
		e: e + 8
	]
	d
]
tuple-to-decimal: func[t [tuple!] /local e d][
	t: reverse to-binary t
	e: 0 d: 0
	forall t [
		d: d + (t/1 * (2 ** e))
		e: e + 8
	]
	d
]
