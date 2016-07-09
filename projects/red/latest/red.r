REBOL [
    Title: "Red"
    Date: 20-Jun-2011/11:49:46+2:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "Oldes"
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
    Email: none
]

change-dir system/options/home: red-root-dir: %/c/dev/git/red/
error? try [ change rs/was-dir red-root-dir ]

unset 'red ;<-- forces to reload compiler
unset 'system-dialect

attempt: func [
    {Tries to evaluate and returns result or NONE on error.}
    [throw]
    value
][
    unless error? set/any 'value try :value [get/any 'value]
]

rc: func[
    "Red compile"
     args [string!]
     /clean
][
    either all [value? 'redc object? :redc not clean][
        system/script/args: args
        system/script/parent/path: red-root-dir
        redc/main
    ][
        do/args red-root-dir/red.r args
    ]
]

print {
rc "-v 0 %environment/console/console.red"
do/args %red.r "%../Red-sfml-bindings/game-engine.red"
do/args %red.r "%tests/view-test.red"
do/args %red.r "%tests/vid.red"
do/args %red.r "-t Windows %environment/console/gui-console.red"
do/args %red-system/rsc.r "-v 3 %tests/m.reds"
do/args %red-system/rsc.r "-v 0 %tests/iMagick.reds"
call/console "red-system/builds/iMagick.exe"
}


