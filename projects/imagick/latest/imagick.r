REBOL [
    Title: "Imagick"
    Date: 25-Oct-2007/15:40:53+2:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "David Oliva (commercial)"
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
    Email: oliva.david@seznam.cz
]


unless any [
	all [value? 'dir_imagemagick exists? dir_imagemagick]
	all [value? 'rs exists? dir_imagemagick: dirize rs/home/lib]
	exists? dir_imagemagick: %/c/utils/imagemagick/
	exists? dir_imagemagick: %"/c/Program Files/ImageMagick/"
][
	print "Set imagick/dir_imagemagick variable to directory where is CONVERT exe!"
]

