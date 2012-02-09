REBOL [
    Title: "UTF-8"
    Date: 1-Jun-2004/13:24:26+2:00
    Name: "UTF-8"
    Version: 1.0.2
    File: %utf-8.r
    Author: "Jan Skibinski"
	Co-author: "Oldes"
    Purpose: {Encoding and decoding of UCS-4/UC-2 binaries
to and from UTF-8 binaries.
}
    History: [
    	1.0.2 01-Jun-2004 {
    	Oldes: Removed to-ucs2 function as I'm now using my UCS2 object to encode strings according given charmaps
    	}
		1.0.1 26-Nov-2002 {
		Oldes: Speed optimalizations (not so readable now:(
		+ fixed to-ucs2 function}
		1.0.0 20-Nov-2002 {
		Jan: Basic UTF-8 encoding and decoding functions.
        Limitations: Does not handle a big/little endian
        signatures yet. Needs thorough testing and algorithms
        optimalizations.}
	]
    Email: [jan.skibinski@sympatico.ca oliva.david@seznam.cz]
    Category: [crypt 4]
    Acknowledments: {
        Inspired by the script 'utf8-encode.r of Romano Paulo Tenca
        and Oldes, which encodes Latin-1 strings.
    }
]
comment {
    UCS means: Universal Character Set (or Unicode)
    UCS-2 means: 2-byte representation of a character in UCS.
    UCS-4 means: 4-byte representation of a character in UCS.
    UTF-8 means: UCS Transformation Format using 8-bit octets.

    The following excerpt from:
        UTF-8 and Unicode FAQ for Unix/Linux, by Markus Kuhn
        http://www.cl.cam.ac.uk/~mgk25/unicode.html
    provides motivations for using UTF-8.

    <<Using UCS-2 (or UCS-4) under Unix would lead to very severe
    problems. Strings with these encodings can contain as parts
    of many wide characters bytes like '\0' or '/' which have a
    special meaning in filenames and other C library function
    parameters. In addition, the majority of UNIX tools expects
    ASCII files and can't read 16-bit words as characters without
    major modifications. For these reasons, UCS-2 is not a suitable
    external encoding of Unicode in filenames, text files,
    environment variables, etc.

    The UTF-8 encoding defined in ISO 10646-1:2000 Annex D
    and also described in RFC 2279 as well as section 3.8
    of the Unicode 3.0 standard does not have these problems.
    It is clearly the way to go for using Unicode under Unix-style
    operating systems.>>

    The copy of forementioned Annex D can be found on Markus site:
    http://www.cl.cam.ac.uk/~mgk25/ucs/ISO-10646-UTF-8.html.
    Encoding and decoding functions implemented here are
    based on the descriptions of algorithms found in the Annex D.

    Testing: The page http://www.cl.cam.ac.uk/~mgk25/unicode.html
    has many pointers to variety of test data. One of them
    is a UTF-8 sampler from Kermit pages of Columbia University
    http://www.columbia.edu/kermit/utf8.html, where the
    phrase "I can eat glass and it doesn't hurt me." is
    produced in dozens of world languages.
    
    A shareware unicode editor 'EmEditor, from www.emurasoft.com
    can be used for copying, editing and saving unicode samples 
    from the web browsers. Since it saves its output in UCS-2, 
    UCS-4 (big and little endians), UTF-8 and UTF-7 formats
    it is a very good tool for testing.

}

comment {
------------------------------------------------------------
SUMMARY of script UTF-8.R
------------------------------------------------------------
decode-2             (binary -> binary)
encode-2             (binary -> binary)

decode-4             (binary -> binary)
encode-4             (binary -> binary)

decode-integer       (binary -> [integer integer])
encode-integer       (integer -> binary)

}

utf-8: context [
	allchars: complement charset []
	
    encode-2: func [
        {
        Encode a binary string of UCS-2 octets into a UTF-8
        encoded binary octet stream.
        }
        us [binary!]
        /local x result [binary!]
    ][
        result: copy #{}
        while [not tail? us][
            x: (256 * first us) + second us
            insert tail result encode-integer x
			us: skip us 2
        ]
        result
    ]

    encode-4: func [
        {
        Encode a binary string of UCS-4 octets into a UTF-8
        encoded binary octet stream.
        }
        us [binary!]
        /local x result [binary!]
    ][
        result: copy #{}
        while [not tail? us][
            x:  (16777216 * first us) + (65536 * second us) + (256 * third us) + fourth us
            insert tail result encode-integer x
            us: skip us 4
        ]
        result
    ]


    decode-2: func [
        {
        Decode a UTF-8 encoded binary string
        to a UCS-2 binary string
        }
        xs [binary!]
        /local z vs us result [binary!]
    ][
        result: copy #{}
        while [not tail? xs][
            us: decode-integer xs
            vs: copy []
            z: to integer! ((first us) / 256)
            insert vs z
            z: (first us) - (z * 256)
            insert tail vs z
            insert tail result to binary! vs
            xs: skip xs second us
        ]
        result
    ]


    decode-4: func [
        {
        Decode a UTF-8 encoded binary string
        to UCS-4 binary string
        }
        xs [binary!]
        /local z1 z vs us result [binary!]
    ][
        result: copy #{}
        while [not tail? xs][
            us: decode-integer xs
            vs: copy []
            z: us/1
            foreach k [16777216 65536 256][
                z1: to integer! (z / :k)
                insert tail vs z1
                z: z - (z1 * :k)
            ]
            insert tail vs z

            insert tail result to binary! vs
            xs: skip xs second us
        ]
        result
    ]
    
    encode-integer: func [
        {
        Encode 4-byte (32-bit) UCS-4 integer to a sequence
        of UTF-8 octets.
        }
        [throw]
        x [integer!]
        /local f k result [binary!]
    ][
        k: 1 loop 6 [
            if x <= encases/:k [
                result: to binary! enf :k x
                break
            ]
			k: k + 1
        ]
        result
    ]

    decode-integer: func [
        {
        Decode sequence of 1-6 octets into 32-bit unsigned
        integer. Return a pair made of a decoded integer
        and a count of bytes used from the input string.
        }
        xs [binary!]
        /local f k result [block!]
    ][
        k: 1 loop 6 [
           if (first xs) <= pick decases k [
                result: to block! def :k xs
                insert tail result :k
                break
           ]
		   k: k + 1
        ]
        result

    ]
    
	;-----functions and values extracted from the decode/encode integer
    enf: func [
	   k x
       /local result
    ][
		result: to block! (us/:k + to integer! (x / vs/:k))
		if k > 1 [
			for z (k - 1) 1 -1 [
				insert tail result (
				(to integer! (x / vs/:z)) // 64 + 128)
			]
		]
		result
    ]
    def: func [
            k xs
            /local m result
        ][
            result: ((first xs) - us/:k) * vs/:k
            if k >= 2 [
                for z 2 k 1 [
                    m: k - :z + 1
                    result: result + ((xs/:z - 128) * vs/:m)
                ]
            ]
            result
        ]
    us: [0 192 224 240 248 252]
    vs: [1 64 4096 262144 16777216 1073741824]
    encases: [
             127         ; 0000 007F
             2047        ; 0000 07FF
             65535       ; 0000 FFFF
             2097151     ; 0001 FFFF
             67108863    ; 03FF FFFF
             2147483647  ; 7FFF FFFF
    ]
    decases: [127 223 239 247 251 253]
]


                                                                                                                                                                                                                                                                                 