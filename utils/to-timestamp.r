rebol [
	title: "Rebol date to-timestamp"
	purpose: {For better date storage (in large date databases)}
	file: %to-timestamp.r
	author: "Oldes"
	mail: oldes@bigfoot.com
	Version: 0.0.4
	date: 18-Jul-2001/11:22:22+2:00
]
to-timestamp: func[
	{Returns date converted to TIMESTAMP integer (YYYYMMDDHHMMSS)}
	d [date! none!]	"Date to convert"
	/dateonly	{Returns only date: YYYYMMDD}
	/local pad
][
	if none? d [return d]
	pad: func[s][either s < 10 [join "0" s][s]]
	to-decimal rejoin [
		d/year
		pad d/month
		pad d/day
		either dateonly [""][
			rejoin [
				pad d/time/hour
				pad d/time/minute
				pad d/time/second
			]
		]
	]
]
