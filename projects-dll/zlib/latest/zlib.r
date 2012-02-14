REBOL [
	Title: "Zlib"
	Date: 6-Sep-2005/10:07:43+2:00
	Name: none
	Version: 1.0.3
	File: none
	Home: none
	Author: "Oldes"
	Owner: none
	Rights: none
	Needs: none
	Tabs: none
	Usage: [
		print ["ZLIB" zlib/version]

		probe zlib/crc32   "test"
		probe zlib/adler32 "test"

		probe inp: "pokus pokus"
		probe out: zlib/compress inp
		probe as-string zlib/decompress out

		probe zlib/compress/level inp 0 ;<- no  compression
		probe zlib/compress/level inp 9 ;<- max compression

		;free zlib/zlib.dll
	]
	Purpose: none
	Comment: none
	History: [
		1.0.3 "implemented late routine initialisation"
		1.0.2 "used compress2 instead of just compress so it's possible to set a level of compression (0-9)"
		1.0.1 "increased automatic length of output buffer for decompress (5x source, if the length is not specified)"
		1.0.0 "history starts"
	]
	Language: none
	Type: none
	Content: none
	Email: oliva.david@seznam.cz
	require: [
		rs-project %memory-tools
		library    %lib/zlib1.dll
	]
]

error? try [free zlib/zlib.dll]
zlib: context [
	home-dir: what-dir
	zlib.dll: none
	;routine placeholders:
	r_version:
	r_inflateInit:
	r_inflate:
	r_compr2:
	r_decompr:
	r_crc32:
	r_adler32: none

	z_stream: make struct! [
		*next_in  [integer!] ;  /* next input byte */
		avail_in  [integer!] ;  /* number of bytes available at next_in */
		total_in  [long]     ;/* total nb of input bytes read so far */
		*next_out [integer!] ; /* next output byte should be put there */
		avail_out [integer!] ; /* remaining free space at next_out */
		total_out [long]     ; /* total nb of bytes output so far */
		*msg      [integer!] ;      /* last error message, NULL if no error */
		*state    [integer!] ; /* not visible by applications */
		zalloc    [integer!] ;  /* used to allocate the internal state */
		zfree     [integer!] ;   /* used to free the internal state */
		opaque    [integer!] ;  /* private data object passed to zalloc and zfree */
		data_type [integer!] ;  /* best guess about the data type: binary or text */
		adler     [long] ;      /* adler32 value of the uncompressed data */
		reserved  [long];   /* reserved for future use */
	] none

	init-routines: does [
		either not any [
			not error? try [zlib.dll: load/library dir_lib/zlib1.dll]
			not error? try [zlib.dll: load/library home-dir/lib/zlib1.dll]
			not error? try [zlib.dll: load/library home-dir/zlib1.dll]
		][
			make error! "Cannot load zlib1.dll"
		][
			r_version: make routine! [
				return:      [string!]
			] zlib.dll "zlibVersion"

			r_inflateInit: make routine! [
				z_streamp    [integer!]
				zlib_version [string!]
				zstreamsz    [integer!]
				return:      [int]
			] zlib.dll "inflateInit_"
			
			r_inflate: make routine! [
				z_streamp    [integer!]
				flush        [int]
				return:      [int]
			] zlib.dll "inflate"

			comment {
			;not needed... used r_compr2
			r_compr: make routine! [
				dest      [integer!]
				destLen   [integer!]
				source    [integer!]
				sourceLen [integer!]
				return: [integer!]
			] zlib.dll "compress"
			}

			r_compr2: make routine! [
				dest      [integer!]
				destLen   [integer!]
				source    [integer!]
				sourceLen [integer!]
				level     [integer!]
				return:   [integer!]
			] zlib.dll "compress2"

			r_decompr: make routine! [
				dest      [integer!]
				destLen   [integer!]
				source    [integer!]
				sourceLen [integer!]
				return:   [integer!]
			] zlib.dll "uncompress"

			r_crc32: make routine! [
				crc       [integer!]
				buf       [integer!]
				len       [integer!]
				return:   [integer!]
			] zlib.dll "crc32"

			r_adler32: make routine! [
				adler     [integer!]
				buf       [integer!]
				len       [integer!]
				return:   [integer!]
			] zlib.dll "adler32"
		]
		;Remove this init function so it's called only once:
		foreach fce [version compress decompress crc32 adler32][
			remove second get in zlib fce
		]
		zlib/init-routines: none
	]

	ui32-to-int: func[i /local s][
		s: make struct! [i [integer!]] none
		change third s i
		return s/i
	]
	int-to-ui32: func[i /local s][
		s: make struct! [i [integer!]] reduce [i]
		return third s
	]

	version: does [
		init-routines
		return r_version
	]

	crc32: func[buff [string! binary!] /update crc [integer!] /local *buff][
		init-routines
		*buff: address? buff
		if none? update [crc: 0]
		int-to-ui32 r_crc32 crc *buff (length? buff)
	]

	adler32: func[buff [string! binary!] /update adler [integer!] /local *buff][
		init-routines
		*buff: address? buff
		if none? update [adler: 0]
		int-to-ui32 r_adler32 adler *buff (length? buff)
	]

	compress: func[src [string! binary!] /level lvl [integer!] /local srcLen buffSize buff buffLen r *buffLen *buff *src][
		init-routines

		if any [none? lvl lvl < 0 lvl > 8][lvl: 8]

		;destination buffer must be at least 0.1% larger than sourceLen plus 12 bytes
		srcLen: length? src
		buffSize: (1.1 * srcLen) + 12
		buff: make binary! buffSize
		;this seems to be stupid but just making buffer using make binary! is not enough
		;you must fill the buffer with something!
		insert/dup buff #{00} buffSize
		;this is stupid way how to get a pointer to integer value:
		buffLen: int-to-ui32 buffSize
		*buffLen: address? buffLen
		;...and pointers to input and output buffers:
		*buff:    address? buff
		*src:     address? src
		r: r_compr2 *buff *buffLen *src srcLen lvl
		copy/part buff ui32-to-int buffLen
	]

	decompress: func[src [string! binary!] /l buffSize /local srcLen buff buffLen r *buffLen *buff *src][
		init-routines
		;destination buffer must be large enough!
		srcLen: length? src
		if none? l [buffSize: 5 * srcLen]
		buff: make binary! buffSize
		insert/dup buff #{00} buffSize
		buffLen: int-to-ui32 buffSize
		*buffLen: address? buffLen
		*buff:    address? buff
		*src:     address? src
		r: r_decompr *buff *buffLen *src srcLen
		copy/part buff ui32-to-int buffLen
	]
]
