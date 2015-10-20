Red/System [
	Title:		"Input/Output"
	Author:		"Kaj de Vos"
	Rights:		"Copyright (c) 2013 Kaj de Vos. All rights reserved."
	License: {
		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:

		    * Redistributions of source code must retain the above copyright notice,
		      this list of conditions and the following disclaimer.
		    * Redistributions in binary form must reproduce the above copyright notice,
		      this list of conditions and the following disclaimer in the documentation
		      and/or other materials provided with the distribution.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
		ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
		WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
		FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
		CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
		OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	}
	Needs: {
		Red/System
		%C-library/ANSI.reds
		%cURL/cURL.reds
	}
	Tabs:		4
]


#include %../C-library/ANSI.reds
#include %../cURL/cURL.reds


read: function ["Read text file."
	name			[c-string!]
	return:			[c-string!]
][
	either as-logic name [
		case [
			zero? compare-string-part name "file:" 5 [
				read-file name + 5
			]
			as-logic find-string name "://" [
				read-url name
			]
			yes [
				read-file name
			]
		]
	][
		null
	]
]

write-string: function ["Write text file."
	name			[c-string!]
	text			[c-string!]
	return:			[logic!]
][
	either as-logic name [
		case [
			zero? compare-string-part name "file:" 5 [
				write-file name + 5  text
			]
			as-logic find-string name "://" [
				write-url name text
			]
			yes [
				write-file name text
			]
		]
	][
		no
	]
]
