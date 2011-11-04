rebol [
	title: "SWF control tags related parse functions"
	purpose: "Functions for control tags in SWF files"
]

	parse-ExportAssets: has[result][
		result: copy []
		loop readUI16 [
			repend result [readUsedID readSTRING]
		]
		result
	]
	
	parse-ImportAssets: has[result][reduce [
		readSTRING ;URL
		either swfVersion >= 8 [
			reduce [
				readUI8	;f_version;	/* must be set to 1 */
				readUI8 ;f_reserved;
			]
		][ none]
		(
			result: copy []
			loop readUI16 [
				repend result [readID readSTRING]
			]
			result
		)
	]]
	parse-ImportAssets2: :parse-ImportAssets ;Don't know what's the difference

	
	parse-EnableDebugger:  does [readRest]
	parse-EnableDebugger2: does [reduce [
		readUI16 ;reserved
		readRest
	]]
	
	parse-ScriptLimits: does [reduce[
		readUI16 ;MaxRecursionDepth
		readUI16 ;ScriptTimeoutSeconds
	]]
	
	parse-SetTabIndex: does [reduce[
		readUI16 ;Depth
		readUI16 ;TabIndex
	]]
	
	parse-FileAttributes: does [
		print ["...FileAtts:" mold inBuffer]
		reduce[
		readUB 3 ;reserved
		readBitLogic ;hasMetadata
		readBitLogic ;actionScript3
		readBitLogic ;suppressCrossDomainCaching
		readBitLogic ;swfRelativeUrls
		readBitLogic ;useNetwork
		readUB 24    ;reserved
	]]
	
	parse-DefineBinaryData: does [reduce[
		readID
		readSI32 ;reserved
		readRest ;data
	]]
	
	parse-DefineScalingGrid: does [reduce[
		readUsedID ;sprite or button to use with
		readRECT
	]]
	
	parse-DefineSceneAndFrameLabelData: has[scenes frameLabels][
		scenes: copy []
		
		loop readUI8 [
			insert tail scenes reduce [
				readUI30
				as-string readString
				
			]
		]
		probe new-line/skip scenes true 2
		frameLabels: copy []
		loop readUI8 [
			insert tail frameLabels reduce [
				readUI30
				as-string readString
			]
		]
		probe new-line/skip frameLabels true 2
		reduce [scenes frameLabels]
	]
	
	parse-SerialNumber: does [
		reduce [
			readSI32 ;product
			readSI32 ;edition
			readUI8  ;majorVersion
			readUI8  ;minorVersion
			readBytes 8 ;build
			readBytes 8 ;compileDate
		]
	]	
