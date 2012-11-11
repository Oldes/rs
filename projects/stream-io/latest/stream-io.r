REBOL [
    Title: "stream-io"
    Date: 22-Apr-2008/10:34:21+2:00
    Name: none
    Version: 1.1.1
    File: none
    Home: none
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: [
    	tm 10000 [
    		s: make stream-io [inBuffer: #{4DC32172} bitBuffer: 1344 availableBits: 2]
    		s/readUB 5
		]

    
	    s: make stream-io [inBuffer: 2#{1111 1001  0010 1011  0000 1111}]
		probe s/readUB 12
		probe s/skipBits 1
		probe s/readUB 2
		probe s/skipBits 9
		
		s: make stream-io [inBuffer: 2#{1111 1001  0010 1011  0000 1111}]
		probe s/readUBx 12
		probe s/skipBits 1
		probe s/readUBx 2
		probe s/skipBits 9

	]
    Purpose: none
    Comment: none
    History: [
    	1.0.0 [16-Sep-2007 "oldes" {First version - Only read functionality}]
    	1.1.0 [8-Nov-2007  "oldes" {Added basic write methods}]
    	1.1.1 [22-Apr-2008 "oldes" {Fixed bug in 'readFB}]
	]
    Language: none
    Type: none
    Content: none
    Email: oliva.david@seznam.cz
    require: [
    	;rs-project 'ieee
	]
	preprocess: true
]

;xc1: xc2: xc3: xc4: 0

stream-io: context [
	inBuffer:  none
	availableBits: 0
	bitBuffer: none
	
	setStreamBuffer: func[buff][
		inBuffer: either port? buff [copy buff][buff]
		availableBits: 0
		bitBuffer: none
	]
	initBitBuffer: does [
		bitBuffer: first inBuffer
		availableBits: 8
		inBuffer: next inBuffer
	]
	clearBuffers: does [
		if series? inBuffer [clear head inBuffer]
		if series? outBuffer [clear head outBuffer]
		availableBits: 0
		bitBuffer: none
		outBitMask:   0
		outBitBuffer: none
	]
	readSB: func[nbits [integer!] /local result][
		;xc1: xc1 + 1
		if nbits = 0 [return 0]
		result: copy ""
		loop nbits [ append result readBit ]
		insert/dup result result/1 (32 - nbits)
		to integer! debase/base result 2
	]
;	readUBx: func[nbits [integer!] /local result][
;		;xc2: xc2 + 1
;		;print ["readUB" nbits mold enbase/base copy/part inBuffer 4 2]
;		if nbits = 0 [return 0]
;		result: copy ""
;		loop nbits [ append result readBit ]
;		insert/dup result 0 (32 - nbits)
;		to integer! debase/base result 2
;	]

	#either [value? 'rebcode] [
		byteAlign: rebcode[] [
			gt.i availableBits 0 ift [
				set.i availableBits 0
				set bitBuffer none
			]
			return inBuffer
		]
		readBit: rebcode [/local bit][
			eq.i availableBits 0 ift [
				pick bitBuffer inBuffer 1
				set.i availableBits 8
				next inBuffer
			]
			set bit bitBuffer
			and bit 128
			
			sub.i availableBits 1
			eq.i availableBits 0 either [
				set bitBuffer none
			][	lsl bitBuffer 1 ]
			
			gt.i bit 0 either [return 1][return 0]
		]
		readBitLogic: rebcode [/local bit][
			eq.i availableBits 0 ift [
				pick bitBuffer inBuffer 1
				set.i availableBits 8
				next inBuffer
			]
			set bit bitBuffer
			and bit 128
			
			sub.i availableBits 1
			eq.i availableBits 0 either [
				set bitBuffer none
			][	lsl bitBuffer 1 ]
			
			gt.i bit 0 either [return true][return false]
		]
		readUB: rebcode [nbits [integer!] /local x nb r tmp result][
			;copy x inBuffer 4
			;print ["readUB" nbits availableBits bitBuffer mold x]
			eq.i  nbits  0 ift [return 0]
			set result 0
			set r 0
			set nb  nbits
			
			while [gt.i nbits 0][
				eq.i availableBits 0 ift [
					pick bitBuffer inBuffer 1
					next inBuffer
					set availableBits 8
				]
				;print [availableBits nbits]
				gt.i availableBits nbits  either [
					set tmp bitBuffer
					set.i r 8
					sub.i r nbits
					and tmp 255
					lsr	  tmp r 
					add.i result tmp
					sub.i availableBits nbits
					eq.i availableBits 0 either [
						set bitBuffer none
					][
						lsl bitBuffer nbits
					]
					;	print ["=1=" result]
					return result 
				][
					set tmp bitBuffer
					and tmp 255
					set.i r 8
					sub.i r availableBits
					lsr	 tmp r 
					set.i r nb
					sub.i r availableBits
					lsl	 tmp r 
					add.i result tmp
					
					sub.i nbits availableBits
					set bitBuffer none
					set.i availableBits 0
				]
				;print nbits
			]
			;print ["=2=" result]
			return result 
		]
		
		;inBuffer: #{} bitBuffer: 0 availableBits: 7
		;readUB 4
		
		readByte: rebcode [/local byte][
			copy byte inBuffer 1
			next inBuffer
			return byte
		]
		readBytes: rebcode [nbytes /local bytes][
			copy bytes inBuffer nbytes
			skip inBuffer nbytes
			return bytes
		]
	][	
		byteAlign: does [
			;print ["byteAlign:" availableBits bitBuffer mold copy/part inBuffer 20]
			if availableBits > 0 [
				availableBits: 0
				bitBuffer: none
			]
			inBuffer
		]
		readBit: has[bit][
			;xc4: xc4 + 1
			;print ["readBit==>"  tab mold copy/part inBuffer 3 "availableBits:" availableBits "bitBuffer:" bitBuffer]
			unless bitBuffer [
				bitBuffer: first inBuffer
				availableBits: 8
				inBuffer: next inBuffer
			]
			
			if 0 < bit: 128 and bitBuffer [bit: 1]
			either 0 = availableBits: availableBits - 1 [
				bitBuffer: none 
			][
				bitBuffer: bitBuffer * 2
			]
			;print ["readBit<=="  tab mold copy/part inBuffer 3 "availableBits:" availableBits "bitBuffer:" bitBuffer]
			bit
		]
		readBitLogic: has[bit][
			unless bitBuffer [
				bitBuffer: first inBuffer
				availableBits: 8
				inBuffer: next inBuffer
			]
			
			bit: (128 and bitBuffer) > 0
			either 0 = availableBits: availableBits - 1 [
				bitBuffer: none 
			][
				bitBuffer: bitBuffer * 2
			]
			bit
		]
		readUB: func[nbits [integer!] /local result nb x][
			;print ["readUB" nbits availableBits bitBuffer mold copy/part inBuffer 4]
			if nbits = 0 [return 0]
			result: 0 nb: nbits
			while [nbits > 0] [
				unless bitBuffer [
					bitBuffer: first inBuffer
					inBuffer: next inBuffer
					availableBits: 8
				]
				either availableBits > nbits [
					availableBits: availableBits - nbits
					result:  (256 -  to integer! x: (2 ** (8 - nbits))) and bitBuffer  /  x + result
					bitBuffer: either availableBits = 0 [none][to integer! (bitBuffer * (2 ** nbits))]
					;print ["=1=" to integer! result]
					return to integer! result
					break
				][
					result: ((255 and bitBuffer) / (2 ** (8 - availableBits))) * (2 ** (nb - availableBits)) + result
					nbits: nbits - availableBits
					bitBuffer: none
					availableBits: 0
				]
			]
			;print ["=2=" to integer! result]
			to integer! result
		]
;		inBuffer: #{973FBCB6} bitBuffer: 872 availableBits: 6
;		readUB 4

		readByte: func[/local byte][
			byte:   copy/part inBuffer 1
			inBuffer: next inBuffer
			byte
		]
		readBytes: func[nbytes /local bytes][
			bytes: copy/part inBuffer
			inBuffer: skip inBuffer nbytes
			bytes
		]
	]
	
	
	readPair: has[nbits][
		;print ["readPair: availableBits" availableBits]
		nbits: readUB 5
		reduce [readFB nbits readFB nbits]
	]
	readSBPair: has[nbits][
		nbits: readUB 5
		;print ["readSBPair:" nbits]
		reduce [readSB nbits readSB nbits]
	]
	;"010001111101111" =  0.14036
	;"01111110001100100" =  0.98591
	readFB: func[nbits /local] [
		(readSB nBits) / 65536.0
	]
	readRect: has[nbits result][
		byteAlign
		nbits: readUB 5
		result: reduce [
			readSB nbits ;Xmin
			readSB nbits ;Xmax
			readSB nbits ;Ymin
			readSB nbits ;Ymax
		]
		byteAlign
		result
	]


	readBytesRev: func[nbytes][
		reverse
			copy/part inBuffer
				inBuffer: skip inBuffer nbytes
	]
	readBytesArray: func [
		"Slices the binary data to parts which length is specified in the bytes block"
		bytes [block!]
		/local result b
	][
		result: copy []
		while [not tail? bytes] [
			insert tail result readBytes bytes/1
			bytes: next bytes
		]
		result
	]

	
	#either [value? 'rebcode] [
		readUI8: rebcode [/local i][
			pick i inBuffer 1
			next inBuffer
			return i
		]
		readUI16:  rebcode [/local r b][
			pick  r inBuffer 1
			next  inBuffer
			pick  b inBuffer 1
			lsl   b 8
			add.i r b
			next  inBuffer
			return r
		]
		readUI32:  rebcode [/local r b][
			pick  r inBuffer 1
			next  inBuffer
			pick  b inBuffer 1
			lsl   b 8
			add.i r b
			next  inBuffer
			pick  b inBuffer 1
			lsl   b 16
			add.i r b
			next  inBuffer
			pick  b inBuffer 1
			lsl   b 24
			add.i r b
			next  inBuffer
			return r
		]
		readSI8:  rebcode[/local r b][
			pick  r inBuffer 1
			next  inBuffer
			gt.i r 127 ift [
				and r 127
				sub.i r 128
			]
			return r
		]
		readSI16:  rebcode[/local r b][
			pick  r inBuffer 1
			next  inBuffer
			pick  b inBuffer 1
			lsl   b 8
			add.i r b
			next  inBuffer
			gt.i r 32767 ift [
				and   r 32767
				sub.i r 32768
			]
			return r
		]
	][
		readUI8:   has[i][i: first inBuffer inBuffer: next inBuffer i]
		readUI16:    func[][to integer! readBytesRev 2]
		readUI32:  func[][to integer! readBytesRev 4]
		readSI8:   has[i][
			i: first inBuffer inBuffer: next inBuffer
			if i > 127 [
				i: (i and 127) - 128
			]
			i
		]
		readSI16: has[i][
			i: to integer! readBytesRev 2
			if i > 32767 [
				i: (i and 32767) - 32768
			]
			i
		]
		readS24: has[i][
			i: to integer! readBytesRev 3
			if i > 8388607 [
				i: (i and 8388607) - 8388608
			]
			i
		]
		readUI16le: :readUI16
		readUI32le: :readUI32
		readSI8le:  :readSI8
		readSI16le: :readSI16
		readUI16be:    func[][to integer! readBytes 2]
		readUI32be:  func[][to integer! readBytes 4]
		readSI8be:   has[i][
			i: first inBuffer inBuffer: next inBuffer
			if i > 127 [
				i: (i and 127) - 128
			]
			i
		]
		readSI16be:  has[i][
			i: to integer! readBytes 2
			if i > 32767 [
				i: (i and 32767) - 32768
			]
			i
		]
	]
	
	readSI32: :readUI32 ;TEMP!!!!!!!!!!!!!!!!!!!!!!!!!
	
	readRest: has[bytes][
		bytes: copy inBuffer
		inBuffer: tail inBuffer
		bytes
	]
	readFloat: does[
		change third float-struct readBytes 4
		float-struct/value
	]
	readUI30: has[r b s][
		b: first inBuffer inBuffer: next inBuffer
		if b < 128 [return to integer! b]
		r: b and 127
		s: 128
		while [b: first inBuffer inBuffer: next inBuffer][
			r: r + (b * s)
			if 128 > b [return r]
			s: s + 128
		]
	]
	readU32: has[r b s][
		r: b: first inBuffer inBuffer: next inBuffer
		if r < 128   [return r]
		ask "x"
		b: first inBuffer inBuffer: next inBuffer
		r: (r and 127) or ( shift/left b 7 )
		if r < 16384 [probe r ask "2" return r]
		
		b: first inBuffer inBuffer: next inBuffer
		r: (r and 16383) or ( shift/left b 14 )
		if r < 2097152 [return r]
		
		b: first inBuffer inBuffer: next inBuffer
		r: (r and 2097151) or ( shift/left b 21 )
		if r < 268435456 [return r]

		b: first inBuffer inBuffer: next inBuffer
		r: (r and 268435455) or ( shift/left b 28 )
		r
	]
	readS32: has[r b][
		r: b: first inBuffer inBuffer: next inBuffer
		if r < 128   [return r]
		
		b: first inBuffer inBuffer: next inBuffer
		r: (r and 127) or ( shift/left b 7 )
		if r < 16384 [return 2 * r]
		
		b: first inBuffer inBuffer: next inBuffer
		r: (r and 16383) or ( shift/left b 14 )
		if r < 2097152 [return 2 * r]
		
		b: first inBuffer inBuffer: next inBuffer
		r: (r and 2097151) or ( shift/left b 21 )
		if r < 268435456 [return 2 * r]

		b: first inBuffer inBuffer: next inBuffer
		r: (r and 268435455) or ( shift/left b 28 )
		2 * r
	]
	
	readD64: does [
		from-ieee64 readBytes 8
	]

	readShort: :readUI16 ;just to make it clear
	readLongFloat: func["reads 4 bytes and converts them to decimal!" /local tmp][
		;prin "readLongFloat: "
		readBytesRev 4
		;from-ieee32 probe join (readBytesRev 3) (readBytes 1)
	]
	readULongFixed: has[l r][
		r: readUI16
		l: readUI16
		load ajoin [l #"." r]
	]
	readSLongFixed: has[l r][
		r: readUI16
		l: readSI16
		load ajoin [l #"." r]
	]
	readSShortFixed: has[l r][
		r: readUI8
		l: readSI8
		load ajoin [l #"." r]
	]
	readRGB:   does[to tuple! readBytes 3]
	readRGBA:  does[to tuple! readBytes 4]
	readStringP: has[str][
		parse/all inBuffer [copy str to "^(00)" 1 skip inBuffer:]
		inBuffer: as-binary inBuffer
		str
	]
	readStringNum: func[bytes][
		as-string readBytes bytes
	]
	readString: does[
		head remove back tail copy/part inBuffer inBuffer: find/tail inBuffer #{00}
	]
	readUTF: does[
		as-string readBytes readUI16
	]
	
	readStringInfo: does [
		as-string readBytes readUI30
	]

	skipString: does[inBuffer: find/tail inBuffer #{00}]
	

	readCount: has[c][
		either 255 = c: readUI8 [readUI16][c]
	]
	readRGBAArray: func[count /local result][
		result: copy []
		loop count [append result readRGBA]
		result
	]
	readUI8Array: func[count /local result][
		result: copy []
		loop count [append result readUI8]
		result
	]
	readUI32array: readSI32array: func[/local count result][
		count: readUI30 - 1
		either count >= 0 [
			result: make block! count
			loop count [ append result readUI32 ]
			result
		][ none ]
	]
	readU32array: func[/local count result][
		count: readUI30 - 1
		either count >= 0 [
			result: make block! count
			loop count [ append result readU32 ]
			result
		][ none ]
	]
	readS32array: func[/local count result][
		count: readUI30 - 1
		either count >= 0 [
			result: make block! count
			loop count [ append result readS32 ]
			result
		][ none ]
	]
	readD64array: func[/local count result][
		count: readUI30 - 1
		either count >= 0 [
			result: make block! count
			loop count [ append result readD64 ]
			result
		][	none ]
	]
	readLongFloatArray: func[count /local result][
		result: copy []
		loop count [append result readLongFloat]
		result
	]
	
    readCharCode: func["Reads sequence of 1-6 octets into 32-bit unsigned integer." /local us][
    	us: utf-8/decode-integer inBuffer
    	inBuffer: skip inBuffer second us
    	first us
	]
	comment {
	readUCS2Code: func[/local us][
    	us: utf-8/decode-integer inBuffer
        vs: make block! 2
        z: to integer! ((first us) / 256)
        insert vs z
        z: (first us) - (z * 256)
        insert tail vs z
        ;probe vs
        insert tail result to binary! vs
       ; probe us
        xs: skip xs second us
    	inBuffer: skip inBuffer second us
    	first us
	]
	}
	
	isSetBit?: func[flags [integer!] bit [integer!] /local b][
		(b: to integer! (2 ** (bit - 1))) = (b and flags)
	]
	
	comment {SKIP FUNCTIONS}	
	skipRect: does [
		byteAlign
		skipBits (4 * readUB 5)
		byteAlign
	]
	skipPair:  does[skipBits (2 * readUB 5)]


	#either [value? 'rebcode] [
		skipBits: rebcode[nbits /local tmp][
			gt.i availableBits 0 ift [
				back inBuffer
				add.i nbits 8
				sub.i nbits availableBits
			]
			;inBuffer: skip inBuffer (to integer! (nbits / 8))
			set   tmp nbits
			div.i tmp 8
			skip  inBuffer tmp
			
			set.i availableBits nbits
			rem.i availableBits 8
			eq.i  availableBits 0 either [
				set bitBuffer none
			][
				pick bitBuffer inBuffer 1
				lsl bitBuffer availableBits
				neg.i availableBits
				add.i availableBits 8
				next inBuffer
			]
		]
		skipBytes: rebcode[nbytes [integer!]][skip inBuffer nbytes]
		skipByte:  rebcode[][next inBuffer]
		skipUI16:  rebcode[][skip inBuffer 2]
		skipUI32:  rebcode[][skip inBuffer 4]
		skipRGB:   rebcode[][skip inBuffer 3]
	][
		skipBits:  func[nbits ][
			;xc3: xc3 + 1
			;print [">>" nbits tab mold copy/part inBuffer 3 mold enbase/base copy/part inBuffer 3 2 "availableBits:" availableBits "bitBuffer:" bitBuffer]
			;loop nbits [readBit]
			if availableBits > 0 [
				inBuffer: back inBuffer
				nbits: 8 - availableBits + nbits
				;print ["NEW bits:" nbits mold copy/part inBuffer 3]
			]
			inBuffer: skip inBuffer (to integer! (nbits / 8))
			either 0 = availableBits: nbits // 8 [
				;inBuffer: back inBuffer
				bitBuffer: none
			][
				;bitCursor: bitCursor + 1
				bitBuffer: to integer! (2 ** availableBits) * first inBuffer ;here the availableBits is NOT availableBits yet!
				availableBits: 8 - availableBits
				inBuffer: next inBuffer
			]
			;print ["==" nbits tab mold copy/part inBuffer 3 "availableBits:" availableBits "bitBuffer:" bitBuffer]
			none
		]
		skipBytes: func[nbytes][inBuffer: skip inBuffer nbytes]
		skipByte:  does[inBuffer: next inBuffer  ]
		skipUI16:  does[inBuffer: skip inBuffer 2]
		skipUI32:  does[inBuffer: skip inBuffer 4]
		skipRGB:   does[inBuffer: skip inBuffer 3]

	]
	skipSBPair: does[skipBits (2 * readUB 5)]
	skipRGBA:  :skipUI32
	skipSI16:  :skipUI16
	skipUI8:   :skipByte
	
	
	
	
	comment {WRITE FUNCTIONS}
	outBuffer:    make binary! 1000
	outBitMask:   0
	outBitBuffer: none
	
	alignBuffers: does [
		if availableBits > 0 [
			availableBits: 0
			bitBuffer: none
		]
		;print ["align.." mold outBitBuffer]
		unless none? outBitBuffer [
			outBuffer: insert outBuffer to char! outBitBuffer
			outBitMask:   0
			outBitBuffer: none
		]
	]
	
	clearOutBuffer: does [
		;outBuffer: clear head outBuffer
		outBuffer: copy #{}
		outBitMask:   0
		outBitBuffer: none
	]
	outSetStreamBuffer: func[buff][
		outBuffer: buff
		outBitMask:   0
		outBitBuffer: none
	]
	
	outByteAlign: does [
		;print ["byteAlign:" outBitMask outBitBuffer]
		unless none? outBitBuffer [
			outBuffer: insert outBuffer to char! outBitBuffer
			outBitMask:   0
			outBitBuffer: none
		]
		outBuffer
	]

	getUBitsLength: func[
		"Returns number of bits needed to store unsigned integer value"
		value [integer!] "Unsigned integer"
	][
		either value <= 0 [0][1 + to integer! log-2 value]
	]
	
	getSBitsLength: func[
		"Returns number of bits needed to store signed integer value"
		value [integer!] "Signed integer"
	][
		either value = 0 [0][2 + to integer! log-2 abs value]
	]
	getUBitsLength: func[
		"Returns number of bits needed to store unsigned integer value"
		value [integer!] "unsigned integer"
	][
		either value = 0 [0][1 + to integer! log-2 abs value]
	]
	
	
	getSBnBits: func[values][
		;print ["getSBnBits:" mold values]
		2 + to integer! log-2 max (first maximum-of values) (abs first minimum-of values)
	]
	getUBnBits: func[values][
		;print ["getUBnBits:" mold values]
		1 + to integer! log-2 (first maximum-of values)
	]
	
	
	ui32-struct: make struct! [value [integer!]] none
	ui16-struct: make struct! [value [short]] none
	float-struct: make struct! [value [float]] none
	
	writeFloat: func[v [number!]][
		float-struct/value: v
		outBuffer: insert outBuffer third float-struct
	]
	writeUI32: writeUnsignedInt: func[i][
		ui32-struct/value: to integer! i
		outBuffer: insert outBuffer copy third ui32-struct
	]
	writeUI16:  func[i][
		ui16-struct/value: to integer! i
		outBuffer: insert outBuffer copy third ui16-struct
	]
	writeUI8: func[i][
		outBuffer: insert outBuffer to char! 255 and to integer! i
	]
	writeUI30: func[i][
		case [
			i < 128   [writeUI8 i]
			true [make error! "Unsuported value for writeUI30"]
			;i < 16384 []
		]
	]
	comment {			
	def writeLen(self, l):
        if l < 0x80:
            self.writeStr(chr(l))
        elif l < 0x4000:
            l |= 0x8000
            self.writeStr(chr((l >> 8) & 0xFF))
            self.writeStr(chr(l & 0xFF))
        elif l < 0x200000:
            l |= 0xC00000
            self.writeStr(chr((l >> 16) & 0xFF))
            self.writeStr(chr((l >> 8) & 0xFF))
            self.writeStr(chr(l & 0xFF))
        elif l < 0x10000000:        
            l |= 0xE0000000         
            self.writeStr(chr((l >> 24) & 0xFF))
            self.writeStr(chr((l >> 16) & 0xFF))
            self.writeStr(chr((l >> 8) & 0xFF))
            self.writeStr(chr(l & 0xFF))
        else:                       
            self.writeStr(chr(0xF0))
            self.writeStr(chr((l >> 24) & 0xFF))
            self.writeStr(chr((l >> 16) & 0xFF))
            self.writeStr(chr((l >> 8) & 0xFF))
            self.writeStr(chr(l & 0xFF))
}

	writeByte: func[byte][outBuffer: insert outBuffer byte]
	writeBytes: func[bytes][outBuffer: insert outBuffer as-binary bytes]
	
	writeBit: func[bit [integer! logic!]][
		;print ["writeBit==>" bit tab "outBitMask:" outBitMask "outBitBuffer:" outBitBuffer]
		unless outBitBuffer [
			outBitBuffer: 0
			outBitMask:   128
		]
		either logic? bit [
			if bit [outBitBuffer: outBitBuffer or outBitMask]
		][
			outBitBuffer: outBitBuffer or (outBitMask and bit)
		]
		if 1 > outBitMask: outBitMask / 2 [
			outBuffer:    insert outBuffer to char! outBitBuffer
			outBitBuffer: none
		]
		outBitBuffer
	]
	writeBits: func[value [integer!] nBits [integer!]][
		loop nBits [
			writeBit value
		]
	]
	
	writeFPBits: func[value nBits][
		writeSignedBits (value * 65536.0) nBits
	]
	
	writeInteger: func[value nBits /local nbitCursor val][
		;print ["writeInteger" value nBits]
		
		if nBits = 32 [
			unless outBitBuffer [
				outBitBuffer: 0
				outBitMask:   128
			]
			if -2147483648 = (-2147483648 and value) [
				outBitBuffer: outBitBuffer or outBitMask
			]
			if 1 > outBitMask: outBitMask / 2 [
				outBuffer:    insert outBuffer to char! outBitBuffer
				outBitBuffer: none
			]
			nBits: 31
		]

		nbitCursor: to integer! power 2 (nBits - 1)
		while [nbitCursor >= 1][
			unless outBitBuffer [
				outBitBuffer: 0
				outBitMask:   128
			]
			if 0 < (nbitCursor and value) [
				outBitBuffer: outBitBuffer or outBitMask
			]
			if 1 > outBitMask: outBitMask / 2 [
				outBuffer:    insert outBuffer to char! outBitBuffer
				outBitBuffer: none
			]
			nbitCursor: nbitCursor / 2
		]
		;probe head outBuffer
		;value
	]
	writeUB: :writeInteger
	writeSB: func[value [integer!] nBits /local][
		;print ["writeSB:" value nbits]
		if nBits < bitsNeeded: getSBitsLength value [
			throw make error! reform ["IO: At least"  bitsNeeded "bits needed for representation of" value "(writeSB)"]
		]
		;print ["writeSB:" value nBits]
		writeInteger value nBits
	]
	writeFB: func[value [number!] nBits /local x y fb] [
		;print ["writeFB:" value nBits]
		writeSB to integer! (value * 65536.0) nBits
	]
	writeSBs: func[values [block!] nbits /local bitsNeeded][
		bitsNeeded: 1 + to integer! log-2 max (first maximum-of values) (abs first minimum-of values)
		
		if nBits < bitsNeeded [
			throw make error! reform ["IO: At least"  bitsNeeded "bits needed for representation of" value "(writeSBs)"]
		]
		forall values [
			writeInteger values/1 nBits
		]
	]
	writeUBs: func[values [block!] nBits][
		;nBits: 1 + to integer! log-2 (first maximum-of values)
		forall values [
			writeInteger max 0 values/1 nBits
		]
	]
	
	writeRect: func[corners /local nBits][
		;print ["writeRect:" corners]
		outByteAlign
		nBits: 2 + to integer! log-2 max (first maximum-of corners) (abs first minimum-of corners)
		writeInteger nBits 5
		forall corners [
			writeInteger corners/1 nBits
		]
		outByteAlign
	]
	
	writeString: func[value][writeBytes join as-binary value #{00}]
	writeUTF: func[value][
		writeUI16 length? value
		writeBytes value
	]
	
	writePair: func[value [pair! block!] /local nBits][
		v1: value/1
		v2: value/2
		
		nBits: 16 + getSBitsLength to integer! (round max abs v1 abs v2)
		;print ["writePair" v1 v2 nBits]
		writeUB nBits 5
		writeFB v1 nbits
		writeFB v2 nbits
	]
	writeSBPair: func[value [pair! block!] /local v1 v2 nBits x y][
		v1: value/1
		v2: value/2
		;print ["writeSBPair" mold value]
		nBits: getSBitsLength to integer! max abs v1 abs v2
		writeUB nBits 5
		writeSB v1 nbits
		writeSB v2 nbits
	]
	readLongFloat: func["reads 4 bytes and converts them to decimal!" /local tmp][
		;prin "readLongFloat: "
		readBytesRev 4
		;from-ieee32 probe join (readBytesRev 3) (readBytes 1)
	]
	
	writeCount: func[c][
		either c < 255 [writeUI8 c][writeByte #{FF} writeUI16 c]
	]
	carryCount: has [c][
		either 255 > c: readUI8 [writeUI8 c][writeByte #{FF} writeUI16 c: readUI16] c
	]
	carryBytes: func[num][writeBytes readBytes num]
	carryBitLogic: has[b][writeBit b: readBitLogic b]
	carrySBPair: carryPair: has[nBits][
		nBits: readUB 5
		writeUB nBits 5
		loop (2 * nBits) [
			writeBit readBitLogic
		]
	]

	carryBits: func[num][ loop num [ writeBit readBitLogic ] ]
	carryUI8: has[v][writeUI8 v: readUI8 v]
	carryUI16: has[v][writeUI16 v: readUI16 v]
	carryUB: func[nBits /local v][writeUB v: readUB nBits nBits v]
	carrySB: func[nBits /local v][writeSB v: readSB nBits nBits v]  
	
	carryString: does [writeString readString]
]

comment {
system/options/binary-base: 2

s: make stream-io []
s/outSetStreamBuffer x: copy #{}
with s [
	writeBit true
	writePair [14.1421203613281 14.1421203613281]
	writeBit true
	writePair [14.1421203613281 -14.1421203613281]
	outByteAlign
	probe enbase/base x 16
]


s: make stream-io []
s/outSetStreamBuffer x: copy #{}
with s [
	writeUI8 2
	b: index? outBuffer
	writeUI8 3
	probe outBuffer: at head outBuffer b
	writeUI8 4
	
	setStreamBuffer copy head outBuffer
	probe readUI8
	probe readUI8
	probe readUI8
]


system/options/binary-base: 2

s: make stream-io []
s/outSetStreamBuffer x: copy #{}
with s [
	writeBit true
	writePair [14.1421203613281 14.1421203613281]
	writeBit true
	writePair [14.1421203613281 -14.1421203613281]
	outByteAlign
	probe enbase/base x 16
]


with s [
	setStreamBuffer copy head outBuffer
	;setStreamBuffer copy #{D5C48C4E2462D5C48C52DB9E0000100BD8FA0E97}
	probe reduce [
		either readBitLogic [ readPair ][none] ;scale
		either readBitLogic [ readPair ][none] ;rotate
	]
]
;halt
s/outSetStreamBuffer x: copy #{}
s/writePair [3.47296355333861 -3.472963553338612]
s/outByteAlign
probe x 

s/setStreamBuffer copy head s/outBuffer
clear head s/outBuffer
probe s/readPair


s/outByteAlign
probe head s/outBuffer


system/options/binary-base: 2
s: make stream-io []
s/outSetStreamBuffer x: copy #{}
s/writeFB 20 22
s/outByteAlign
probe x 

s/setStreamBuffer head s/outBuffer
probe s/readFB 22

s/writeBit 0
s/writeBit 0
s/writeBit 0
s/writeBit 1
s/writeSBPair [2799 940]
s/writeBit 0
s/writeBit 0
s/writeBit 0
s/writeBit 1
s/writeBit 1
s/writeUB 11 4


;s/writeUB 32 5
;s/writeInteger 1 6
;s/writeSB -22106 32
;s/writePair [0.707118333714809 0.707118333714809]
;s/writeRect [100 10 30 -210] 5
;s/writeFB 3.0 19
;s/writeFB 0.707118333714809 19
;s/writePair [10 2.2]
;s/writeSB -22 9
;s/writeSBPair [-80000 2460]
;s/outByteAlign
;s/writeString "test"
;s/writeRect [100 10 30 10]
;s/writeInteger 0 2
;s/writeSB -2 3
;s/writeInteger 10 6
;s/writeSBPair [ 0 0 ]
s/outByteAlign

probe x 

s/setStreamBuffer head s/outBuffer
probe s/readBit
probe s/readBit
probe s/readBit
probe s/readBit
probe s/readSBPair
probe s/readBit
probe s/readBit
probe s/readBit
probe s/readBit
probe s/readBit
probe s/readUB 4
;probe s/readUB 5
;probe s/readUB 1
;probe s/readUB 6
;probe s/readSB 32
;probe s/readPair
;probe s/readRect
;probe s/readFB 19
;probe s/readFB 19
;probe s/readPair
;probe s/readSB 9
;probe s/readSBPair
;probe s/readSBPair
;probe as-string s/readString

probe x ; head s/outBuffer
}