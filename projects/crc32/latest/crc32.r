REBOL [
    Title: "CRC-32"
    Date: 6-Apr-2006
    Version: 1.1.0
    File: %crc32.r
    Author: "Vincent Ecuyer"
    Purpose: "CRC32 checksum function"
    Usage: {
        Calculates a 32 bits cyclic redundancy code as used
        in gzip/pkzip/etc. 
        
        Returns a binary:
        >> crc-32 "a string"
        == #{99A255DA}

        >> crc-32 #{112233445566}
        == #{345913D6}

        or an integer:
        >> crc-32/integer "a string"
        == -1717414438

        To compute the checksum part by part:
        >> crc-32 "a str"
        == #{61AD7C35}
        >> crc-32/continue "ing" #{61AD7C35}
        == #{99A255DA}

        >> crc-32/continue data none
        is a synonym of:
        >> crc-32 data

        Usage of /continue in a loop:
        ; initial crc
        crc: none
        until [
            ...
            ; a new crc is computed from the previous one and the new data
            crc: crc-32/continue data-part crc
            ...
        ]
        ; at the end of this loop, 'crc holds the crc-32 of the whole data

        The /direct mode, with a specified buffer size,
        works directly on files (useful for big files):
        ; calculates the checksum of a remote file with a 64 kb buffer
        >> crc-32/direct ftp://192.168.1.33/rebol.exe 64 * 1024
        == #{67AD9CF6}

        Note: In the case of a file access error, connection timeout, or an
        execution halted by the user, the opened file can still be locked.
        Any new invocation of 'crc-32 will release (close) the file and clear
        the internal buffer. Example:
        >> crc-32 ""
    }
    Comment: {
        Contains a precalculated table for speedup.

        REBOL VM isn't really suited for fast bitwise operations, so this
        code is quite slow. If the rebcode VM is available, it's used to
        achieve a more usable speed (between checksum/method 'md5 and
        checksum/method 'sha1).
    }

    Library: [
        level: 'advanced
        platform: 'all
        type: [module function rebcode]
        domain: [math security]
        tested-under: [
            core 2.6.2.3.1 on [Win2K]
            view 1.3.2.3.1 on [Win2K]
            view 1.3.61.3.1 on [Win2K]
            base 2.5.4.3.1 on [Win2K]
            view 1.2.1.1.1 on [AmigaOS30]
            core 2.5.0.1.1 on [AmigaOS30]
        ]
        support: none
        license: 'bsd
        see-also: %rebzip.r
    ]
    History: [
        1.0.0 26-3-2006
            "First published version"
        1.1.0 6-4-2006
            "/direct mode, /continue and /integer added"
    ]
]
ctx-crc-32: context [
    crc-long: [
                 0   1996959894  -301047508 -1727442502   124634137  1886057615
        -379345611  -1637575261   249268274  2044508324  -522852066 -1747789432
         162941995   2125561021  -407360249 -1866523247   498536548  1789927666
        -205950648  -2067906082   450548861  1843258603  -187386543 -2083289657
         325883990   1684777152   -43845254 -1973040660   335633487  1661365465
         -99664541  -1928851979   997073096  1281953886  -715111964 -1570279054
        1006888145   1258607687  -770865667 -1526024853   901097722  1119000684
        -608450090  -1396901568   853044451  1172266101  -589951537 -1412350631
         651767980   1373503546  -925412992 -1076862698   565507253  1454621731
        -809855591  -1195530993   671266974  1594198024  -972236366 -1324619484
         795835527   1483230225 -1050600021 -1234817731  1994146192    31158534
       -1731059524   -271249366  1907459465   112637215 -1614814043  -390540237
        2013776290    251722036 -1777751922  -519137256  2137656763   141376813
       -1855689577   -429695999  1802195444   476864866 -2056965928  -228458418
        1812370925    453092731 -2113342271  -183516073  1706088902   314042704
       -1950435094    -54949764  1658658271   366619977 -1932296973   -69972891
        1303535960    984961486 -1547960204  -725929758  1256170817  1037604311
       -1529756563   -740887301  1131014506   879679996 -1385723834  -631195440
        1141124467    855842277 -1442165665  -586318647  1342533948   654459306
       -1106571248   -921952122  1466479909   544179635 -1184443383  -832445281
        1591671054    702138776 -1328506846  -942167884  1504918807   783551873
       -1212326853  -1061524307  -306674912 -1698712650    62317068  1957810842
        -355121351  -1647151185    81470997  1943803523  -480048366 -1805370492
         225274430   2053790376  -468791541 -1828061283   167816743  2097651377
        -267414716  -2029476910   503444072  1762050814  -144550051 -2140837941
         426522225   1852507879   -19653770 -1982649376   282753626  1742555852
        -105259153  -1900089351   397917763  1622183637  -690576408 -1580100738
         953729732   1340076626  -776247311 -1497606297  1068828381  1219638859
        -670225446  -1358292148   906185462  1090812512  -547295293 -1469587627
         829329135   1181335161  -882789492 -1134132454   628085408  1382605366
        -871598187  -1156888829   570562233  1426400815  -977650754 -1296233688
         733239954   1555261956 -1026031705 -1244606671   752459403  1541320221
       -1687895376   -328994266  1969922972    40735498 -1677130071  -351390145
        1913087877     83908371 -1782625662  -491226604  2075208622   213261112
       -1831694693   -438977011  2094854071   198958881 -2032938284  -237706686
        1759359992    534414190 -2118248755  -155638181  1873836001   414664567
       -2012718362    -15766928  1711684554   285281116 -1889165569  -127750551
        1634467795    376229701 -1609899400  -686959890  1308918612   956543938
       -1486412191   -799009033  1231636301  1047427035 -1362007478  -640263460
        1088359270    936918000 -1447252397  -558129467  1202900863   817233897
       -1111625188   -893730166  1404277552   615818150 -1160759803  -841546093
        1423857449    601450431 -1285129682 -1000256840  1567103746   711928724
       -1274298825  -1022587231  1510334235   755167117
    ]

    right-shift-8: func [
        "Right-shifts the value by 8 bits and returns it."
        value [integer!] "The value to shift"
    ][
        either negative? value [
            -1 xor value and -256 / 256 xor -1 and 16777215
        ][
            -256 and value / 256
        ]
    ]

    update-crc: either value? 'rebcode [
        rebcode [
            "Returns the data crc."
            data [any-string!] "Data to checksum"
            crc [integer!] "Initial value"
            /local char i
        ][
            tail? data
                iff [
                    until [
                        pick char data 1
                        set.i i crc
                        xor i char
                        and i 255
                        lsr crc 8
                        pickz i crc-long i
                        xor crc i
                        next data
                        tail? data
                    ]
                ]
                return crc
        ]
    ][
        func [
            "Returns the data crc."
            data [any-string!] "Data to checksum"
            crc [integer!] "Initial value"
        ][
            foreach char data [
                 crc: (right-shift-8 crc) xor pick crc-long crc and 255 xor char + 1
            ]
            crc
        ]
    ]

    any-file?: func [
        "Returns TRUE for file and url values." value [any-type!]
    ][any [file? value url? value]]

    file: none
    buffer: none

    set 'crc-32 func [
        "Returns a CRC32 checksum."
        source [binary! string! file! url!] "Data or file to checksum"
        /direct "For file! and url! sources, uses /direct mode"
            buffer-size [integer!] "Buffer size (in bytes)"
        /integer "Returns an integer! instead of a binary!"
        /continue "Continues a checksum with more data"
            crc [integer! binary! none!] "Previous CRC32 value."
    ][
        crc: -1 xor to-integer any [crc 0]
        if file   [error? try [close file  ] file:   none]
        if buffer [error? try [clear buffer] buffer: none]
        either all [direct any-file? source] [
            file: source: open/direct/read/binary source
            buffer: make binary! buffer-size
            until [
                clear buffer
                read-io source buffer buffer-size
                crc: update-crc buffer crc
                wait 0.002
                zero? length? buffer
            ]
            clear buffer
            close source
            buffer: file: source: none
        ][
            if any-file? source [source: read/binary source]
            crc: update-crc source crc
            source: none
        ]
        either integer [-1 xor crc][
            load join "#{" [to-hex -1 xor crc "}"]
        ]
    ]
]

; Verification
either #{CBF43926} <> crc-32 "123456789" [
    make error! "Test failed - CRC-32 doesn't work with this VM."
][true]