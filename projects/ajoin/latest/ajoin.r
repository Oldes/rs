REBOL [
    Title: "Ajoin"
    Date: 16-Sep-2007/15:16:29+2:00
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

unless value? 'ajoin [
	ajoin: func[
		"Faster way how to create string from a block (in R3 it's native!)"
		block [block!]
	][make string! reduce block]
]

unless value? 'abin [
	abin: func[
		"faster binary creation of a block"
		block
	][
		head insert copy #{}reduce block
	]
]