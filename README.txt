This is part of my REBOL scripting (RS) environment.
So far there is just a few projects included, especially these which are related to working with Flash XFL sources and SWF files.

Note that it's on your risk. It may contain a lot of code which were done just for my special needs. So take it or leave it. Also if you are not on Windows, you must get ImageMagick for your platform.

If you want to use it anyway, you must get REBOL -> http://www.rebol.com
Then you can start running the start.r script (or something like that) and using the scripts from console, for example to run REBOL/Flash dialect use:

>> rs/run/go 'rswf
>> exam-swf/file %examples/compiled/demon.swf
Searching the binary file... -------------------------
make object! [
    version: 5
    frame-size: [0 8140 0 7400]
    frame-rate: 12
    frame-count: 1
]
10451734
setBackgroundColor(09): 0.0.0
DefineBitsJPEG2(21):
    ID: 1
    JPEGData: 10908 Bytes = #{FFD8FFDB004300100B0C...
[0 8140 0 7400]
formatFillStyle: [65 [1 [[20.0 20.0] none [0 0]]]]
DefineShape(02):
    ID: 2
    Bounds: [0 8140 0 7400]
    StylesAndShapes: [
        FillStyles:
            #1 clipped bitmap ID:1
                Scale: [20.0 20.0]
                Translate: [0 0]
        LineStyles:
        ShapeRecords:
            Style:
            ChangeStyle:
                Move: [8140 7400]
                FillStyle1: 1
            Line: -8140 0 0 -7400 8140 0 0 7400
    ]
PlaceObject2(26):
    Depth: 1
    Move?: false
    Character: 2
        Translate: [0 0]
showFrame(01):x
end(00):x
>>


If you need to pack a projects which require other subprojects or other files so you could run it without RS, you can use 'rs/build' or 'rs/build/save' commands like:

>> rs/build 'cookies-daemon
== [REBOL [
        Title: "Cookies-daemon"
        Date: 7-Nov-2011/8:30:44+1:00
        Name: none
        Version: 1.2.2
   ...
