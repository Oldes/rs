rebol [
	title: "print-struct"
	author: "Oldes"
	purpose: {Prints readable pairs of variables and values of the struct! datatype}
]

print-struct: func[
	{Prints readable pairs of variables and values of the struct! datatype}
	st [struct!] "Struct! to explore"
	/local val i
][
	i: 0
	parse first st [
		opt [set val string! (print val loop length? val [prin "="] print "")]
		any [
		set val word! (
			insert/dup tail val: to-string val #"." 24 - length? val
			print [val pick second st i: i + 1]
		)
		| any-type!
	]]
]