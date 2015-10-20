REBOL [
    Title: "Url-encode"
    Date: 4-Aug-2003/18:56:29+2:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "unknown"
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
    Email: none
]

url-encode: func [
    "URL-encode a string" 
    data "String to encode" 
    /local new-data normal-chars tmp
][
    unless any [string? data binary? data] [return data] 
    new-data: copy "" 
    normal-chars: charset [
        #"A" - #"Z" #"a" - #"z" 
        #"@" #"." #"*" #"-" #"_" 
        #"0" - #"9"
    ] 
    parse/all data [any[
    	  copy tmp some normal-chars (insert tail new-data tmp)
    	| copy tmp some #" " (insert/dup tail new-data #"+" length? tmp)
    	| copy tmp 1 skip (
    		insert tail new-data rejoin ["%" as-string skip tail (to-hex to integer! to char! tmp) -2]
    	)
	]]
    new-data
]