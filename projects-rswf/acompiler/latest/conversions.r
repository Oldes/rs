rebol []


issue-to-binary: func[clr] [debase/base clr 16]
issue-to-decimal: func[i [issue!] /local e d][
	i: reverse issue-to-binary i
	e: 0 d: 0
	forall i [
		d: d + (i/1 * (2 ** e))
		e: e + 8
	]
	d
]
tuple-to-decimal: func[t [tuple!] /local e d][
	t: reverse as-binary t
	e: 0 d: 0
	forall t [
		d: d + (t/1 * (2 ** e))
		e: e + 8
	]
	d
]
