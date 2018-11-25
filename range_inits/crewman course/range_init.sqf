[
	"targets", 		//range type
	"Ground Static Range",	// title text
	"gs",			// range tag
	[ // range args
		10,				// targets per lane
		1,				// lane count
		[
			// Range sequence
			["Ready your weapon",5],
			["Range is hot!",1],
			[[1],10],
			[[2],10],
			[[4],10],
			[[5],10],
			[[6],10],
			[[7],10],
			[[8],10],
			[[9],10],
			[[10],10],
			["Range complete.",0]
		]
	],
	[9,7,5],	// qualification tiers
	true,  // instructor actions
	false, // object actions
    true // civ targets
] call cav_ranges_fnc_createRange;
