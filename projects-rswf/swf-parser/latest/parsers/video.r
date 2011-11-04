rebol [
	title: "SWF video related parse functions"
	purpose: "Functions for parsing video related tags in SWF files"
]

	parse-DefineVideoStream: does [reduce[
		readID
		readUI16 ;NumFrames
		readUI16 ;Width
		readUI16 ;Height
		readUB 5 ;VideoFlagsReserved
		readUB 2 ;VideoFlagsDeblocking
		readBitLogic ;VideoFlagsSmoothing
		readUI8  ;CodecID
	]]
	
	parse-VideoFrame: does [reduce[
		readUsedID ;StreamID
		readUI16   ;FrameNum
		readRest   ;VideoData
	]]