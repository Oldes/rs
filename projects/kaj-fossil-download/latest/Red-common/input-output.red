Red [
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
		Red >= 0.3.2
		%common/input-output.reds
		%common/common.red
	}
	Tabs:		4
]


#system-global [#include %input-output.reds]
#include %common.red


read: routine ["Read file."
	name			[string!]  ; [file! url!]
;	return:			[string! none!]
	/local file data
][
	file: to-local-file name
	data: system/words/read file
	free-any file

	either as-logic data [
		SET_RETURN ((string/load data  1 + length? data))
;		free data
	][
		RETURN_NONE
	]
]

write: routine ["Write file."
	name			[string!]  ; [file! url!]
	data			[string!]
	return:			[logic!]
	/local file out ok?
][
	file: to-local-file name
	out: to-UTF8 data

	ok?: write-string file out

	free-any out
	free-any file
	ok?
]
