REBOL [
    Title: "R2-forward"
    Date: 21-Jul-2011/11:25:07+2:00
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

;object: :context

funct: func [
    "Defines a function with all set-words as locals."
    [catch]
    spec [block!] {Help string (opt) followed by arg words (and opt type and string)}
    body [block!] "The body block of the function"
    /with "Define or use a persistent object (self)"
    object [object! block!] "The object or spec"
    /extern words [block!] "These words are not local"
    /local r ws wb a
][
    spec: copy/deep spec
    body: copy/deep body
    ws: make block! length? spec
    parse spec [any [
            set-word! | set a any-word! (insert tail ws to-word a) | skip
        ]]
    if with [
        unless object? object [object: make object! object]
        bind body object
        insert tail ws first object
    ]
    insert tail ws words
    wb: make block! 12
    parse body r: [any [
            set a set-word! (insert tail wb to-word a) |
            hash! | into r | skip
        ]]
    unless empty? wb: exclude wb ws [
        remove find wb 'local
        unless find spec /local [insert tail spec /local]
        insert tail spec wb
    ]
    throw-on-error [make function! spec body]
]