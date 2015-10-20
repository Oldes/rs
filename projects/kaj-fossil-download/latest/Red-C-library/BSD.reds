Red/System [
	Title:		"C Library BSD extensions"
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
		Red/System >= 0.3.2
		%ANSI.reds
	}
	Tabs:		4
]


#include %ANSI.reds


#import [LIBC-file cdecl [

	; Floating point

	is-NaN: "isnan" [				"Test for Not-a-Number."
		number			[float!]
		return:			[integer!]
	]
	is-finite: "finite" [			"Test if number is finite (or NaN)."
		number			[float!]
		return:			[integer!]
	]
	infinity-sign-of: "isinf" [		"Test for infinity and return its sign, or 0."
		number			[float!]
		return:			[integer!]	"0: finite, 1: infinite, -1: negative infinity"
	]

]]


; Higher level interface


; Floating point

NaN?: function [					"Test for Not-a-Number."
	number			[float!]
	return:			[logic!]
][
	as-logic is-NaN number
]
finite?: function [					"Test if number is finite (or NaN)."
	number			[float!]
	return:			[logic!]
][
	as-logic is-finite number
]
infinite?: function [				"Test for infinity."
	number			[float!]
	return:			[logic!]
][
	as-logic infinity-sign-of number
]
