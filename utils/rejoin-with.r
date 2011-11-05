REBOL [
	Title: "Rejoin-with"
	Date:   16-7-2003
	File:   %rejoin-with.r
	Author: "Oldes"
	Email:  oldes@bigfoot.com
	Version: 0.0.1
	Category: [util file 1]
]

rejoin-with: func[block str /local new][
	if empty? block: reduce block [return block]
	new: either series? first block [copy first block] [form first block]
	block: next block
	while [not tail? block] [
		insert tail new str
		insert tail new first block
		block: next block
	]
	new
]
