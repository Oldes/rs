REBOL [
    Title: "RS - core script" 
    Date: 29-Mar-2007/11:19:37+2:00 
    Name: none 
    Version: none 
    File: none 
    Home: none 
    Author: none 
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
    require: none
] 
comment {
#### RS include: %prebol.r
#### Title:   "Prebol - Official REBOL Preprocessor"
#### Author:  ["Carl Sassenrath" "Holger Kruse" "Oldes"]
----} 
system/options/binary-base: 64 
error: func [[catch] msg] [throw make error! reform msg] 
process-source-comment?: true 
process-source: func [
    blk [any-block!] "Block of source to process" 
    size [integer!] "Starting size" 
    /local file data expr cmd else tmp path include-cmds header do-expr
] [
    do-expr: func [expr /local result] [
        if unset? set/any 'result do expr [
            print ["***" cmd "must return a value or none:" mold expr]
        ] 
        :result
    ] 
    include-cmds: [
        #include [
            data: load/all file 
            if data/1 = 'rebol [
                header: make object! [
                    title: "" 
                    author: ""
                ] 
                header: make header data/2 
                remove/part data 2 
                if process-source-comment? [
                    insert data compose [
                        comment (rejoin ["^/#### Include: " mold file "^/#### Title:   " mold header/title "^/#### Author:  " mold header/author "^/----"])
                    ] 
                    insert tail data compose [
                        comment (rejoin ["---- end of include " mold file " ----"])
                    ]
                ]
            ] 
            data
        ] 
        #include-string [
            read file
        ] 
        #include-binary [
            read/binary file
        ] 
        #include-block [
            data: load/all file 
            if data/1 = 'rebol [remove/part data 2] 
            head insert/only copy [] data
        ] 
        #include-eval [
            set/any 'data do file 
            head insert/only copy [] data
        ]
    ] 
    while [not tail? blk] [
        either issue? blk/1 [
            cmd: blk/1 
            either find include-cmds cmd [
                file: blk/2 
                if paren? :file [
                    file: do-expr reduce [file]
                ] 
                if not file? file [error ["***Invalid" cmd "file expression:" mold file]] 
                if not exists? file [error ["***" cmd "file not found:" mold file]] 
                size: size + size? file 
                if error? data: try select include-cmds cmd [
                    data: disarm :data 
                    error ["***" cmd file "error:" data/id "at" mold data/near]
                ] 
                remove/part blk 2 
                insert blk data
            ] [
                switch/default cmd [
                    #do [
                        expr: blk/2 
                        remove/part blk 2 
                        if data: do-expr expr [insert blk :data]
                    ] 
                    #if [
                        expr: blk/2 
                        data: blk/3 
                        remove/part blk 3 
                        if do-expr expr [insert blk :data]
                    ] 
                    #either [
                        expr: blk/2 
                        data: blk/3 
                        else: blk/4 
                        remove/part blk 4 
                        insert blk either do-expr expr [:data] [:else]
                    ] 
                    #include-files [
                        tmp: copy [] 
                        path: dirize blk/2 
                        foreach file blk/3 [
                            size: size + size? join path to-file file 
                            data: read/binary join path to-file file 
                            repend tmp [file data]
                        ] 
                        remove/part blk 3 
                        insert/only blk tmp
                    ] 
                    #comments [
                        process-source-comment?: either find [false off] blk/2 [false] [true] 
                        blk: skip blk 2
                    ]
                ] [
                    blk: next blk
                ]
            ]
        ] [
            blk: next blk
        ]
    ] 
    foreach item head blk [
        if block? :item [size: process-source item size]
    ] 
    size
] 
comment "---- end of RS include %prebol.r ----" 
comment {
#### RS include: %error-handler.r
#### Title:   "Error-handler"
#### Author:  "oldes, cyphre"
----} 
if system/version < 2.99.3 [
	attempt: func [value] [
		either error? set/any 'value try :value [
			print parse-error disarm value none
		] [get/any 'value]
	] 
	parse-error: func [
		error [object!] 
		/local type id arg1 arg2 arg3 wh
	] [
		type: error/type 
		id: error/id 
		wh: mold get/any in error 'where 
		either any [
			unset? get/any in error 'arg1 
			unset? get/any in error 'arg2 
			unset? get/any in error 'arg3
		] [
			arg1: arg2: arg3: "(missing value)"
		] [
			arg1: error/arg1 
			arg2: error/arg2 
			arg3: error/arg3
		] 
		rejoin ["** " system/error/:type/type ": " reduce either block? system/error/:type/:id [
				bind to-block system/error/:type/:id 'arg1
			] [
				form system/error/:type/:id
			] 
			newline 
			reform ["** Where: " wh newline "** Near: " mold error/near newline]
		]
	] 
]
comment "---- end of RS include %error-handler.r ----" 
rs: make object! [
    home: either any [error? try [rs-home] not dir? rs-home] [
        either found? i: find system/script/path %/projects/rs/latest/ [
            copy/part system/script/path index? i
        ] [system/script/path]
    ] [rs-home] 
    project-dirs: either exists? home/project-dirs.txt [
        load home/project-dirs.txt
    ] [
        if not exists? join home %projects/ [
            make-dir/deep join home %projects/
        ] 
        write home/project-dirs.txt "%projects/" 
        [%projects/]
    ] 
    if not block? project-dirs [project-dirs: reduce [project-dirs]] 
    was-dir: make block! 3 
    project: make object! [
        id: none 
        file: none 
        path: none 
        result: none 
        version: none
    ] 
    included-files: make block! [] 
    result: none 
    include: func [
        "Includes required files (if needed)" 
        header 
        /local tmp files version
    ] [
        if not error? try [files: header/Require] [
            rs-require-rule: [
                'rs-utils set tmp [file! | block!] (
                    if not block? tmp [tmp: append copy [] tmp] 
                    forall tmp [
                        if not system/options/quiet [
                            print ["Including:" rejoin [home/utils "/" tmp/1]]
                        ] 
                        either building > 0 [
                            insert tail out-build load rejoin [home/utils "/" tmp/1]
                        ] [
                            attempt reduce ['do rejoin [home/utils "/" tmp/1]]
                        ]
                    ]
                ) 
                | 
                'rs-style set tmp [file! | block!] (
                    if not block? tmp [tmp: append copy [] tmp] 
                    forall tmp [
                        if not system/options/quiet [
                            print ["Including:" rejoin [home/styles "/" tmp/1]]
                        ] 
                        either building > 0 [
                            if not system/options/quiet [
                                print "!!!!!!!!!!!"
                            ] 
                            insert tail out-build load rejoin [home/styles "/" tmp/1]
                        ] [
                            attempt reduce ['do rejoin [home/styles "/" tmp/1]]
                        ]
                    ]
                ) 
                | 'rs-project copy tmp [file! | lit-word! | word! | string! | block!] set version opt [tuple! | lit-word! | none] (
                    if not block? tmp [tmp: append copy [] tmp] 
                    forall tmp [
                        either none? find included-files tmp/1 [
                            if not system/options/quiet [
                                print ["Including RS project:" tmp/1 version]
                            ] 
                            either none? version [run tmp/1] [run/version tmp/1 version] 
                            insert included-files tmp/1
                        ] [
                            if not system/options/quiet [
                                print ["RS project already included:" tmp/1]
                            ]
                        ]
                    ]
                ) 
                | ['sdk (incl-dir: %sdk/source/) | 'lib (incl-dir: %library/)] set tmp [file! | block!] (
                    if not block? tmp [tmp: append copy [] tmp] 
                    use [inc-file was-dir] [
                    	was-dir: what-dir
                    	change-dir home/:incl-dir
                        forall tmp [
                            inc-file: rejoin [home incl-dir tmp/1] 
                            either none? find included-files inc-file [
                                if not system/options/quiet [print ["Including:" inc-file]] 
                                either building > 0 [
                                	insert tail out-build either all [not error? try [header/preprocess] header/preprocess] [
                  						process-source code: load inc-file 0
                  						code
                					] [ load inc-file ]
                                ] [
                                    attempt reduce ['do inc-file] 
                                    insert included-files inc-file
                                ]
                            ] [
                                if not system/options/quiet [
                                    print ["SDK or library file already included:" inc-file]
                                ]
                            ]
                        ]
                        change-dir was-dir
                    ]
                ) 
                | copy tmp file! (
                    if not system/options/quiet [
                        print ["Including:" tmp]
                    ] 
                    either building > 0 [
                        insert tail out-build load tmp
                    ] [
                        attempt reduce [tmp]
                    ]
                ) 
                | any-type!
            ] 
            if not block? files [files: append copy [] files] 
            parse/all files [any [
                    'Base set tmp block! (
                        if system/product = 'Base [
                            parse/all tmp [rs-require-rule]
                        ]
                    ) 
                    | 
                    rs-require-rule
                ]]
        ]
    ] 
    run: func [
        "Evaluates the project" 
        id "Which project to do" 
        /go "Go into this project directory and stay here" 
        /args in-args {Block with arguments for example: [version 1.0.0 usage]} 
        /fresh "Runs already included projects again as well" 
        /usage 
        /version v "If not specified the 'latest version is used" 
        /file f {Run this file from the project (by default it's file with the same name as project id)} 
        /local tmp header code pr hdr
    ] [
        if fresh [clear included-files] 
        if building > 0 [building: building + 1] 
        project/id: to-file id 
        project/version: either version [v] ['latest] 
        if args [
            if not none? tmp: select in-args 'version [project/version: tmp] 
            if not none? tmp: select in-args 'file [f: tmp]
        ] 
        project/path: get-project-dir/version id project/version 
        either exists? project/file: rejoin [project/path either none? f [join id ".r"] [f]] [
            if go [change-dir project/path] 
            insert was-dir what-dir 
            change-dir project/path 
            attempt [
                header: system/script/header: first tmp: copy load/header project/file 
                system/script/path: project/path 
                either building = 2 [
                    hdr: make header [
                        date: now 
                        require: none
                    ] 
                    insert out-build copy load/all rejoin [
                        "REBOL " skip (mold hdr) 13
                    ] 
                    hdr: none
                ] [
                    if building > 0 [
                        insert tail out-build compose [
                            comment (rejoin ["^/#### RS include: " mold last split-path project/file "^/#### Title:   " mold header/title "^/#### Author:  " mold header/author "^/----"])
                        ]
                    ]
                ] 
                pr: make project copy [] 
                include header 
                project: make pr copy [] 
                system/script/header: header 
                code: either any [object? tmp tail? tmp] [make block! []] [next tmp] 
                if all [not error? try [header/preprocess] header/preprocess] [
                    process-source code 0
                ] 
                either building > 0 [
                    insert tail out-build code 
                    if building > 2 [
                        insert tail out-build compose [
                            comment (rejoin ["---- end of RS include " mold last split-path project/file " ----"])
                        ]
                    ]
                ] [
                    attempt code
                ] 
                if usage [
                    print "===== USAGE EXAMPLE =====" 
                    probe header/usage 
                    either building > 0 [
                        insert tail out-build header/usage
                    ] [
                        attempt header/usage
                    ]
                ]
            ] 
            attempt [change-dir first was-dir] 
            remove was-dir
        ] [make error! "Project ID does not exists!"] 
        if building > 0 [building: building - 1] 
        :result
    ] 
    building: 0 
    build: func [
        {Tries to build project into one file (using %prebol.r)} 
        id "Which project to do" 
        /args in-args 
        /compressed 
        /data-only 
        /save /to file 
        /local tmp b
    ] [
        clear out-build 
        building: 1 
        run/fresh/args id either args [in-args] [copy []] 
        b: system/options/binary-base 
        either compressed [
            system/options/binary-base: 64 
            tmp: copy/part out-build 2 
            append tmp compose either data-only [
                [(compress mold skip out-build 2)]
            ] [[do load decompress (compress mold skip out-build 2)]] 
            out-build: tmp
        ] [
            out-build: head out-build
        ] 
        building: building - 1 
        if save [
            if not to [
                file: rejoin [home %builds/ id "_" project/version ".r"]
            ] 
            system/words/save file out-build 
            write file detab/size read file 2
        ] 
        system/options/binary-base: b 
        out-build
    ] 
    out-build: make block! 10000 
    project-exists?: func [id] [not none? get-project-dir id] 
    get-projects: func [/local ids tmp] [
        ids: make block! 500 
        foreach dir project-dirs [
            tmp: read dirize (either #"/" = first dir [dir] [join home dir]) 
            forall tmp [if #"/" = last tmp/1 [append ids head remove back tail tmp/1]]
        ] 
        ids
    ] 
    get-project-dir: func [id /version v /local tmp] [
        if not version [v: 'latest] 
        foreach dir project-dirs [
            tmp: rejoin [either #"/" = first dir [dir] [join home dir] id #"/" v #"/"] 
            if exists? tmp [
                return tmp
            ]
        ] 
        none
    ] 
    get-default-header: func [title] [
        make system/standard/script compose [
            title: (uppercase/part to-string title 1) 
            date: (now) 
            author: (system/user/name) 
            Email: (system/user/email)
        ]
    ] 
    go: func [
        id "project id" 
        /version v 
        /local dir
    ] [
        if not version [v: 'latest] 
        either any [
            none? dir: get-project-dir/version id v 
            not dir? dir
        ] [
            print "!!! invalid project id"
        ] [change-dir dir] 
        dir
    ] 
    new: func [
        "Makes ne project" 
        id "New project ID" 
        /import files 
        /in pdir "Makes new project in specified projects directory" 
        /local target tmp
    ] [
        project/id: to-file id 
        if not none? tmp: get-project-dir id [throw make error! join "Project ID already exists!^/^-" mold tmp] 
        either not in [pdir: dirize home/projects] [
            if #"/" <> first pdir [insert pdir home]
        ] 
        attempt [
            make-dir/deep project/path: rejoin [dirize pdir id "/latest/"] 
            target: rejoin [project/path id ".r"] 
            write target replace mold (get-default-header id) "make object!" "REBOL"
        ] 
        if import [
            if not block? files [files: head insert copy [] files] 
            foreach file files [
                probe file
            ]
        ] 
        system/words/run/args {"C:\Program Files\Emerald Editor Community\Crimson Editor 3.72\cedt.exe"} form to-local-file target 
        target
    ] 
    info: func ["Shows project info" id "Project ID" /version v] [
        project/id: to-file id 
        run 'dir-mapper 
        project/version: either version [v] ['latest] 
        dir-mapper/map/quiet project/path: rejoin [home %projects/ id "/" project/version "/"]
    ] 
    pack: func ["Makes RIP archive of the project version" id version] [
        attempt [
            do rs/home/utils/rip.r 
            filename: rejoin [to-file id "_" version ".rip"] 
            write/binary home/projects/:filename rip-pack project/path: get-project-dir/version id version filename to-file rejoin [id "/" version "/"]
        ]
    ] 
    help: func ["RS object help" /c co /local shelp tmp] [
        shelp: get in system/words 'help 
        tmp: get in self co 
        shelp tmp
    ]
]