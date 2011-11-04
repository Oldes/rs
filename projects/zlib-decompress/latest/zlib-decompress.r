REBOL [
    Title: "Zlib-decompress"
    Date: 24-Dec-2007/15:24:56+1:00
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

zlib-decompress: func[
	zlibData [binary!]
	length [integer!] "known uncompressed zlib data length"
][
	decompress head insert tail zlibData third make struct! [value [integer!]] reduce [length]
]