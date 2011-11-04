REBOL [
    Title: "Error-handler"
    Date: 26-Mar-2004/12:11:21+1:00
    Name: none
    Version: 0.1.0
    File: none
    Home: none
    Author: "oldes, cyphre"
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

if system/version < 2.99.3 [
	attempt*: func[value ][
		either error? set/any 'value try :value [
			print parse-error disarm value none
		][get/any 'value]
	]
	
	parse-error:  func[
		error [object!]
		/local type id arg1 arg2 arg3 wh
	][
		type: error/type
		id: error/id
		wh: mold get/any in error 'where
		either any [
			unset? get/any in error 'arg1
			unset? get/any in error 'arg2
			unset? get/any in error 'arg3
		][
			arg1: arg2: arg3: "(missing value)"
		][
			arg1: error/arg1
			arg2: error/arg2
			arg3: error/arg3
		]
		rejoin ["** " system/error/:type/type ": " reduce either block? system/error/:type/:id [
				bind to-block system/error/:type/:id 'arg1
			 ][
				form system/error/:type/:id
			 ]
			newline
		 	reform ["** Where: " wh  newline  "** Near: " mold error/near newline]
	 	]
	]
]
