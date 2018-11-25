// rifle range "rr" - TargetP_Inf_Acc2_F
// grenade range "gr" - TargetP_Inf_F
// killhouse "kh" - TargetP_Inf_Acc2_NoPop_F (kh_target_1)


// grenade launcher range setup
//{
//	_x addEventHandler ["Explosion", {_this spawn cav_ranges_fnc_eh_explosion}];
//	_x addEventHandler ["HandleDamage", {0}];
//	_x setVariable ["cav_ranges_expDmgThreshold",0.001];
//} foreach allMissionObjects "TargetP_Inf3_F";
//
// grenade range


/*
[
	"targets", 		//range type
					//	"targets" : pop up targets, terc animation is used
					//	"spawn"   : spawned units, targets being alive/dead is used
	"Rifle Range",	// title text
	"rr",			// range tag
	[
		8,				// targets per lane
		6,				// lane count
		[
			// Range sequence
				// First element defines the type of event:
				//		ARRAY: target(s)/group(s) to raise. Multiple elements for multiple targets/groups
				//		STRING: Message to show on the lane UI. Third element is not used in this case
				// Second element: seconds length/delay for that event
				// Third element (optional): Sound to play out of range speakers
				// Fourth element (optional): delay between end of this event and start of the next, default 2 if not present
			["Load one 20 round magazine",5,"Reload"],
			["Assume a prone position and scan your lane",3,"Prone2"],
			["Range is hot!",1,"RangeIsHot"],
			["Range is hot!",0,"FD_Course_Active_F",0],
			[[1],5],
			[[2],5],
			[[6],5],
			[[3],5],
			[[8],5],
			[[4],5],
			[[7],5],
			[[2],5],
			[[1],5],
			[[5],5],
			[[2,4],8],
			[[1,5],8],
			[[7,3],8],
			[[3,6],8],
			[[2,5],8],
			["Reload one 20 round magazine",5,"Reload"],
			["Assume a prone position and scan your lane",3,"Prone1"],
			["Range is hot!",1,"RangeIsHot"],
			["Range is hot!",0,"FD_Course_Active_F",0],
			[[5],5],
			[[2],5],
			[[7],5],
			[[1],5],
			[[8],5],
			[[3],5],
			[[4],5],
			[[6],5],
			[[3],5],
			[[2],5],
			["Assume a kneeling position and scan your lane",3,"Kneel"],
			["Range is hot!",1,"RangeIsHot"],
			[[1],5],
			[[3],5],
			[[4],5],
			[[2],5],
			[[3],5],
			[[2],5],
			[[4],5],
			[[1],5],
			[[3],5],
			[[2],5],
			["Cease Fire!",3,"CeaseFire1"],
			["Standby for final score...",1,"StandbyScore"],
			["Range complete.",0]
		],
		true,    // has hit indicators
		true,	// use custom black texture
		nil	// target grouping, nil to disable grouping, otherwise group as define nested arrays: [[0,1],[2,3]] etc
					//   a particular target can be in multiple groups
	],
	[38,30,23],	// qualification tiers, [expert, sharpshooter, marksman], nil to disable qualifications altogether
				//   values below the last element will show no go
				//   Not all three are required, [35] would simply return expert above 35, and no go below that
	true	// add instructor actions
] call cav_ranges_fnc_createRange;
*/

/*
[
	"targets", 		//range type
	"Grenade Range",	// title text
	"gr",			// range tag
	[
		8,				// targets per lane
		4,				// lane count
		[
			// Range sequence
			["Ready your grenades",5],
			["Range is hot!",1],
			[[1],15],
			[[2,3],15],
			[[4],15],
			[[5,6],15],
			[[7,8],15],
			["Range complete.",0]
		]
	],
	[8,6,5],	// qualification tiers
	true,
	false
] call cav_ranges_fnc_createRange;*/
