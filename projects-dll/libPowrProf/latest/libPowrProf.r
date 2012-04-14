REBOL [
    Title: "LibPowrProf"
    Date: 13-Apr-2012/21:51:25+2:00
    Author: "Oldes"
]

libPowrProf: context [
	libPowrProf.dll: load/library %PowrProf.dll

	SetSuspendState: make routine! [
		Hibernate        [integer!]
		ForceCritical    [integer!]
		DisableWakeEvent [integer!]
		return:          [integer!]
	] libPowrProf.dll "SetSuspendState"

	set 'os-sleep func[
		"Suspends the system by shutting power down"
		/hybernate "Use deep (slow) hibernation"
	][
		SetSuspendState either hybernate [1][0] 1 0
	]
]
