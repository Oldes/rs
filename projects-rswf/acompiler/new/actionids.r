rebol []

local-constants: make hash! [
	;key codes:
	Backspace 8
	Tab 9
	Clear 12
	Enter 13
	Shift 16
	Control 17
	Alt 18
	CapsLock 20
	Esc 27
	Spacebar 32
	PageUp 33
	PageDown 34
	End 35
	Home 36
	Left 37
	Up 38
	Right 39
	Down 40
	Insert 45
	Delete 46
	Help 47
	NumLock 144
	
	F1 112 F2 113 F3 114 F4 115 F5 116 F6 117
	F7 118 F8 119 F9 120 F10 121 F11 122 F12 123
	
	PI 3.14159265358979
]

properties: make hash! [
	_x            0
	_y            1
	_xscale       2
	_yscale       3
	_currentframe 4
	_totalframes  5
	_alpha        6
	_visible      7
	_width        8
	_height       9
	_rotation     10
	_target	      11
	_framesloaded 12
	_name	      13
	_droptarget   14
	_url	      15
	_highquality  16
	_focusrect    17
	_soundbuftime 18
	_quality      19
	_xmouse       20
	_ymouse       21
]


path-shortcuts: make hash! [
	Date!	Date
	Color!  Color
	BitmapFilter!          flash.filters.BitmapFilter
	BevelFilter!           flash.filters.BevelFilter
	BlurFilter!            flash.filters.BlurFilter
	ColorMatrixFilter!     flash.filters.ColorMatrixFilter
	ConvolutionFilter!     flash.filters.ConvolutionFilter
	DisplacementMapFilter! flash.filters.DisplacementMapFilter
	DropShadowFilter!      flash.filters.DropShadowFilter
	GlowFilter!            flash.filters.GlowFilter
	GradientBevelFilter!   flash.filters.GradientBevelFilter
	GradientGlowFilter!    flash.filters.GradientGlowFilter
	
	BitmapData!         flash.display.BitmapData
	
	ColorTransform!     flash.geom.ColorTransform
	Matrix!             flash.geom.Matrix
	Point!              flash.geom.Point
	Rectangle!          flash.geom.Rectangle
	Transform!          flash.geom.Transform
	
	ExternalInterface!  flash.external.ExternalInterface
	
	FileReference!      flash.net.FileReference
	FileReferenceList!  flash.net.FileReferenceList
	
	Locale!             mx.lang.Locale
	
	TextRenderer!       flash.text.TextRenderer
]

 	
actionIds: make hash! [
	aEnd			#{00}
	aNextFrame		#{04}
	aPrevFrame		#{05}
	aPlay			#{06}
	aStop			#{07}
	aToggleQuality	#{08}
	aStopSounds		#{09}
	aGotoFrame		#{81}
	aGetURL			#{83}
	aWaitForFrame	#{8A}
	aSetTarget		#{8B}
	aGoToLabel		#{8C}
	aPush			#{96}
	aPop			#{17}
	aAdd			#{0A}
	aSubtract		#{0B}
	aMultiply		#{0C}
	aDivide			#{0D}
	aEquals			#{0E}
	aLess			#{0F}
	aAnd			#{10}
	aOr				#{11}
	aNot			#{12}
	aStringEquals	#{13}
	aStringLength	#{14}
	aStringAdd		#{21}
	aStringExtract	#{15}
	aStringLess		#{29}
	aMBStringLength	#{31}
	aMBStringExtract	#{35}
	aToInteger		#{18}
	aCharToAscii	#{32}
	aAsciiToChar	#{33}
	aMBCharToAscii	#{36}
	aMBAsciiToChar	#{37}
	aJump			#{99}
	aIf				#{9D}
	aCall			#{9E}
	aGetVariable	#{1C}
	aSetVariable	#{1D}
	aGetURL2		#{9A}
	aGotoFrame2		#{9F}
	aSetTarget2		#{20}
	aGetProperty	#{22}
	aSetProperty	#{23}
	aCloneSprite	#{24}
	aRemoveSprite	#{25}
	aStartDrag		#{27}
	aEndDrag		#{28}
	aWaitForFrame2	#{8D}
	aTrace			#{26}
	aGetTime		#{34}
	aRandomNumber	#{30}
	aCallFunction	#{3D}
	aCallMethod		#{52}
	aConstantPool	#{88}
	aDefineFunction	#{9B}
	aDefineLocal	#{3C}
	aDefineLocal2	#{41}
	aDefineObject	#{43}
	aDelete			#{3A}
	aDelete2		#{3B}
	aEnumerate		#{46}
	aEquals2		#{49}
	aGetMember		#{4E}
	aInitArray		#{42}
	aNewMethod		#{53}
	aNewObject		#{40}
	aSetMember		#{4F}
	aTargetPath		#{45}
	aWith			#{94}
	aToNumber		#{4A}
	aToString		#{4B}
	aTypeOf			#{44}
	aAdd2			#{47}
	aLess2			#{48}
	aModulo			#{3F}
	aBitAnd			#{60}
	aBitLShift		#{63}
	aBitOr			#{61}
	aBitRShift		#{64}
	aBitURShift		#{65}
	aBitXor			#{62}
	aDecrement		#{51}
	aIncrement		#{50}
	aPushDuplicate	#{4C}
	aReturn			#{3E}
	aStackSwap		#{4D}
	aStoreRegister	#{87}
	aInstanceOf		#{54}
	aEnumerate2		#{55}
	aStrictEqual	#{66}
	aGreater		#{67}
	aStringGreater	#{68}
	aExtends		#{69}
	aThrow			#{2A}
	aCastOp			#{2B}
	aImplementsOp	#{2C}
	aDefineFunction2	#{8E}
	aTry			#{8F}
	
	aFscommand2	#{2D}
]