rebol []



s: make stream-io []
s/setStreamBuffer 2#{111100001100 110010101100} 2#{101 0100111011110101100110110001 100100001}
;loop 24 [s/readBit]
s/readUB 4 s/skipBits 4
;s/skipBits 4 print s/readUB 4 ;2#{1111 0000 1100110010101100}
s/skipBits 2 print s/readUB 2 ;2#{1111 0000 11 00 110010101100}
s/skipBits 2 print s/readUB 2 ;2#{1111 0000 11 00 11 00 10101100}
s/skipBits 7 print s/readUB 1 ;2#{1111 0000 11 00 11 00 1010110 0}
]
;s/readUB 8 s/skipBits 2 print s/readUB 4 ;2#{1111 0000 1100110010101100}
;s/skipBits 2 print s/readUB 2 ;2#{1111 0000 11 00 110010101100}
;s/skipBits 2 print s/readUB 2 ;2#{1111 0000 11 00 11 00 10101100}
;s/skipBits 7 print s/readUB 1 ;2#{1111 0000 11 00 11 00 1010110 0}
[
;halt
;probe enbase/base s/inBuffer 2
;repeat i 8 [print [">>>:" i mold s/readBit] s/skipBits 1]
;halt

;s/readUB 1 s/readUB 7
;s/skipBits 4 s/skipBits 4
s/skipBits 8 ;s/skipBits 4
print [mold copy/part s/inBuffer 4 s/bitCursor s/bitBuffer]
;stream/skipBits 1 stream/skipBits 39
;stream/skipBits 3
;stream/skipBits 28

[
	"1 1 1 1 0 0 0 0  1100 110010101100"
	
]
;stream: make stream-io [stream: 2#{0 1011  0000 1111 111  0 0010 0001 00  00 0000 0111 1  010 0000 0010 0000000}] ;rect
 ;stream: make stream-io [inBuffer: 2#{01111110001100100 0000000}] ;0.98591
 ;stream: make stream-io [inBuffer: 2#{00000001   010001111101111 000000000}] ;0.14036
 ;stream: make stream-io [inBuffer: #{61686F6A0001}]  ;string test

;print [mold stream/inBuffer "=" enbase/base stream/inBuffer 2]
;print stream/readSB 4
;print stream/readUB 4
;print stream/readUB 8
;print stream/readRect

;probe stream/readBytes 1
;probe stream/readFB 15
;probe stream/byteAlign


;probe stream/readSI16
;probe stream/readString probe stream/readByte

;while [not error? try [b: stream/readBit]][prin b] print ""
