rebol [
	require: [
		rs-project 'code-colorizer
	]
]
code-colorizer/remove-parens?: off
colorize/save/title
	to-rebol-file "I:\rebol\rs\projects-rswf\rswf\new\swf-tag-rules_enczes.rb"
	%rswf-main-rules-full-code.html
	"Rebol/Flash Dialect (RSWF) main rules"
	
code-colorizer/remove-parens?: on
colorize/save/title
	to-rebol-file "I:\rebol\rs\projects-rswf\rswf\new\swf-tag-rules_enczes.rb"
	%rswf-main-rules.html
	"Rebol/Flash Dialect (RSWF) main rules"
	
