REBOL [
    Title: "Exif-parser"
    Date: 3-Feb-2004/14:27:06+1:00
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
    Email: oliva.david@seznam.cz
]

ctx-exif: make object! [
	v: v2: tmp: none
	IntelAlign?: true
	BYTE:  [copy v 1 skip (v: to integer! to binary! v)]
	UI16:  [copy v 2 skip (v: to integer! to binary! v)]
	SHORT: [copy v 2 skip (v: to integer! either IntelAlign? [head reverse to binary! v][to binary! v])]
	LONG:  [copy v 4 skip (v: to integer! either IntelAlign? [head reverse to binary! v][to binary! v])]
	RATIONAL: [copy v 4 skip copy v2 4 skip (
		v: (to integer! either IntelAlign? [head reverse to binary! v ][to binary! v ]) / 
		   (to integer! either IntelAlign? [head reverse to binary! v2][to binary! v2])
		)
	]
	
	exif-data:   make binary! 20000
	ifd0-data:   make block! 32
	ifd1-data:   make block! 40
	subifd-data: make block! 40
	
	thumbnail: none
	thumbnail-bin: none
	
	ifd-tag-types: [
		;tagID "tag Name" {tag description}
		
		;######Pointers
		34665	"Exif IFD Pointer" {A pointer to the Exif IFD. Interoperability, Exif IFD has the same structure as that of the IFD specified in TIFF. Ordinarily, however, it does not contain image data as in the case of TIFF.}
		34853	"GPS Info IFD Pointer" {A pointer to the GPS Info IFD. The Interoperability structure of the GPS Info IFD, like that of Exif IFD, has no image data.}
		40965	"Interoperability IFD Pointer" {The Interoperability structure of Interoperability IFD is same as TIFF defined IFD structure but does not contain the image data characteristically compared with normal TIFF IFD.}
		
		;######Tags relating to image data structure
		256	"Image Width" {The number of columns of image data, equal to the number of pixels per row. In JPEG compressed data a JPEG marker is used instead of this tag.}
		257	"Image Length" {The number of rows of image data. In JPEG compressed data a JPEG marker is used instead of this tag.}
		258	"BitsPerSample" {The number of bits per image component. In this standard each component of the image is 8 bits, so the value for this tag is 8. See also SamplesPerPixel. In JPEG compressed data a JPEG marker is used instead of this tag.}
		259 "Compression" {The compression scheme used for the image data. When a primary image is JPEG compressed, this designation is not necessary and is omitted. When thumbnails use JPEG compression, this tag value is set to 6.}
		262	"PhotometricInterpretation" {The pixel composition. In JPEG compressed data a JPEG marker is used instead of this tag.}
		274	"Orientation" {The image orientation viewed in terms of rows and columns.}
		277	"SamplesPerPixel" {The number of components per pixel. Since this standard applies to RGB and YCbCr images, the value set for this tag is 3. In JPEG compressed data a JPEG marker is used instead of this tag.}
		284	"PlanarConfiguration" {Indicates whether pixel components are recorded in chunky or planar format. In JPEG compressed files a JPEG marker is used instead of this tag. If this field does not exist, the TIFF default of 1 (chunky) is assumed.}
		530	"YCbCrSubSampling" {The sampling ratio of chrominance components in relation to the luminance component. In JPEG compressed data a JPEG marker is used instead of this tag.}
		531 "YCbCrPositioning" {The position of chrominance components in relation to the luminance component. This field is designated only for JPEG compressed data or uncompressed YCbCr data. The TIFF default is 1 (centered); but when Y:Cb:Cr = 4:2:2 it is recommended in this standard that 2 (co-sited) be used to record data, in order to improve the image quality when viewed on TV systems. When this field does not exist, the reader shall assume the TIFF default. In the case of Y:Cb:Cr = 4:2:0, the TIFF default (centered) is recommended. If the reader does not have the capability of supporting both kinds of YCbCrPositioning, it shall follow the TIFF default regardless of the value in this field. It is preferable that readers be able to support both centered and co-sited positioning.}
		282	"XResolution" {The number of pixels per ResolutionUnit in the ImageWidth direction. When the image resolution is unknown, 72 [dpi] is designated.}
		283	"YResolution" {The number of pixels per ResolutionUnit in the ImageLength direction. The same value as XResolution is designated.}
		296	"ResolutionUnit" {The unit for measuring XResolution and YResolution. The same unit is used for both XResolution and YResolution. If the image resolution in unknown, 2 (inches) is designated. 3 = centimeters}
		
		;######## Tags relating to recording offset
		273	"StripOffsets" {For each strip, the byte offset of that strip. It is recommended that this be selected so the number of strip bytes does not exceed 64 Kbytes. With JPEG compressed data this designation is not needed and is omitted. See also RowsPerStrip and StripByteCounts.}
		278	"RowsPerStrip" {The number of rows per strip. This is the number of rows in the image of one strip when an image is divided into strips. With JPEG compressed data this designation is not needed and is omitted. See also RowsPerStrip and StripByteCounts.}
		279	"StripByteCounts" {The total number of bytes in each strip. With JPEG compressed data this designation is not needed and is omitted.}
		513	"JPEGInterchangeFormat" {The offset to the start byte (SOI) of JPEG compressed thumbnail data. This is not used for primary image JPEG data.}
		514	"JPEGInterchangeFormatLength" {The number of bytes of JPEG compressed thumbnail data. This is not used for primary image JPEG data. JPEG thumbnails are not divided but are recorded as a continuous JPEG bitstream from SOI to EOI. APPn and COM markers should not be recorded. Compressed thumbnails shall be recorded in no more than 64 Kbytes, including all other data to be recorded in APP1.}
		;####### Tags Relating to Image Data Characteristics
		301	"TransferFunction" {A transfer function for the image, described in tabular style. Normally this tag is not necessary, since color space is specified in the color space information tag (ColorSpace).}
		318	"WhitePoint" {The chromaticity of the white point of the image. Normally this tag is not necessary, since color space is specified in the color space information tag (ColorSpace).}
		319	"PrimaryChromaticities" {The chromaticity of the three primary colors of the image. Normally this tag is not necessary, since color space is specified in the color space information tag (ColorSpace).}
		529 "YCbCrCoefficients" {The matrix coefficients for transformation from RGB to YCbCr image data. No default is given in TIFF; but here the characteristics given in Annex E, "Color Space Guidelines," is used as the default.}
		532	"ReferenceBlackWhite" {The reference black point value and reference white point value. No defaults are given in TIFF, but the values below are given as defaults here. The color space is declared in a color space information tag, with the default being the value that gives the optimal image characteristics Interoperability these conditions.}
		
		;####### Other Tags
		306	"DateTime" {The date and time of image creation. In this standard it is the date and time the file was changed. The format is "YYYY:MM:DD HH:MM:SS" with time shown in 24-hour format, and the date and time separated by one blank character [20.H]. When the date and time are unknown, all the character spaces except colons (":") may be filled with blank characters, or else the Interoperability field may be filled with blank characters. The character string length is 20 bytes including NULL for termination. When the field is left blank, it is treated as unknown.}
		270	"ImageDescription" {A character string giving the title of the image. It may be a comment such as "1988 company picnic" or the like. Two-byte character codes cannot be used. When a 2-byte code is necessary, the Exif Private tag UserComment is to be used.}
		271	"Make" {The manufacturer of the recording equipment. This is the manufacturer of the DSC, scanner, video digitizer or other equipment that generated the image. When the field is left blank, it is treated as unknown.}
		272	"Model" {The model name or model number of the equipment. This is the model name of number of the DSC, scanner, video digitizer or other equipment that generated the image. When the field is left blank, it is treated as unknown.}
		305	"Software" {This tag records the name and version of the software or firmware of the camera or image input device used to generate the image. The detailed format is not specified, but it is recommended that the example shown below be followed. When the field is left blank, it is treated as unknown.}
		315	"Artist" {This tag records the name of the camera owner, photographer or image creator. The detailed format is not specified, but it is recommended that the information be written as in the example below for ease of Interoperability. When the field is left blank, it is treated as unknown.}
		33432	"Copyright" {Copyright information. In this standard the tag is used to indicate both the photographer and editor copyrights. It is the copyright notice of the person or organization claiming rights to the image. The Interoperability copyright statement including date and rights should be written in this field; e.g., "Copyright, John Smith, 19xx. All rights reserved." In this standard the field records both the photographer and editor copyrights, with each recorded in a separate part of the statement. When there is a clear distinction between the photographer and editor copyrights, these are to be written in the order of photographer followed by editor copyright, separated by NULL (in this case, since the statement also ends with a NULL, there are two NULL codes) (see example 1). When only the photographer copyright is given, it is terminated by one NULL code (see example 2). When only the editor copyright is given, the photographer copyright part consists of one space followed by a terminating NULL code, then the editor copyright is given (see example 3). When the field is left blank, it is treated as unknown.}
		
		;####### Tags Relating to Version
		36864	"ExifVersion" {The version of this standard supported. Nonexistence of this field is taken to mean nonconformance to the standard (see section 4.2). Conformance to this standard is indicated by recording "0220" as 4-byte ASCII. Since the type is UNDEFINED, there is no NULL for termination.}
		40960	"FlashpixVersion" {The Flashpix format version supported by a FPXR file. If the FPXR function supports Flashpix format Ver. 1.0, this is indicated similarly to ExifVersion by recording "0100" as 4-byte ASCII. Since the type is UNDEFINED, there is no NULL for termination.}
		
		;####### Tag Relating to Color Space
		40961	"ColorSpace" {The color space information tag (ColorSpace) is always recorded as the color space specifier. Normally sRGB (=1) is used to define the color space based on the PC monitor conditions and environment. If a color space other than sRGB is used, Uncalibrated (=FFFF.H) is set. Image data recorded as Uncalibrated can be treated as sRGB when it is converted to Flashpix. On sRGB see Annex E.}
		
		;###### Tags Relating to Image Configuration
		40962	"PixelXDimension" {Information specific to compressed data. When a compressed file is recorded, the valid width of the meaningful image shall be recorded in this tag, whether or not there is padding data or a restart marker. This tag should not exist in an uncompressed file. For details see section 2.8.1 and Annex F.}
		40963	"PixelYDimension" {Information specific to compressed data. When a compressed file is recorded, the valid height of the meaningful image shall be recorded in this tag, whether or not there is padding data or a restart marker. This tag should not exist in an uncompressed file. For details see section 2.8.1 and Annex F. Since data padding is unnecessary in the vertical direction, the number of lines recorded in this valid image height tag will in fact be the same as that recorded in the SOF.}
		37121	"ComponentsConfiguration" {Information specific to compressed data. The channels of each component are arranged in order from the 1st component to the 4th. For uncompressed data the data arrangement is given in the PhotometricInterpretation tag. However, since PhotometricInterpretation can only express the order of Y,Cb and Cr, this tag is provided for cases when compressed data uses components other than Y, Cb, and Cr and to enable support of other sequences.}
		37122	"CompressedBitsPerPixel" {Information specific to compressed data. The compression mode used for a compressed image is indicated in unit bits per pixel.}
		
		;####### Tags Relating to User Information
		37500	"MakerNote" {A tag for manufacturers of Exif writers to record any desired information. The contents are up to the manufacturer, but this tag should not be used for any other than its intended purpose.}
		37510	"UserComment" {A tag for Exif users to write keywords or comments on the image besides those in ImageDescription, and without the character code limitations of the ImageDescription tag.
		The character code used in the UserComment tag is identified based on an ID code in a fixed 8-byte area at the
start of the tag data area. The unused portion of the area is padded with NULL ("00.H"). ID codes are assigned by
means of registration. The designation method and references for each character code are given in Table 6 . The
value of Count N is determined based on the 8 bytes in the character code area and the number of bytes in the
user comment part. Since the TYPE is not ASCII, NULL termination is not necessary.

	ASCII   	41.H, 53.H, 43.H, 49.H, 49.H, 00.H, 00.H, 00.H
	JIS     	4A.H, 49.H, 53.H, 00.H, 00.H, 00.H, 00.H, 00.H
	Unicode 	55.H, 4E.H, 49.H, 43.H, 4F.H, 44.H, 45.H, 00.H
	Undefined	00.H, 00.H, 00.H, 00.H, 00.H, 00.H, 00.H, 00.H}
		
		;####### Tag Relating to Related File
		40964	"RelatedSoundFile" {This tag is used to record the name of an audio file related to the image data. The only relational information recorded here is the Exif audio file name and extension (an ASCII string consisting of 8 characters + '.' + 3 characters). The path is not recorded. Stipulations on audio are given in section 0. File naming conventions are given in section 0.}
		
		;####### Tags Relating to Date and Time
		36867	"DateTimeOriginal" {The date and time when the original image data was generated. For a DSC the date and time the picture was taken are recorded. The format is "YYYY:MM:DD HH:MM:SS" with time shown in 24-hour format, and the date and time separated by one blank character [20.H]. When the date and time are unknown, all the character spaces except colons (":") may be filled with blank characters, or else the Interoperability field may be filled with blank characters. The character string length is 20 bytes including NULL for termination. When the field is left blank, it is treated as unknown.}
		36868	"DateTimeDigitized" {The date and time when the image was stored as digital data. If, for example, an image was captured by DSC and at the same time the file was recorded, then the DateTimeOriginal and DateTimeDigitized will have the same contents. The format is "YYYY:MM:DD HH:MM:SS" with time shown in 24-hour format, and the date and time separated by one blank character [20.H]. When the date and time are unknown, all the character spaces except colons (":") may be filled with blank characters, or else the Interoperability field may be filled with blank characters. The character string length is 20 bytes including NULL for termination. When the field is left blank, it is treated as unknown.}
		37520	"SubsecTime" {A tag used to record fractions of seconds for the DateTime tag.}
		37521	"SubsecTimeOriginal" {A tag used to record fractions of seconds for the DateTimeOriginal tag.}
		37522	"SubsecTimeDigitized" {A tag used to record fractions of seconds for the DateTimeDigitized tag.}
		
		;####### Tags Relating to Picture-Taking Conditions
		33434	"ExposureTime" {Exposure time, given in seconds (sec).}
		33437	"FNumber" {The F number.}
		34850	"ExposureProgram" {The class of the program used by the camera to set exposure when the picture is taken. The tag values are as follows.
		0 = Not defined
		1 = Manual
		2 = Normal program
		3 = Aperture priority
		4 = Shutter priority
		5 = Creative program (biased toward depth of field)
		6 = Action program (biased toward fast shutter speed)
		7 = Portrait mode (for closeup photos with the background out of focus)
		8 = Landscape mode (for landscape photos with the background in focus)
		Other = reserved}
		34852	"SpectralSensitivity" {Indicates the spectral sensitivity of each channel of the camera used. The tag value is an ASCII string compatible with the standard developed by the ASTM Technical committee.}
		34855	"ISOSpeedRatings" {Indicates the ISO Speed and ISO Latitude of the camera or input device as specified in ISO 12232.}
		34856	"OECF" {Indicates the Opto-Electric Conversion Function (OECF) specified in ISO 14524. OECF is the relationship between the camera optical input and the image values.}
		37377	"ShutterSpeedValue" {Shutter speed. The unit is the APEX (Additive System of Photographic Exposure) setting (see Annex C).}
		37378	"ApertureValue" {The lens aperture. The unit is the APEX value.}
		37379	"BrightnessValue" {The value of brightness. The unit is the APEX value. Ordinarily it is given in the range of -99.99 to 99.99. Note that if the numerator of the recorded value is FFFFFFFF.H, Unknown shall be indicated.}
		37380	"ExposureBiasValue" {The exposure bias. The unit is the APEX value. Ordinarily it is given in the range of –99.99 to 99.99.}
		37381	"MaxApertureValue" {The smallest F number of the lens. The unit is the APEX value. Ordinarily it is given in the range of 00.00 to 99.99, but it is not limited to this range.}
		37382	"SubjectDistance" {The distance to the subject, given in meters. Note that if the numerator of the recorded value is FFFFFFFF.H, Infinity shall be indicated; and if the numerator is 0, Distance unknown shall be indicated.}
		37383	"MeteringMode" {The metering mode.
		0 = unknown
		1 = Average
		2 = CenterWeightedAverage
		3 = Spot
		4 = MultiSpot
		5 = Pattern
		6 = Partial
		Other = reserved
		255 = other}
		37384	"LightSource" {The kind of light source.
		0 = unknown
		1 = Daylight
		2 = Fluorescent
		3 = Tungsten (incandescent light)
		4 = Flash
		9 = Fine weather
		10 = Cloudy weather
		11 = Shade
		12 = Daylight fluorescent (D 5700 – 7100K)
		13 = Day white fluorescent (N 4600 – 5400K)
		14 = Cool white fluorescent (W 3900 – 4500K)
		15 = White fluorescent (WW 3200 – 3700K)
		17 = Standard light A
		18 = Standard light B
		19 = Standard light C
		20 = D55
		21 = D65
		22 = D75
		23 = D50
		24 = ISO studio tungsten
		255 = other light source
		Other = reserved}
		37385	"Flash" {This tag indicates the status of flash when the image was shot. Bit 0 indicates the flash firing status, bits 1 and 2 indicate the flash return status, bits 3 and 4 indicate the flash mode, bit 5 indicates whether the flash function is present, and bit 6 indicates "red eye" mode}
		37396	"SubjectArea" {This tag indicates the location and area of the main subject in the overall scene.}
		37386	"FocalLength" {The actual focal length of the lens, in mm. Conversion is not made to the focal length of a 35 mm film camera.}
		41483	"FlashEnergy" {Indicates the strobe energy at the time the image is captured, as measured in Beam Candle Power Seconds (BCPS).}
		41484	"SpatialFrequencyResponse" {This tag records the camera or input device spatial frequency table and SFR values in the direction of image width, image height, and diagonal direction, as specified in ISO 12233.}
		41486	"FocalPlaneXResolution" {Indicates the number of pixels in the image width (X) direction per FocalPlaneResolutionUnit on the camera focal plane.}
		41487	"FocalPlaneYResolution" {Indicates the number of pixels in the image height (Y) direction per FocalPlaneResolutionUnit on the camera focal plane.}
		41488	"FocalPlaneResolutionUnit" {Indicates the unit for measuring FocalPlaneXResolution and FocalPlaneYResolution. This value is the same as the ResolutionUnit.}
		41492	"SubjectLocation" {Indicates the location of the main subject in the scene. The value of this tag represents the pixel at the center of the main subject relative to the left edge, prior to rotation processing as per the Rotation tag. The first value indicates the X column number and second indicates the Y row number.}
		41493	"ExposureIndex" {Indicates the exposure index selected on the camera or input device at the time the image is captured.}
		41495	"SensingMethod" {Indicates the image sensor type on the camera or input device. The values are as follows.
		1 = Not defined
		2 = One-chip color area sensor
		3 = Two-chip color area sensor
		4 = Three-chip color area sensor
		5 = Color sequential area sensor
		7 = Trilinear sensor
		8 = Color sequential linear sensor
		Other = reserved}
		41728	"FileSource" {Indicates the image source. If a DSC recorded the image, this tag value of this tag always be set to 3, indicating that the image was recorded on a DSC.}
		41729	"SceneType" {Indicates the type of scene. If a DSC recorded the image, this tag value shall always be set to 1, indicating that the image was directly photographed.}
		41730	"CFAPattern" {Indicates the color filter array (CFA) geometric pattern of the image sensor when a one-chip color area sensor is used. It does not apply to all sensing methods.}
		41985	"CustomRendered" {This tag indicates the use of special processing on image data, such as rendering geared to output. When special processing is performed, the reader is expected to disable or minimize any further processing.}
		41986	"ExposureMode" {This tag indicates the exposure mode set when the image was shot. In auto-bracketing mode, the camera shoots a series of frames of the same scene at different exposure settings.
		0 = Auto exposure
		1 = Manual exposure
		2 = Auto bracket
		Other = reserved}
		41987	"WhiteBalance" {This tag indicates the white balance mode set when the image was shot.
		0 = Auto white balance
		1 = Manual white balance
		Other = reserved}
		41988	"DigitalZoomRatio" {This tag indicates the digital zoom ratio when the image was shot. If the numerator of the recorded value is 0, this indicates that digital zoom was not used.}
		41989	"FocalLengthIn35mmFilm" {This tag indicates the equivalent focal length assuming a 35mm film camera, in mm. A value of 0 means the focal length is unknown. Note that this tag differs from the FocalLength tag.}
		41990	"SceneCaptureType" {This tag indicates the type of scene that was shot. It can also be used to record the mode in which the image was shot. Note that this differs from the scene type (SceneType) tag.
		0 = Standard
		1 = Landscape
		2 = Portrait
		3 = Night scene
		Other = reserved}
		41991	"GainControl" {This tag indicates the degree of overall image gain adjustment.
		0 = None
		1 = Low gain up
		2 = High gain up
		3 = Low gain down
		4 = High gain down
		Other = reserved}
		41992	"Contrast" {This tag indicates the direction of contrast processing applied by the camera when the image was shot.
		0 = Normal
		1 = Soft
		2 = Hard
		Other = reserved}
		41993	"Saturation" {This tag indicates the direction of saturation processing applied by the camera when the image was shot.
		0 = Normal
		1 = Low saturation
		2 = High saturation
		Other = reserved}
		41994	"Sharpness" {This tag indicates the direction of sharpness processing applied by the camera when the image was shot.
		0 = Normal
		1 = Soft
		2 = Hard
		Other = reserved}
		41995	"DeviceSettingDescription" {This tag indicates information on the picture-taking conditions of a particular camera model. The tag is used only to indicate the picture-taking conditions in the reader.}
		41996	"SubjectDistanceRange" {This tag indicates the distance to the subject.
		0 = unknown
		1 = Macro
		2 = Close view
		3 = Distant view
		Other = reserved}
		
		;####### Other tags
		42016	"ImageUniqueID" {This tag indicates an identifier assigned uniquely to each image. It is recorded as an ASCII string equivalent to hexadecimal notation and 128-bit fixed length.}
		
		;####### Tags Relating to GPS
		;..... too much work....
		
		;####### Tags Relating to Interoperability
		1	"InteroperabilityIndex" {Indicates the identification of the Interoperability rule. The following rules are defined. Four bytes used including the termination code (NULL).
		"R98" = Indicates a file conforming to R98 file specification of Recommended Exif Interoperability Rules (ExifR98) or to DCF basic file stipulated by Design Rule for Camera File System.
		"THM" = Indicates a file conforming to DCF thumbnail file stipulated by Design rule for Camera File System.}
	]
	get-ifd-data: func[
		{Parses EXIF data block to resolve IFD data}
		bin [binary! string!] "data block to parse"
		block-to-store
		/local ofs tagID type count bin_value value
	][
		parse/all bin [any [
			SHORT (tagID: v)
			SHORT (type: v)
			;types:
			;  1 - An 8-bit unsigned integer
			;  2 - ASCII terminated with #{00}
			;  3 - A 16-bit (2-byte) unsigned integer
			;  4 - A 32-bit (4-byte) unsigned integer
			;  5 - RATIONAL
			;  6 - Signed byte
			;  7 - An 8-bit byte that can take any value depending on the field definition
			;  9 - SLONG - A 32-bit (4-byte) signed integer (2's complement notation)
			; 10 - Two SLONGs. The first SLONG is the numerator and the second SLONG is the denominator.
			LONG (count: v)
			copy value 4 skip ;pointer to value or value, depends on type
			(
				either any [
					type = 1
					type = 3
					type = 4
					all [type = 7 count < 5]
					all [type = 2 count < 5]
				][
					bin_value: to-binary value
				][
					ofs: to integer! head reverse to binary! value
					either type = 5 [
						bin_value: copy/part skip exif-data ofs 8
					][
						bin_value: copy/part skip exif-data ofs count
					]
		  		]
				either any [
					type = 1
					type = 3
					type = 4
				][
					value: to integer! head reverse copy bin_value
				][
					switch/default type [
						2 [parse/all bin_value [copy value to #"^@"]]
						5 [
							value: rejoin [
								to-integer head reverse copy/part bin_value 4
								"/"
								to-integer head reverse copy/part skip bin_value 4 4
							]
						]
						7 [value: bin_value]
						10 [
							value: rejoin [
								to-integer head reverse copy/part bin_value 4
								"/"
								to-integer head reverse copy/part skip bin_value 4 4
							]
						]
					][
						value: none
					]
				]

		  		;print [	tagID type count value ]
		  		repend block-to-store [tagID reduce [bin_value value type count]]
			)
		]]
		ifd0-data
	]
	parse-exif: func[
		{This function tries to parse 3 main EXIF data blocks (IFD0, IFD1 and SubIFD)
		 If found, thumbnail image is stored in variable 'thumbnail as an image.
		 Found IFD data are stored in variables 'ifd0-data and 'ifd1-data .}
		in_exif-data [string! binary!] "EXIF data to parse"
		/local ExifIFD-start next-ofs
	][
		clear ifd0-data
		clear ifd1-data
		clear subifd-data
		thumbnail-bin: thumbnail: none
		exif-data: in_exif-data
		parse/all exif-data [
			[          ;byte-order
				  "II" (IntelAlign?: true)  ;little endian
				| "MM" (IntelAlign?: false) ;big endian
			]
			[#{2A00} | #{002A}]  ;fixed (depends on byte order)
			LONG	;0th IFD Offset
			SHORT	(v2: v * 12) ;Interoperability Number (each directory entry has 12bytes)
			copy tmp v2 skip (get-ifd-data tmp ifd0-data)
			LONG (next-ofs: v)   ;offset to next IFD
			to end
		]
		;== Exif SubIFD =================================
		ExifIFD-start: second select ifd0-data 34665
		if not none? ExifIFD-start [
			parse/all (skip exif-data ExifIFD-start) [
				SHORT (v2: v * 12)
				copy tmp v2 skip (if not none? tmp [get-ifd-data tmp subifd-data])
			]
		]
		;== IFD1 (thumbnail image)  =====================
		parse/all (skip exif-data next-ofs) [
				SHORT (v2: v * 12)
				copy tmp v2 skip (tmp get-ifd-data tmp ifd1-data)
		]
		switch (get-tag-value/from 259 ifd1-data) [;thumbnail compression type
			6 [
				;jpg
				error? try [
					thumbnail: load thumbnail-bin: copy/part skip exif-data
						(get-tag-value/from 513 ifd1-data)
						(get-tag-value/from 514 ifd1-data)
				]
			]
			1 [
				;uncompressed
				if 2 = (get-tag-value/from 262 ifd1-data) [
					error? try [
						thumbnail: make image! to-pair reduce [
							get-tag-value/from 256 ifd1-data
							get-tag-value/from 257 ifd1-data
						]
						thumbnail/rgb: copy/part skip exif-data
							(get-tag-value/from 273 ifd1-data)
							(get-tag-value/from 279 ifd1-data)
					]
				]
			]
		] 
		;print-ifd0-data
		ifd0-data
	]
	
	parse-file: func[jpgfile [file! url!] /no-break /local file-port app0 buf break?][
		file-port: open/direct/binary/read jpgfile
		if #{FFD8} = copy/part file-port 2 [
			;it's JPG file
			break?: false
			while [all [not break? not none? buf: copy/part file-port 4]][
				parse/all buf [
					#{FF}
					BYTE ( app0: to-binary to-char v )
					UI16 (
						buf: copy/part file-port (v - 2)
						if app0 = #{E1} [
							if parse/all buf [#{457869660000} to end][
								;It's EXIF block
								;print "parsing EXIF"
								parse-exif skip buf 6
								if not no-break [
									break?: true ;exif parsed, we can quit
								]
							]
						]
					)
				]
			]
			
		]
		clear tmp
		close file-port
	]
	get-tag-value: func[tag [integer!] "Tag id of value we want to find" /from block /local tmp][
		if not none? tmp: select (either from [block][ifd0-data]) tag [
			tmp: second tmp
		]   tmp
	]
	print-ifd-data: func["Prints all IFD data values" /from block /local name][
		foreach [tagid values] (either from [block][ifd0-data]) [
			name: select ifd-tag-types tagid
			print [tagid tab values/3 tab name tab mold values/2]
			
		]
	]

]
;ctx-exif/parse-file %/J\grafika\fotky\bechyne\DSCN8323.jpg
;ctx-exif/parse-file %/d/test.jpg ;%/J\grafika\fotky\bechyne\DSCN8323.jpg ;
;if not none?  ctx-exif/thumbnail [
;	img: load ctx-exif/thumbnail
;	view layout [image img]
;]
