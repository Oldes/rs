REBOL [
	Title:		"SQLite driver"
	Owner:		"Ashley G. Trüter"
	Version:	1.0.6
	Date:		26-Nov-2008
	Purpose:	"REBOL front-end to SQLite (requires library access)."
	History: {
		0.1.0	Initial beta version
		0.1.1	Corrected mold/all ? handling
				Changed /blocked to /flat (rows are now returned as blocks by default)
		0.1.2	Added SQLITE_BUSY check
				Added /timeout refinement to connect
				Added automatic NULL conversion
		0.1.3	Rewrote describe to use PRAGMAs and now accepts additional refinements
				Fixed 'sql so as explain and pragma are row-processed like select
				context is now named SQLite
				Removed 'headings func as SQLite/columns is now the same
				Connect now returns dbid, disconnect none!
				Changed describe arg from: 'table [word!] => table [word! string!]
				'tables command no longer returns sql text (use describe to get this info)
				Describe now accepts a word! or a string! as an argument
		0.1.4	Added global error handler and sqlite.log support
				Changed func / function to make function!
				Added a /log refinement to CONNECT
				Replaced sqlite- routine prefixes with *; and re-ordered alphabetically
				Fixed bind_real (it used sqlite3_bind_int instead of sqlite3_bind_double)
				Renamed bind_real to bind_double
				Tidied up example code a bit
		0.1.5	TABLES now uses sql/raw
				Added widths block
				Added /format option to CONNECT
				Simplified TABLES and INDEXES functions
				DESCRIBE rewritten
				Added EXPLAIN function
				CONNECT rewritten
				Added DATABASE function
				Error reporting more informative
		0.1.6	Added no-copy directive
				Replaced /raw refinement of SQL with /flat and recoded its use accordingly
				Replaced ret local var with rc (Result Code)
				New col-info? directive (used by format)
				Recoded SQL and IMPORT loops as composed - improved iteration speed by 200%!!!
				Reordered directives and other user-definable settings to beginning of context
				Removed IMPORT (not fast enough, and fails under some cases)
				Removed example code to %demo.r
		0.1.7	insert/only to handle block! values
				format now uses mold/all instead of form to show values
				switch statement now uses type?/word to enable SQLite to be encapped
				sqlite.log messages now use message codes (ERR, SQL, CON, DIS)
		0.1.8	Context -> make object!
				Date! is now bound to a sortable string (in both now and now/date forms)
				sql non-select statements now return SQLITE_OK
				SQL now handles concatenated columns correctly (was loading them as a block)
		0.1.9	Concatenation logic improved (now handles types apart from string)
		0.2.0	Added ROWS function
				DATABASE now returns none! (instead of error) when not connected (Ingo)
		1.0.0	Added IMPORT function, stability issues resolved under latest Core and SQLite3 DLL
		1.0.1	Added nested transaction support (Robert)
		1.0.2	Worked around data corruption bug (RAMBO#4063) by adding a recycle every 100 statements
		1.0.3	Supports newer sqlite3_prepare_v2 API (Robert)
		1.0.4	Added Mac support (which uses the older sqlite3_prepare API)
		1.0.5	Mac now uses the newer v2 API and dylib path updated
				SQLite version is now automatically returned
				Library script paths shortened
		1.0.6	Added missing *finalize calls to SQL function
	}
	Comment: {	This work is based on Cal Dixon's sqlite3-protocol.r script:

					http://www.rebol.org/view-script.r?script=sqlite3-protocol.r

				which in turn is mostly based on Juan-Carlos Miranda's sqlite3.r script:

					http://www.rebol.org/view-script.r?script=sqlite3.r

				Major enhancements include automatic REBOL type conversion and a total rewrite of the
				main '*exec function (now named 'sql) to expand its functionality and improve its
				performance. Also added a number of useful functions to more easily extract data from
				sqlite_master.
	}
	Usage: {
				Exported functions

					connect		Open a SQLite database
					database	Database tasks
					describe	Information about a table
					disconnect	Close database connection
					explain		Explain an SQL statement
					indexes		List all indexes
					rows		Return row count
					sql			Prepare and execute an SQL statement
					tables		List all tables

				connect/create %my-database.db
	}
	Licence:	"MIT. Free for both commercial and non-commercial use."
]

SQLite: make object! [

	version:		none

	;	Directives
	retry:			5						; number of 1 second intervals to try if SQLITE_BUSY
	flat?:									; don't return rows as blocks
	direct?:								; bypass mold/load conversions
	no-copy?:								; clear buffer instead of copy
	log?:									; SQL statement logging
	format?:								; format output
	col-info?:		false					; column names and widths

	;	Data structures
	buffer:			make block! 1024 * 32	; result buffer
	columns:		make block! 16			; column names of last select
	widths:			make block! 16			; column widths of last select

	;	State variables
	dbid:									; Database ID
	sid:									; Statement ID
	time:			none					; time last statement was started (used by format)
	transaction:	0						; nested transaction counter
	recycle-cnt:	0						; work around for RAMBO#4063

	;	Result codes
	SQLITE_OK:		0						; Successful result
	SQLITE_BUSY:	5						; The database file is locked
	SQLITE_ROW:		100						; sqlite_step() has another row ready
	SQLITE_DONE:	101						; sqlite_step() has finished executing

	;
	;	SQLite Library functions
	;

	*lib: load/library switch/default fourth system/version [
		2	[%/usr/lib/libsqlite3.dylib]
		3	[%sqlite3.dll]
	] [%libsqlite3.so]

	version: to tuple! do make routine! [return: [string!]] *lib "sqlite3_libversion"

	*bind-blob:			make routine! [stmt [integer!] idx [integer!] val [string!] len [integer!] fn [integer!] return: [integer!]] *lib "sqlite3_bind_blob"
	*bind-double:		make routine! [stmt [integer!] idx [integer!] val [decimal!] return: [integer!]] *lib "sqlite3_bind_double"
	*bind-int:			make routine! [stmt [integer!] idx [integer!] val [integer!] return: [integer!]] *lib "sqlite3_bind_int"
	*bind-null:			make routine! [stmt [integer!] idx [integer!] return: [integer!]] *lib "sqlite3_bind_null"
	*bind-text:			make routine! [stmt [integer!] idx [integer!] val [string!] len [integer!] fn [integer!] return: [integer!]] *lib "sqlite3_bind_text"
	*close:				make routine! [db [integer!] return: [integer!]] *lib "sqlite3_close"
	*column-blob:		make routine! [stmt [integer!] idx [integer!] return: [string!]] *lib "sqlite3_column_blob"
	*column-count:		make routine! [stmt [integer!] return: [integer!]] *lib "sqlite3_column_count"
	*column-double:		make routine! [stmt [integer!] idx [integer!] return: [decimal!]] *lib "sqlite3_column_double"
	*column-integer:	make routine! [stmt [integer!] idx [integer!] return: [integer!]] *lib "sqlite3_column_int"
	*column-name:		make routine! [stmt [integer!] idx [integer!] return: [string!]] *lib "sqlite3_column_name"
	*column-text:		make routine! [stmt [integer!] idx [integer!] return: [string!]] *lib "sqlite3_column_text"
	*column-type:		make routine! [stmt [integer!] idx [integer!] return: [integer!]] *lib "sqlite3_column_type"
	*errmsg:			make routine! [db [integer!] return: [string!]] *lib "sqlite3_errmsg"
	*finalize:			make routine! [stmt [integer!] return: [integer!]] *lib "sqlite3_finalize"
	*open:				make routine! [name [string!] db-handle [struct! [[integer!]]] return: [integer!]] *lib "sqlite3_open"
	*prepare:			make routine! [db [integer!] dbq [string!] len [integer!] stmt [struct! [[integer!]]] dummy [struct! [[integer!]]] return: [integer!]] *lib "sqlite3_prepare_v2"
	*reset:				make routine! [stmt [integer!] return: [integer!]] *lib "sqlite3_reset" ; Required by IMPORT
	*step:				make routine! [stmt [integer!] return: [integer!]] *lib "sqlite3_step"

	;	Helper functions
	;		do-step		Used by SQL to handle locks
	;		format		Used by SQL to format output
	;		pad			Used by format to pad values
	;		sql-error	Used by database functions when an error occurs

	do-step: make function! [
		sid [integer!]
		/local rc
	] [
		loop retry [
			unless SQLITE_BUSY = rc: *step sid [return rc]
			all [log? write/append/lines %sqlite.log reform [now "BSY"]]
			wait 1
		]
		rc
	]

	format: make function! [
		/local cols rows p separator
	] [
		all [empty? buffer return "No rows selected."]
		cols: length? columns
		rows: (length? buffer) / cols
		;	separator
		separator: copy ""
		repeat i cols [
			insert tail separator "+"
			insert/dup tail separator "-" 2 + pick widths i
		]
		insert tail separator "+"
		;	column headings
		print separator
		repeat i cols [
			prin pad pick columns i pick widths i
		]
		print "|"
		print separator
		;	print results
		p: 0
		loop rows [
			foreach width widths [
				prin pad pick buffer p: p + 1 width
			]
			print "|"
		]
		print either rows > 1 [[separator "^/" rows "rows in" now/time/precise - time "seconds"]] [separator]
	]

	pad: make function! [
		value [any-type!]
		width [integer!]
		/local s
	] [
		either any-string? value [
			s: value while [s: find s "^/"] [change/part s #"¶" 2]	; replace/all
			insert/dup tail value " " width + 1 - length? value
		] [
			insert tail insert/dup value: mold/all value " " width - length? value " "
		]
		head insert value "| "
	]

	sql-error: make function! [
		error [string! integer!]
		/local rc
	] [
		all [integer? error rc: error error: *errmsg dbid]
		if error = "not an error" [
			error: select [
				0	"OK: Successful result"
				1	"ERROR: SQL error or missing database"
				2	"INTERNAL: An internal logic error in SQLite"
				3	"PERM: Access permission denied"
				4	"ABORT: Callback routine requested an abort"
				5	"BUSY: The database file is locked"
				6	"LOCKED: A table in the database is locked"
				7	"NOMEM: A malloc() failed"
				8	"READONLY: Attempt to write a readonly database"
				9	"INTERRUPT: Operation terminated by sqlite_interrupt()"
				10	"IOERR: Some kind of disk I/O error occurred"
				11	"CORRUPT: The database disk image is malformed"
				12	"NOTFOUND: (Internal Only) Table or record not found"
				13	"FULL: Insertion failed because database is full"
				14	"CANTOPEN: Unable to open the database file"
				15	"PROTOCOL: Database lock protocol error"
				16	"EMPTY: (Internal Only) Database table is empty"
				17	"SCHEMA: The database schema changed"
				18	"TOOBIG: Too much data for one row of a table"
				19	"CONSTRAINT: Abort due to constraint violation"
				20	"MISMATCH: Data type mismatch"
				21	"MISUSE: Library used incorrectly"
				22	"NOLFS: Uses OS features not supported on host"
				23	"AUTH: Authorization denied"
				100	"ROW: sqlite_step() has another row ready"
				101	"DONE: sqlite_step() has finished executing"
			] rc
			all [none? error error: "Unhandled error"]
		]
		all [log? write/append/lines %sqlite.log reform [now "ERR" error]]
		make error! reform ["SQLite" error]
	]

	;	Database access functions
	;		connect		Open a SQLite database
	;		database	Database tasks
	;		describe	Information about a table
	;		disconnect	Close database connection
	;		explain		Explain an SQL statement
	;		import		Insert a large number of rows at once
	;		indexes		List all indexes
	;		rows		Return row count
	;		sql			Prepare and execute an SQL statement
	;		tables		List all tables

	set 'connect make function! [
		"Open a SQLite database."
		database [file! block!]
		/create "Create database if non-existent"
		/flat "Do not return rows as blocks"
		/direct "Do not mold/load REBOL values"
		/no-copy "Clear buffer instead of copy"
		/timeout "Specify alternate retry limit (default is 5)"
		retries [integer!] "Number of 1 second interval retries if SQLITE_BUSY"
		/format "Format output"
		/info "Obtain column names and widths"
		/log "Log all SQL statements"
		/local tmp rc
	] [
		all [log? write/append/lines %sqlite.log reform [now "CON" mold database]]
		all [dbid sql-error "Already connected"]
		database: compose [(database)]
		;	database file(s) exist?
		unless find first database %/ [insert first database what-dir]
		unless create [
			foreach file database [
				unless exists? file [sql-error reform ["Database file" file "not found"]]
			]
		]
		;	open first file, then attach others
		either SQLITE_OK = rc: *open form to-local-file first database tmp: make struct! [p [integer!]] none [
			dbid: tmp/p
			if create [sql/flat/direct "PRAGMA page_size=4096"]
			foreach file next database [
				unless find file %/ [insert file what-dir]
				sql rejoin ["attach '" form to-local-file file "' as " replace last split-path file suffix? file ""]
			]
		] [sql-error rc]
		;	 directives
		flat?:		flat
		direct?:	direct
		no-copy?:	no-copy
		all [timeout retry: retries]
		format?:	format
		col-info?:	info
		log?:		log

		dbid
	]

	set 'database make function! [
		"Database tasks."
		/analyze "Gather statistics on indexes"
		/vacuum "Reclaim unused space"
		/check "Perform an integrity check"
	] [
		unless dbid [return none]
		all [analyze sql "analyze" return true]
		all [vacuum sql "vacuum" return true]
		all [check sql/flat/direct "PRAGMA integrity_check" return]
		sql/flat/direct "PRAGMA database_list"
	]

	set 'describe make function! [
		"Information about a database object (default is table)."
		object [string!]
		/index "Describes an index"
		/indexes "Indexes on table"
		/fkeys "Foreign keys that reference table"
		/local type
	] [
		type: switch/default true reduce [
			index	['index_info]		; "seqno" "cid" "name"
			indexes	['index_list]		; "seq" "name" "unique"
			fkeys	['foreign_key_list]	; ?
		] ['table_info]					; "cid" "name" "type" "notnull" "dflt_value" "pk"
		sql/flat/direct reform ["PRAGMA" type "(" object ")"]
	]

	set 'disconnect make function! [
		"Close database connection."
		/local rc
	] [
		all [log? write/append/lines %sqlite.log reform [now "DIS"]]
		any [dbid sql-error "Nothing to disconnect"]
		if SQLITE_OK <> rc: *close dbid [sql-error rc]
		dbid: none
	]

	set 'explain make function! [
		"Explain an SQL statement."
		statement [string! block!] "SQL statement"
	] [
		sql/flat/direct either string? statement [
			reform ["explain" statement]
		] [
			statement: copy/deep statement
			insert first statement "explain "
			statement
		]
	]

	import: make function! [
		"Insert a large number of rows at once."
		statement [string!] "INSERT statement"
		values [block!] "Values to be bound"
		/local val cols rows rc
	] [
		if none? dbid [sql-error "Not connected"]
		;	init
		cols: 0
		foreach char find statement #"?" [all [char = #"?" cols: cols + 1]]
		all [zero? cols sql-error "At least one bind var must be specified"]
		any [integer? rows: (length? values) / cols sql-error reform ["Values must be a multiple of" cols]]
		;	start transaction
		sql "begin"
		;	prepare statement
		unless SQLITE_OK = rc: *prepare dbid statement length? statement sid: make struct! [p [integer!]] none make struct! [[integer!]] none [sql-error rc]
		sid: sid/p
		;	bind each row - compose direct? and variables (rows, cols, sid, SQLITE_OK and SQLITE_DONE)
		do compose/deep [
			loop (rows) [
				all [100 = recycle-cnt: recycle-cnt + 1 recycle-cnt: 0 recycle]
				repeat i (cols) [
					if (SQLITE_OK) <> rc: switch/default type? val: first values [
						#[datatype! integer!]	[*bind-int (sid) i val]
						#[datatype! decimal!]	[*bind-double (sid) i val]
						#[datatype! binary!]	[*bind-blob (sid) i val: enbase val length? val 0]
						#[datatype! none!]		[*bind-null (sid) i]
					] [
						(either direct? [[*bind-text (sid) i val length? val 0]] [[*bind-text (sid) i val: mold/all val length? val 0]])
					] [sql-error rc]
					values: next values
				]
				if (SQLITE_DONE) <> rc: do-step (sid) [sql-error rc]
				*reset (sid)
			]
		]
		values: head values
		;	end transaction
		*finalize sid
		sql "commit"
	]

	set 'indexes make function! [
		"List all indexes."
	] [
		sql/flat/direct "select name,sql from sqlite_master where type = 'index' order by name"
	]

	set 'rows make function! [
		"Return row count."
		table [string!]
	][
		first sql/flat/direct reform ["select count(*) from" table]
	]

	set 'sql make function! [
		"Prepare and execute an SQL statement."
		statement [string! block!] "SQL statement"
		/flat "Do not return rows as blocks"
		/direct "Do not mold/load REBOL values"
		/local stmt val cols rc p idx s v
	] [
		time: now/time/precise
		all [100 = recycle-cnt: recycle-cnt + 1 recycle-cnt: 0 recycle]
		;	statement logging?
		if none? dbid [sql-error "Not connected"]
		all [log? write/append/lines %sqlite.log reform [now "SQL" mold statement]]
		;	refinements
		flat: any [flat? flat format?]
		direct: any [direct? direct]
		;	prepare statement
		stmt: either string? statement [statement] [first statement]
		;	check if this is a nested transaction statement
		switch stmt [
			"begin"		[if 1 < transaction: transaction + 1 [return true]]
			"commit"	[if 0 < transaction: transaction - 1 [return true]]
			"end"		[if 0 < transaction: transaction - 1 [return true]]
			"rollback"	[transaction: 0]
		]
		unless SQLITE_OK = rc: *prepare dbid stmt length? stmt sid: make struct! [p [integer!]] none make struct! [[integer!]] none [sql-error rc]
		sid: sid/p
		;	bind any ?
		if block? statement [
			repeat i length? next statement [
				if SQLITE_OK <> rc: switch/default type?/word val: pick next statement i [
					integer!	[*bind-int sid i val]
					decimal!	[*bind-double sid i val]
					binary!		[*bind-blob sid i val: enbase val length? val 0]
					none!		[*bind-null sid i]
				] [
					unless direct [
						val: either date? val [
							p: reform [val/year val/month val/day]
							all [val/month < 10 insert skip p 5 "0"]
							all [val/day < 10 insert skip p 8 "0"]
							poke p 5 #"-"
							poke p 8 #"-"
							if val/time [
								insert tail p "/"
								insert tail p val/time
								if 16 = length? p [insert tail p ":00"]
								if val/zone [
									insert tail p "+"
									insert tail p val/zone
								]
							]
							p
						] [mold/all val]
					]
					val: form val
					*bind-text sid i val length? val 0
				] [sql-error rc]
			]
		]
		;	return unless rows await
		unless find ["SEL" "EXP" "PRA"] copy/part stmt 3 [
			if SQLITE_DONE <> rc: do-step sid [*finalize sid sql-error rc]
			*finalize sid
			return SQLITE_OK
		]
		;	obtain column count (and optional names and widths)
		cols: *column-count sid
		if any [format? col-info?] [
			clear columns
			clear widths
			repeat i cols [
				insert tail columns val: *column-name sid -1 + i
				insert tail widths length? val
			]
		]
		;	allocate buffer
		either no-copy? [clear buffer] [buffer: copy []]
		p: buffer
		;	compose directives (flat, direct and col-info?) and variables (SQLITE_ROW, sid and cols)
		do compose/deep [
			while [(SQLITE_ROW) = rc: do-step (sid)] [
				(either flat [] [[insert/only tail buffer copy [] p: last buffer]])
				idx: 0
				repeat i (cols) [
					insert/only tail p val: do pick [
						[*column-integer (sid) idx]		; SQLITE_INTEGER
						[*column-double (sid) idx]		; SQLITE_REAL
						[(								; SQLITE_TEXT
							either direct [[*column-text (sid) idx]] [
								[
									s: *column-text (sid) idx
									v: load s
									either all [block? v #"[" <> first s] [rejoin v] [v]
								]
							]
						)]
						[debase *column-blob (sid) idx]	; SQLITE_BLOB
						[none]							; SQLITE_NULL
					] *column-type (sid) idx
					(either any [format? col-info?] [[poke widths i max pick widths i length? mold/all val]] [])
					idx: i
				]
			]
		]
		if SQLITE_DONE <> rc [*finalize sid sql-error rc]
		*finalize sid
		;	return result
		either format? [format] [buffer]
	]

	set 'tables make function! [
		"List all tables."
	] [
		sql/flat/direct "select tbl_name,sql from sqlite_master where type = 'table' order by tbl_name"
	]
]