REBOL [
    Title: "Functions for converting and exchanging decimal values"
    File:  %decimal.r
    Author: "Eric Long"
    Email: kgd03011@nifty.ne.jp
    Co-Authors: ["Larry Palmiter" "Gerald Goertzel" "Oldes"]
    Date: 7-Jan-2012
    Category: [math util 4]
    Version: 1.0.1
	History: [
		1.0.0 15-Feb-2000 "Original Eric's version"
		1.0.1 7-Jan-2012 "Added real/to-native32 function"
	]
    Purpose: {
        Contains functions for the manipulation of decimal values,
        packaged into the REAL object. These provide full support for
        native binary floating-point file IO, compatible with C,
        FORTRAN, etc. REBOL decimal and money values may also be saved
        and loaded with no roundoff error. This package is necessary
        because the standard REBOL representation of decimal values
        may round off one or two significant digits, and the rounding
        of money values is an even greater source of error.

        This script contains two more objects, IEEE and EMPIRICAL,
        which provide several functions useful for exploring how
        decimal values are represented as double floating point numbers,
        and for testing the inexactness of the REBOL comparison functions.
    }
    Dependencies: [
        {The following require %format.r to properly format the output,
        though they will work without it. %format.r should be loaded
        before this script.}

        real/form
        real/show/decimal
        IEEE/rebtest
        empirical/rebtest

        {please download: } http://www.rebol.org/utility/format.r
    ]
]

comment { =============== REAL ===============

REAL is an object that packages several functions useful for examining,
saving, exporting and importing decimal values:

Main Interface Functions
FORM           Returns precise decimal representation (requires format.r).
SHOW           Returns a string showing the bits in the IEEE representation.
TO-NATIVE      Converts a decimal value into a native IEEE binary
FROM-NATIVE    Converts an 8-byte native binary into a decimal value.
SAVE           Saves a value with all decimal values converted.
LOAD           Loads a value and restores 8-byte binaries to decimals.
WRITE          Writes a block of decimal values to a file in native form.
READ           Reads a file containing a series of decimal values expressed
               in native form.

Helper Functions
SPLIT          Returns a block with the three components of the IEEE
               double floating point representation of a decimal value.
CONVERT        Converts all decimal values to native binaries, leaves other
               values untouched.
RESTORE        Restores 8-byte binaries to decimal values.
TO-BIN         Returns a binary string representation or a numeric value.
FROM-BIN       Returns the integer represented by string of 1's and 0's.
TO-MATRIX      Converts a flat block into nested blocks of any depth.

}

real: make object! [

comment { =============== REAL/FORM ===============

NOTE: Please see FULL-FORM in format.r for details.

}

; Set the word FORM in the context of this object:
; either to the function FULL-FORM if available, or else to the global FORM.

form: either value? 'full-form [:full-form][get in system/words 'form]

comment { =============== REAL/SHOW ===============

EXAMPLES:

>> real/show 2
== {0 10000000000 0000000000000000000000000000000000000000000000000000}
>> real/show 3
== {0 10000000000 1000000000000000000000000000000000000000000000000000}
>> real/show 3.5
== {0 10000000000 1100000000000000000000000000000000000000000000000000}
>> real/show 4
== {0 10000000001 0000000000000000000000000000000000000000000000000000}
>> real/show/decimal 3.5
== "0 1024 3377699720527872"          ; requires format.r

>> real/show ieee/max-real
== {0 11111111110 1111111111111111111111111111111111111111111111111111}

}

show: func [
    "return an IEEE-compatible string representation in binary"
    x  [number!]
    /decimal  "return a decimal representation"
    /local out sign exponent fraction
][
    set [sign exponent fraction] split x
    out: copy "  "
    either decimal [
        append out form fraction
        insert next out form exponent
        insert out sign
    ][
        append out to-bin/length fraction 52
        insert next out to-bin/length exponent 11
        insert out sign
    ]
    out
]

comment { =============== REAL/TO-NATIVE REAL/FROM-NATIVE ===============

EXAMPLES:

>> real/to-native pi
== #{400921FB54442D18}
>> real/to-native/rev pi
== #{182D4454FB210940}            ; configuration used in PC's
>> real/from-native real/to-native pi
== 3.14159265358979
>> pi - real/from-native real/to-native pi
== 0                              ; converts back to exact value
}

to-native: func [
    "convert a numerical value into native binary format"
    x  [number!]
    /rev     "reverse binary output"
    /local out sign exponent fraction
][
    set [sign exponent fraction] split x
    out: copy #{}
    loop 6 [
        insert out to char! byte: fraction // 256
        fraction: fraction - byte / 256
    ]
    insert out to char! exponent // 16 * 16  + fraction
    insert out to char! exponent / 16 + (128 * sign)
    return either rev [head reverse out][out]
]
to-native32: func [
    "convert a numerical value into native binary format"
    x  [number!]
    /rev     "reverse binary output"
    /local out sign exponent fraction
][
    set [sign exponent fraction] split32 x
	out: copy #{}
    loop 2 [
        insert out to char! byte: fraction // 256
        fraction: fraction - byte / 256
    ]
    insert out to char! exponent * 128 // 256  + fraction
    insert out to char! exponent / 2 + (128 * sign)
    return either rev [head reverse out][out]
]
from-native: func [
    {convert a binary native into a decimal value - also accepts a binary
    string representation in the format returned by REAL/SHOW}
    in      [binary! string!]
    /rev    "binary input in reverse order"
    /local sign exponent fraction
][
    in: copy in
    either binary? in [
        if rev [reverse in]
        sign: either zero? to integer! (first in) / 128 [1][-1]
        exponent: (first in) // 128 * 16 + to integer! (second in) / 16
        fraction: to decimal! (second in) // 16
        in: skip in 2
        loop 6 [
            fraction: fraction * 256 + first in
            in: next in
        ]
    ][
        set [sign exponent fraction] parse in none
        sign: either sign = "0" [1][-1]
        exponent: from-bin exponent
        fraction: from-bin fraction
    ]
    sign * either zero? exponent [
        2 ** -1074 * fraction
    ][
        2 ** (exponent - 1023) * (2 ** -52 * fraction + 1)
    ]
]

comment { =============== REAL/SAVE REAL/LOAD ===============

REAL/SAVE and REAL/LOAD are meant to be completely compatible
with the standard functions SAVE and LOAD, except that there
will be no roundoff error from saving and loading decimal
or money values.

EXAMPLE:

>> amount: [100 * $1.504]
== [100 * $1.50]

>> save %test-x.dat amount
>> do load %test-x.dat
== $150.00                             ; large round-off error

>> real/save %test-y.dat amount
>> do real/load %test-y.dat
== $150.40                             ; no error
}

save: func [
    {Saves a value with all decimals converted to binary natives}
    where [file! url!] "Where to save it."
    value              "Value to save."
    /header            "Save it with a header"
        header-data [block! object!] "Header block or object"
][
    either header [
        system/words/save/header where convert :value convert header-data
    ][
        system/words/save where convert :value
    ]
]

load: func [
    {Loads a value and converts binary natives to decimals}
    source [file! url! string! any-block!]
    /header "Includes REBOL header object if present"
    /next   {Load the next value only.
            Return block with value and new position.}
    /local lp
][
    lp: copy 'system/words/load
    foreach item [header next][
        if get item [insert tail :lp item]
    ]
    restore lp source
]

comment { =============== REAL/WRITE REAL/READ ===============

NOTE: REAL/WRITE and REAL/READ are meant for writing and reading
      decimal values in native binary format. REAL/WRITE accepts
      a single numerical value or a block of numerical values that
      may be nested to any depth, but the return value of REAL/READ
      is always a flat block.

EXAMPLES:

>> b1: [] for x 1 16 1 [append b1 square-root x]
== [1 1.4142135623731 1.73205080756888 2 2.23606797749979 ...
>> real/write %test.bin b1
16 decimal values written

>> bb1: real/read %test.bin
== [1 1.4142135623731 1.73205080756888 2 2.23606797749979 ...
>> b1/7 - probe bb1/7
2.64575131106459                ; square root of 7
== 0                            ; is restored exactly

>> b2: real/to-matrix b1 4      ; convert to 4x4 matrix
== [[1 1.4142135623731 1.73205080756888 2] [2.23606797749979 ...
>> real/write %test.bin b2
16 decimal values written       ; the same values are written,
>> bb2: real/read %test.bin     ; and read back into a flat block
== [1 1.4142135623731 1.73205080756888 2 2.23606797749979 ...
}

write: func [
    {Writes a (nested) block of decimal values
    to a file in native binary format}
    f [file!]          "file to write to"
    b [block! number!] "number or block of numbers"
    /rev               "reverse bytes if needed"
    /append            "append to file"
    /local out elem p to-do
][
    out: copy #{}
    to-do: copy []
    insert to-do b
    nat: to path! either rev [[to-native rev]][[to-native]]
    while [ not tail? to-do ] [
        either block? first to-do [
            change/part to-do first to-do 1
        ][
            insert tail out nat first to-do
            remove to-do
        ]
    ]
    either append [
        system/words/write/binary/append f out
    ][
        system/words/write/binary f out
    ]
    print [(length? out) / 8  "decimal values written"]
]

read: func [
    {Returns a block of numbers read in from a binary data file}
    f "file name of binary file"
    /rev "reverse bytes if needed"
    /local tmp out from l
][
    tmp: system/words/read/binary f
    l: (length? tmp) / 8
    if not zero? l - to integer! l
        [make error! "read-native: bad file size"]
    out: make block! l
    from: make path! either rev [[from-native rev]][[from-native]]
    loop l [
        insert tail out from copy/part tmp 8
        tmp: skip tmp 8
    ]
    out
]


comment { =============== REAL/SPLIT ===============

SPLIT calculates the three components of the IEEE representation of a
double floating point value. These are the actual values used by the CPU
in numerical calculations.

>> set [sign exponent fraction] real/split pi
== [0 1024 2.57063812465794E+15]
>> (-1 ** sign) * (2 ** (exponent - 1023)) * (1 + (fraction * (2 ** -52)))
== 3.14159265358979

Numbers smaller than 2 ** -1022 (denormals, which have an exponent
component of zero) use a different formula:

>> set [sign exponent fraction] real/split probe 2 ** -1030
8.69169475979376E-311
== [0 0 17592186044416]
>> (-1 ** sign) * (2 ** -1074) * fraction
== 8.69169475979376E-311
}

split: func [
    "Returns block containing three components of double floating point value"
    x [number!] /local sign exponent fraction
][
    sign: either negative? x [x: (- x) 1][0]

    either zero? x [exponent: 0  fraction: 0][

        either zero? 1024 - exponent: to integer! log-2 x [exponent: 1023][
            if positive? (2 ** exponent) - x [exponent: exponent - 1]
        ]
        fraction: x / (2 ** exponent)

        either positive? exponent: exponent + 1023 [
            fraction: fraction - 1         ; drop the first bit for normals
            fraction: fraction * (2 ** 52) ; make the remaining fraction an
                                           ; "integer"
        ][
            fraction: 2 ** (51 + exponent) * fraction  ; denormals
            exponent: 0
        ]
    ]
    reduce [sign exponent fraction]
]

split32: func [
    "Returns block containing three components of double floating point value"
    x [number!] /local sign exponent fraction
][
    sign: either negative? x [x: (- x) 1][0]

    either zero? x [exponent: 0  fraction: 0][

        either zero? 128 - exponent: to integer! log-2 x [exponent: 127][
            if positive? (2 ** exponent) - x [exponent: exponent - 1]
        ]
        fraction: x / (2 ** exponent)

        either positive? exponent: exponent + 127 [
            fraction: fraction - 1         ; drop the first bit for normals
            fraction: fraction * (2 ** 23) ; make the remaining fraction an
                                           ; "integer"
        ][
            fraction: 2 ** (22 + exponent) * fraction  ; denormals
            exponent: 0
        ]
    ]
    reduce [sign exponent fraction]
]
comment { =============== REAL/CONVERT REAL/RESTORE ===============

These functions are principally meant to be used by REAL/SAVE and
REAL/LOAD. REAL/CONVERT accepts a value of any SAVE-able datatype,
converts all decimal values to native binaries, and returns the
result. The argument value is unaffected. REAL/RESTORE does the
reverse of REAL/CONVERT, restoring all of the original decimal
values. This allows decimal values to be saved with no roundoff error.

Since all object and any-block values are copied, the result of
converting and restoring may not be identical to the original value.
The result will be good enough, however, to allow saving and
loading of values compatible with the behavior of the standard
functions SAVE and LOAD, and without any roundoff error.

EXAMPLE:

>> circle-area: func [r [number!]] compose [(pi) * r * r]
>> probe obj1: make object! compose/deep [
[    a: [(pi) (exp 1)] b: (EU$1.00 * pi) c: real/to-native (pi)
[    f: :circle-area ]

make object! [
    a: [3.14159265358979 2.71828182845905]
    b: EU$3.14
    c: #{400921FB54442D18}
    f: func [r [number!]][3.14159265358979 * r * r]
]

>> probe obj2: real/convert obj1

make object! [
a: [#{400921FB54442D18} #{4005BF0A8B145769}]
b: (EU$1.00 * #{400921FB54442D18})   ; money value converted to paren
c: ['escape #{400921FB54442D18}]     ; pre-existing 8-byte binary is escaped
f: func [r [number!]][#{400921FB54442D18} * r * r]
]
>> probe obj3: real/restore obj2

make object! [
a: [3.14159265358979 2.71828182845905]
b: EU$3.14
c: #{400921FB54442D18}
f: func [r [number!]][3.14159265358979 * r * r]
]

>> obj3/a/1 - pi                   ; decimal values are exactly restored
== 0
>> (obj3/f 4) - circle-area 4      ; restored function gives same answer
== 0

}

convert: func [
    {returns (copy of) B with all decimals converted to binary natives}
    value     "value to convert"
    /local r
][
    if function? :value [
        return func load mold third :value convert second :value
    ]
    if object? :value [
        r: make value []
        foreach word next first r [
            set in r word convert get in r word
        ]
        return r
    ]
    if any-block? :value [
        r: copy :value
        while [not tail? :r] [
            change/only :r convert first :r
            r: next :r
        ]
        return head :r
    ]
    if money? :value [
        return to paren! compose [(value / value/2) * (to-native value/2)]
    ]
    if all [
        binary? :value
        8 = length? value
    ][                            ; return an "escaped" form
        return compose ['escape (value)]
    ]
    if :value = first ['escape] [
        return ['escape 'escape]
    ]
    either decimal? :value [to-native value][:value]
]

restore: func [
    {returns (copy of) B with all binary natives converted to decimals}
    value     "value to convert"
    /local r item
][
    if function? :value [
        return func load mold third :value restore second :value
    ]
    if object? :value [
        r: make value []
        foreach word next first r [  ; cycle through all words except first
            set in r word restore get in r word
        ]
        return r
    ]
    if any-block? :value [
        if all [
            paren? :value
            3 = length? :value
            money? first :value
            binary? item: pick :value 3
        ][                        ; restore a money value
            change at :value 3 from-native item
            return value
        ]
        if all [
            block? :value
            2 = length? value
            (first value) = (first ['escape])
        ][
            return second value   ; return the "escaped" value
        ]
        r: copy :value
        while [not tail? :r] [
            change/only :r restore first :r
            r: next :r
        ]
        return head :r
    ]
    either all [
        binary? :value
        8 = length? value
    ][from-native value][:value]
]

comment { =============== TO-BIN FROM-BIN ===============

NOTE: used by REAL/SHOW and REAL/FROM-NATIVE

}

to-bin: func [
    {return a binary string representation of N}
    n [number!] "number to show in binary (integer value from 0 to 2 ** 53)"
    /length l   "length of string desired"
    /local r v
][
    if not l [l: 1]
    either negative? n - 1 [r: copy "0"][
        r: copy ""
        v: 2 ** to integer! log-2 n
        if negative? n - v [v: v / 2]  ; in case LOG-2 rounds up
        while [ v >= 1 ] [
            insert tail r either negative? n - v ["0"][n: n - v "1"]
            v: v / 2
        ]
    ]
    head insert/dup r "0" (l - length? r)
]

from-bin: func [
    {convert a binary string representation into a numeric value}
    b [string!]
    /local x  bitval
][
    bitval: 1.0
    b: tail b
    x: 0
    while [ not head? b ] [
        b: back b
        if #"1" = first b [x: x + bitval]
        bitval: bitval * 2
    ]
    x
]


comment { =============== TO-MATRIX ===============

EXAMPLE:

>> to-matrix [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16] 4
== [[1 2 3 4] [5 6 7 8] [9 10 11 12] [13 14 15 16]]
>> to-matrix [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16] [2 4]
== [[[1 2 3 4] [5 6 7 8]] [[9 10 11 12] [13 14 15 16]]]

}

to-matrix: func [
    {Returns a matrix constructed from the values of B}
    b [block!]
    row-length [number! block!]
    /local out number-rows
][
    if number? row-length [row-length: reduce [row-length]]
    reverse row-length
    number-rows: length? b
    foreach l row-length [
        number-rows: number-rows / l
        if not zero? number-rows - to integer! number-rows
            [make error! "to-matrix: bad dimensions"]
        out: make block! number-rows
        loop number-rows [
            insert/only tail out copy/part b l
            b: skip b l
        ]
        b: out
    ]
    out
]

]  ; end REAL


comment { =============== IEEE ===============

IEEE is an object that contains:

REBTEST   A function that tests the sensitivity of the REBOL EQUAL?
          comparison function.
GET-NEXT  A function that makes the minimum increment to a decimal value.
GET-LAST  A function that makes the maximum decrement to a decimal value.
MAX-REAL  The largest decimal value.
MIN-NORM  The smallest positive normalized decimal.
MIN-REAL  The smallest positive decimal value.
EPS       The minimum increment to 1 (smallest x such that (x+1)>1).

All of the increments and other values in IEEE are calculated based on
IEEE Std 754 (International Electrical and Electronic Engineering society).

REBTEST points out the inexactness of the REBOL comparison functions (as of
version 2.2), but note that it is easy to get exact comparisons by using
ZERO? NEGATIVE? and POSITIVE? to test the results of subtraction:

>> x: .1
== 0.1
>> y: ieee/get-next .1     ; make minimum increment to .1
== 0.1
>> y - x
== 1.38777878078145E-17    ; Y is greater than X ...
>> equal? x y
== true                    ; inexact
>> zero? x - y
== false                   ; exact
>> greater? y x
== false
>> positive? y - x
== true
>> lesser? x y
== false
>> negative? x - y
== true

; Example of rebtest (format.r not loaded so we get REBOL display values)
; Let's use 2 ** 53 as the target. All positive integers from 1 to 2 ** 53
; are exact in binary form. All doubles greater than 2 ** 52 are integers.
; The doubles from 2 ** 52 thru 2 ** 53 are consecutive integers.
; The first column shows the result of REBOL's test for equality of the target
; to (target + increment). The 2nd column shows REBOL display value and the
; 3rd column shows the increment.

>> ieee/rebtest 2 ** 53             ; the exact value is 9007199254740992
target 9.00719925474099E+15         ; REBOL display rounds to 15 sig. digits
positive increments
t=t+i target+increment increment
true 9.00719925474099E+15 2         ; positive increments are of size 2
true 9.007199254741E+15 4         ; REBOL display value changes
true 9.007199254741E+15 6         ; REBOL equality test is wrong
true 9.007199254741E+15 8
true 9.007199254741E+15 10
true 9.007199254741E+15 12
true 9.00719925474101E+15 14     ; REBOL display changes again
true 9.00719925474101E+15 16     ; but equality test is still wrong
false 9.00719925474101E+15 18     ; equality test correct once we add 18
false 9.00719925474101E+15 20
negative increments
t=t+i target+increment increment
false 9.00719925474099E+15 -1    ; negative increments are of size 1
false 9.00719925474099E+15 -2
false 9.00719925474099E+15 -3
false 9.00719925474099E+15 -4
false 9.00719925474099E+15 -5
false 9.00719925474099E+15 -6     ; REBOL equality test OK for all inc.
false 9.00719925474099E+15 -7
false 9.00719925474098E+15 -8     ; REBOL display changes
false 9.00719925474098E+15 -9
false 9.00719925474098E+15 -10

}

IEEE: make object! [

comment { =============== IEEE/REBTEST ===============

REBTEST makes ten successive minimum increments and decrements to the
target value, and tests whether EQUAL? returns TRUE when comparing
the results to the original value. In all cases EQUAL? should return
false.

}

rebtest: func [
     {displays 21 adjacent doubles centered on x}
     x [number!] "target value"
     /local y
][
    print ["target"  x ]
    print "positive increments"
    print ["t=t+i"  "target+increment"  "increment"]
    y: x
    loop 10 [
        if all [positive? y  zero? y - max-real][
            print ["" "+Inf"]
            break
        ]
        y: get-next y
        print [equal? x y  y  y - x]
    ]
    print "negative increments"
    print ["t=t+i"  "target+increment"  "increment"]
    y: x
    loop 10 [
        if all [negative? y  zero? y + max-real][
            print ["" "-Inf"]
            break
        ]
        y: get-last y
        print [equal? x y  y  y - x]
    ]
]

get-next: func [
    {returns next double after x}
    x [number!] "input value"
    /local exp inc
][
    if zero? x [return 2 ** -1074]
    if negative? x [return - get-last (- x)]
    either zero? 1024 - exp: to-integer log-2 x [exp: 1023][
        if positive? (2 ** exp) - x [exp: exp - 1]
    ]
    inc: 2 ** (exp - 52)                ; local machine precision
    if exp < -1021 [inc: 2 ** -1074]    ; handle denormals
    x + inc
]

get-last: func [
    {returns next double before x}
    x [number!] "input value"
    /local exp inc
][
    if zero? x [return - (2 ** -1074)]
    if negative? x [return - get-next (- x)]
    either zero? 1024 - exp: to-integer log-2 x [exp: 1023][
        if not negative? (2 ** exp) - x [exp: exp - 1]
    ]
    inc: 2 ** (exp - 52)                ; local machine precision
    if exp < -1021 [inc: 2 ** -1074]    ; handle denormals
    x - inc
]

max-real: 2 ** 1023 * (2 - (2 ** -52))   ; maximum decimal value

min-norm: 2 ** -1022         ; minimum normalized positive value

min-real: 2 ** -1074         ; minimum positive decimal value

eps: 2 ** -52   ; machine epsilon (smallest x such that (x+1)>1)

; if possible, set PRINT locally to a function providing formatted output

print: either value? 'format [
    func [line][
        system/words/print format/full reduce line [#8..3 #24.16.1 #12.2.1]
    ]
][
    get in system/words 'print
]

] ; end IEEE

comment { =============== EMPIRICAL ===============

EMPIRICAL is equivalent to IEEE, but whereas the values in IEEE are
calculated based on the IEEE standard, the values in EMPIRICAL are
obtained through an empirical algorithm. The function CMP-SENS does
this by actually trying a series of increments to the target value,
until the smallest value is identified that results in a different
value when added to the target.

}

empirical: make object! [

cmp-sens: func [
    {find smallest effective increment for TARGET.
    NOTE: this is less than the resulting increment}
    target [number!]
    /exact   {results for exact comparison - default is use EQUAL?}
    /below   "return decrement (default is increment)"
    /local diff upper lower last-diff eqf operation no-effect
][
    eqf: either exact [func[x y][zero? x - y]][:equal?]
    operation: either below [ :subtract ][ :add ]
    last-diff: upper: max   2 ** -30   abs target * (2 ** -30)
    lower: 0
    diff:  upper + lower / 2
    while [ not zero? last-diff - diff ] [
        last-diff: diff
        if error? try [
            no-effect: eqf target operation target diff
        ][
            no-effect: none
        ]
        either no-effect [
            lower: diff
            diff: diff + upper / 2
        ][
            upper: diff
            diff: diff + lower / 2
        ]
    ]
    return either none? no-effect [none][upper]
]

rebtest: func [
    {compare sensitivity of REBOL comparison operators against
    actual increment value}
    target [number!]
    /local inc rebsense factor
][
    if inc: cmp-sens/exact target [             ; get effective increment
        inc: target + inc - target              ; get resulting increment
        if rebsense: cmp-sens target [
            rebsense: target + rebsense - target
            if 1e10 < factor: rebsense / inc [factor: form factor]
        ]
    ]
    print ["Increments:"  "Smallest" "NOT EQUAL?" "Factor"]
    print ["Positive:" inc  rebsense factor]
    factor: none
    if inc: cmp-sens/below/exact target [
        inc: target - inc - target
        if rebsense: cmp-sens/below target [
            rebsense: target - rebsense - target
            if 1e10 < factor: rebsense / inc [factor: form factor]
        ]
    ]
    print ["Negative:" inc rebsense factor]
]

get-next: func [
    {make the smallest possible increment to a double}
    target [number!]
    /count n "number of times to do this"
][
    if not n [n: 1]
    loop n [
        target: target + cmp-sens/exact target
    ]
]

get-last: func [
    {make the smallest possible decrement to a double}
    target [number!]
    /count n "number of times to do this"
][
    if not n [n: 1]
    loop n [
        target: target - cmp-sens/below/exact target
    ]
]

max-real: func [
    {returns the highest numerical value on the system}
    /local x lower upper factor last-factor
][
    x: 2.0
    loop 100000 [
        if error? try [x: x * 2][break]
    ]
    lower: 1
    upper: 2
    last-factor: 0
    loop 100000 [
        if zero? last-factor - factor: lower + upper / 2 [break]
        either error? try [x * factor] [upper: factor][lower: factor]
        last-factor: factor
    ]
    x * lower
]

min-real: get-next 0

eps: (get-next 1) - 1

print: either value? 'format [
    func [
        {print out a formatted line if FORMAT is available}
        line
    ][
        system/words/print format/full reduce line
            [#-12 #12.2.1 #12.2.1 #8]
    ]
][
    get in system/words 'print
]

]  ; end empirical


