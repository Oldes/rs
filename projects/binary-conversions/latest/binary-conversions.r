REBOL [
    Title: "Binary-conversions"
    Date: 25-Dec-2007/16:27:56+1:00
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
]

either value? 'rebcode [
	int-to-ui8: rebcode [val [integer!] /local tmp result][
		copy result #{00} -1
		and    val 255
		poke result 1 val
		return result
	]
	
	int-to-ui16: rebcode [val [integer!] /local tmp result][
		copy result #{0000} -1
		set  tmp 0
		
		set.i  tmp val
		and    tmp 255
		poke result 1 tmp
		
		set.i  tmp val
		lsr    tmp 8
		and    tmp 255
		poke result 2 tmp
		
		return result
	]
	
	int-to-ui32: rebcode [val [integer!] /local tmp result][
		;to-int val
		copy result #{00000000} -1
		set  tmp 0
		
		set.i  tmp val
		and    tmp 255
		poke result 1 tmp
		
		set.i  tmp val
		lsr    tmp 8
		and    tmp 255
		poke result 2 tmp
		
		set.i  tmp val
		lsr    tmp 16
		and    tmp 255
		poke result 3 tmp
		
		set.i  tmp val
		lsr    tmp 24
		and    tmp 255
		poke result 4 tmp
		
		return result
	]
	int-to-bits: func[i [number!] bits][skip enbase/base head reverse int-to-ui32 i 2 32 - bits]
][
	if error? try [
		ui32-struct: make struct! [value [integer!]] none
		ui16-struct: make struct! [value [short]] none
		int-to-ui32:   func[i][ui32-struct/value: to integer! i copy third ui32-struct]
		int-to-ui16: func[i][ui16-struct/value: to integer! i copy third ui16-struct]
		int-to-ui8: func[i][ui16-struct/value: to integer! i copy/part third ui16-struct 1]
		int-to-bits: func[i [number!] bits][skip enbase/base head reverse int-to-ui32 i 2 32 - bits]
	][
		;for Rebol versions where the struct! datatype is not available
		int-to-ui32: func[i [number!]][head reverse load rejoin ["#{" to-hex to integer! i "}"]]
		int-to-ui16: func[i [number!]][head reverse load rejoin ["#{" skip mold to-hex to integer! i 5 "}"]]
		int-to-ui8:  func[i [number!]][load rejoin ["#{" skip mold to-hex to integer! i 7 "}"]]
		int-to-bits: func[i [number!] bits][skip enbase/base load rejoin ["#{" to-hex to integer! i "}"] 2 32 - bits]
	]
]

issue-to-binary: func[clr] [debase/base clr 16]
issue-to-decimal: func[i [issue!] /local e d][
	i: head reverse issue-to-binary i
	e: 0 d: 0
	forall i [
		d: d + (i/1 * (2 ** e))
		e: e + 8
	]
	d
]
tuple-to-decimal: func[t [tuple!] /local e d][
	t: head reverse to-binary t
	e: 0 d: 0
	forall t [
		d: d + (t/1 * (2 ** e))
		e: e + 8
	]
	d
]

to-ieee64f: func [
	"Conversion of number to IEEE (Flash byte order)"
	value [number!]
	/local tmp
][
	insert tail tmp: third make struct! [f [double]] reduce [value] copy/part tmp 4
	return remove/part tmp 4
]
from-ieee64f: func [
	"Conversion of number from IEEE (Flash byte order)"
	bin [binary!]
	/local tmp
][
	change third tmp: make struct! [f [double]] [0] remove/part head insert tail bin: copy bin copy/part bin 4 4
	tmp/f
]
from-ieee64: func [
	"Conversion of number from IEEE"
	bin [binary!]
	/local tmp
][
	change third tmp: make struct! [f [double]] [0] bin
	tmp/f
]