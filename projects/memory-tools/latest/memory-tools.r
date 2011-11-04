REBOL [
    Title: "Memory-tools"
    Date: 13-Jul-2003/12:28:53+2:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "Ladislav Mecir"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: [
	   	a: "123^(0)45"
	    adr: address? a
	   	get-mem? adr ; == #"1"
	    get-mem? adr + 1 ; == #"2"
	    get-mem? adr + 2 ; == #"3"
	    get-mem? adr + 3 ; == #"^@"
	    get-mem? adr + 4 ; == #"4"
	    get-mem? adr + 5 ; == #"5"
	    get-mem? adr + 6 ; == #"^@"
	    get-mem?/nts adr ; == "123"
	    get-mem?/part adr 7 ; == "123^@45^@"
	    set-mem adr + 1 #"a" ; == #"a"
	    a ; == "1a3^@45"
	]
    Purpose: none
    Comment: {taken from Rebol's mail-list discussion by Oldes (thread: "External library interface")}
    History: none
    Language: none
    Type: none
    Content: none
    Email: lmecir@mbox.vol.cz
]

probe-mem: func[
	address [binary!]
	length	[integer!]
	/local m
][
	m: head insert/dup copy [] [. [char!]] length
	m: make struct! compose/deep [bin [struct! (reduce [m])]] none
	change third m address
	probe third m/bin
	free m
]
address?: function [
    {get the address of a string}
    s [any-string!]
] [address] [
    s: make struct! [s [string!]] reduce [s]
    address: make struct! [i [integer!]] none
    change third address third s
    address/i
]

get-mem?: function [
    {get the byte from a memory address}
    address [integer!]
    /nts {a null-terminated string}
    /part {a binary with a specified length}
    length [integer!]
] [m] [
    address: make struct! [i [integer!]] reduce [address]
    if nts [
        m: make struct! [s [string!]] none
        change third m third address
        return m/s
    ]
    if part [
        m: head insert/dup copy [] [. [char!]] length
        m: make struct! compose/deep [bin [struct! (reduce [m])]] none
        change third m third address
        return to string! third m/bin
    ]
    m: make struct! [c [struct! [chr [char!]]]] none
    change third m third address
    m/c/chr
]

set-mem: function [
    {set a byte at a specific memory address}
    address [integer!]
    value [char!]
] [m] [
    address: make struct! [i [integer!]] reduce [address]
    m: make struct! [c [struct! [chr [char!]]]] none
    change third m third address
    m/c/chr: value
]

make-array: func [length [integer!] spec [block!] "eg: [ch [char!]]" /local result][
	result: copy []
	repeat n length [foreach [name type] spec [repend result [to-word join name n type]]]
	result
]