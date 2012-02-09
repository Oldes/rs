REBOL [
    Title: "HTML-entities" 
    Date: 9-Apr-2008/13:18:16+2:00 
    Name: none 
    Version: 0.2.0 
    File: %htmlentities.r 
    Home: none 
    Author: "Oldes" 
    Owner: none 
    Rights: none 
    Needs: none 
    Tabs: none 
    Usage: [
        probe HTMLentities/decode {&lt;&eacute;lan&gt; a &#60;&#233;lan&#62; a &#x3c;&#xe9;lan&#x3e; Invalid: &test; &#xx; &}
    ] 
    Purpose: none 
    Comment: "Contains only DECODE function now" 
    History: [
        0.2.0 [9-Apr-2008 "oldes" "fixed bug in handling of invalid entities"] 
        0.1.0 [9-Apr-2008 "oldes" "first version with support for decoding"]
    ] 
    Language: none 
    Type: none 
    Content: none 
    Email: oliva.david@seznam.cz 
    preprocess: true 
    require: [
		rs-project 'utf-8
	]
] 

HTMLentities: context [
    ch_EntChars: charset [#"a" - #"z" #"A" - #"Z"] 
    ch_Digits: charset "0123456789" 
    ch_Hexa: union ch_Digits charset [#"a" - #"f" #"A" - #"F"] 
    Entities-to-UTF8: make hash! #include-block %entities-to-utf8.rb
    decode: func [
        "Decodes HTML entities into UTF8 chars" 
        str [string! binary!] "UTF8 encoded string with HTML entities to decode" 
        /local tmp ent pos cont result
    ] [
        result: make binary! length? str 
        parse/all/case str [
            any [
                pos: 
                "&" [
                    copy ent some ch_EntChars ";" cont: (
                        either ent: select/case/skip Entities-to-UTF8 ent 2 [
                            insert tail result ent
                        ] [
                            print ["Unknown HTML entity near:" mold copy/part pos 20] 
                            insert tail result "&" 
                            cont: next pos
                        ]
                    ) 
                    | 
                    "#x" copy ent some ch_Hexa ";" cont: (
                        either ent: debase/base (head insert/dup ent #"0" (length? ent) // 2) 16 [
                            insert tail result utf-8/encode-integer to integer! ent
                        ] [
                            print ["Invalid hexadecimal HTML entity near:" mold copy/part pos 20] 
                            insert tail result "&" 
                            cont: next pos
                        ]
                    ) 
                    | 
                    "#" copy ent some ch_Digits ";" cont: (
                        insert tail result utf-8/encode-integer to integer! ent
                    ) 
                    | cont: (insert tail result "&")
                ] :cont 
                | 
                copy tmp to "&" (insert tail result tmp)
            ] 
            copy tmp to end (
                if tmp [insert tail result tmp]
            )
        ] 
        as-string result
    ]
]