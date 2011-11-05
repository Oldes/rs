REBOL [
	title: "Start RS in console"
]

with: func[obj body][do bind body obj]

dir_imagemagick: %lib/ ;used by imagick to load MagickWand's dll or the convert app;

do %rs.r
print "RS ready"

halt