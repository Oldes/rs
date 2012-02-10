REBOL [
	title: "Start RS in console"
]

with: func[obj body][do bind body obj]
drc:  does[do read clipboard://]
tm:   func[count [integer!] code [block!] /local t][t: now/time/precise loop count code probe now/time/precise - t]
ls: :list-dir
cd: :change-dir

dir_lib:               ;used to store external libraries
dir_imagemagick: %lib/ ;used by imagick to load MagickWand's dll or the convert app;

do %rs.r
print "RS ready"

halt