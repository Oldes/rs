REBOL [
    Title: "CRC32"
    Date: 27-Oct-2003/11:11:13+1:00
    Name: none
    Version: 0.0.1
    File: none
    Home: none
    Author: "oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: {
    	crc32/count "some data"
    }
    Purpose: {
    	To count CRC32 used in PNG file format
    }
    Comment: {
    	Why it's not possible to use native version from Rebol?
    	There must be this function in C because Rebol is saving images as PNG!
    }
    History: none
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
]

crc32: make object! [
	magic-number: #{edb88320}
	to-ulong:  func[v][
		v: to binary! v
		v: either #{80000000} = and v #{80000000} [
			2147483648 + to integer! (and v #{7FFFFFFF})
		][	to integer! v]
	]
	int-to-bin: func[i][
		if binary? i [return i]
		copy load rejoin ["#{" to-hex to integer! i "}"]
	]
	rshift: func[i n][
		debase/base head (
			insert/dup head (
				remove/part tail (
					enbase/base (int-to-bin i) 2
				) (negate n)
			) "0" n
		) 2
	]
	crc_table: make block! 256
	make_crc_table: func["Makes the table for a fast CRC." /local c][
		repeat n 256 [
			c: int-to-bin ( n - 1 )
			loop 8 [
				either (c and #{00000001}) = #{00000001} [
					c: (xor (rshift c 1) magic-number)
	        	][
					c: (rshift c 1)
				]
	    	]
	        insert tail crc_table c
	    ]
	]
	make_crc_table
	
	update_crc: func[
		{Update a running CRC with the bytes buf[0..len-1]--the CRC
	     should be initialized to all 1's, and the transmitted value
	     is the 1's complement of the final running CRC (see the
	     crc() routine below)).}
	    crc buf len
	    /local c
	][
		c: crc
		loop len [
			c: (pick crc_table 1 + to integer! ((c xor (join #{000000} buf/1)) and #{000000FF})) xor (rshift c 8)
			buf: next buf
		]
		buf: head buf
	    return int-to-bin c
	]
	
	count: func[
		{Return the CRC of the bytes buf[0..len-1].}
		buf
	][
		xor (update_crc #{ffffffff} buf length? buf) #{ffffffff}
	]
	 
]