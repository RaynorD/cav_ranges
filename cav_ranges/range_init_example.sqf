/*
	For version: 2.0.0
	
	===========================================================================
	
	The framework expects to find objects with very specific names.
	Naming the objects a standard format allows the scripts to access the range
	objects in an organized manner, without some list somewhere that has to be
	updated if target or lane count is changed.
	
	Consider the naming syntax for a target on an example range: 
	r1_target_l3_t7
	
	The first element in the object name, "r1", is the range tag of the range. 
	This naming syntax is the purpose of the range tag. 
	
	The second element, "target", indicates the function of the object on the range. 
	This has to be one of several specific strings:
		"ctrl" - The control or "brain" object for the range. This object is what 
			the actions to control the range are added to, and is also used to 
			store script variables. There is only one ctrl object per range. 
			It can be any kind of object, but I'd recommend something that 
			indicates interaction. Location does not matter.
		"trg" - A trigger encompassing the whole area that players may occupy while 
			using or observing the range. When a player enters this trigger, the 
			UI showing that range's info will appear. There is only one trigger 
			per range. The trigger must be set to activation:any player, activation type:present,
			and repeatable:true. Don't overlap triggers for different ranges, otherwise
			multiple UIs could try to open at once and the timespace continuum may implode.
		"shootingPos" - Each lane has a shooting position. The closest player to
			this object within a few meters is shown as the shooter for the range
			on the UI. Currently it is purely cosmetic. The object can be anything,
			I have successfully used actual shooting positions and hidden helper 
			spheres.
		"target" - A target, gets shot at. If using the "targets" range mode, a popup target
			that uses the "terc" animation must be used. If using the "spawn" mode, anything
			that can die can be used.
		
	The third element, "l3", indicates the lane number of that object. Only targets 
		and shooting positions have this. The index starts at 1.
	
	The fourth element, "t4", is the target's index on its lane. Only targets will 
		have it. The index starts at 1.
	
	===========================================================================
	
	An example range listing all its named objects:
	range tag: "ar"
	
	Only one:
	ar_ctrl
	ar_trg
	
	One per lane:
	ar_shootingPos_l1
	ar_shootingPos_l2
	etc...
	
	Lane 1 targets:
	ar_target_l1_t1
	ar_target_l1_t2
	etc...
	
	Lane 2 targets:
	ar_target_l2_t1
	ar_target_l2_t2
	etc...
	
	More lanes, etc.
*/

// grenade launcher range setup
{
	_x addEventHandler ["Explosion", {_this spawn cav_ranges_fnc_eh_explosion}];
	_x addEventHandler ["HandleDamage", {0}];
	_x setVariable ["cav_ranges_expDmgThreshold",0.001]; // damage threshold for target to go down, 0.04 is about 5 meters for a vanilla grenade, 0.01 is about 10 meters
} foreach allMissionObjects "TargetP_Inf3_F";

// grenade range
{
	_x addEventHandler ["Explosion", {_this spawn cav_ranges_fnc_eh_explosion}];
	_x addEventHandler ["HandleDamage", {0}];
	_x setVariable ["cav_ranges_expDmgThreshold",0.04]; // damage threshold for target to go down, 0.04 is about 5 meters for a vanilla grenade, 0.01 is about 10 meters
} foreach allMissionObjects "TargetP_Inf2_F";

[
	"targets", 		//range type
					//	"targets" : pop up targets, terc animation is used
					//	"spawn"   : spawned units, targets being alive/dead is used
	"Pistol Range",	// title text
	"r1",			// range tag
	1,				// lane count
	10,				// targets per lane
	[				
		// Range sequence
			// First element defines the type of event:
			//		ARRAY: target(s)/group(s) to raise. Multiple elements for multiple targets/groups
			//		STRING: Message to show on the lane UI. Third element is not used in this case
			// Second element: seconds length/delay for that event
			// Third element (optional): delay between end of this event and start of the next, default 2 if not present
		["Load a magazine.",5], //show message for 5 seconds
		["Range is hot!",3],
		[[1],5], // raise first target for 5 seconds
		[[3],5],
		[[7],2],
		[[4],2],
		[[9],5],
		["Reload.",5],
		["Range is hot!",3],
		[[2,7],8], // raise targets 2 and 7 for 5 seconds
		[[1,10],8],
		[[7,4],5],
		[[6,2],5],
		[[7,10],5],
		["Safe your weapon.",3],
		["Range complete.",0]
	],
	nil,	// target grouping, nil to disable grouping, otherwise group as define nested arrays: [[0,1],[2,3]] etc
				//   a particular target can be in multiple groups
	[13,11,9]	// qualification tiers, [expert, sharpshooter, marksman], nil to disable qualifications altogether
				//   values below the last element will show no go
				//   Not all three are required, [35] would simply return expert above 35, and no go below that
] spawn cav_ranges_fnc_createRange;


[
	"targets", //range type
	"Rifle Range", // title text
	"r2", // range tag
	1, // lane count
	11, // targets per lane
	[ // Range sequence
		["Load your magazine",5],
		["Assume a prone position and standby",3],
		["Range is hot!",1],
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
		["Reload your weapon",5],
		["Assume a prone position and standby",3],
		["Range is hot!",1],
		[[5],5],
		[[2],5],
		[[7],5],
		[[11],5],
		[[8],5],
		[[3],5],
		[[10],5],
		[[6],5],
		[[3],5],
		[[2],5],
		["Assume a kneeling position and standby",3],
		["Range is hot!",1],
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
		["Safe your weapon.",3],
		["Range complete.",0]
	],
	nil, // target grouping
	[38,30,23] // qualification tiers
] spawn cav_ranges_fnc_createRange;

[
	"targets", //range type
	"AR Range", // title text
	"r3", // range tag
	1, // lane count
	10, // targets per lane
	[ // Range sequence
		["Load your magazine",5],
		["Range is hot!",5],
		[[1],5],
		[[2],5],
		[[3],5],
		[[4],5],
		[[5],5],
		["Reload",5],
		["Range is hot!",3],
		[[2,3],8],
		[[4,5],8],
		[[7,8],8],
		[[10,3],8],
		[[7,9],8],
		["Safe your weapon.",3],
		["Range complete.",0]
	],
	nil, // target grouping
	[10,8,6] // qualification tiers
] spawn cav_ranges_fnc_createRange;

[
	"targets", //range type
	"Grenade Range", // title text
	"r4", // range tag
	1, // lane count
	4, // targets per lane
	[ // Range sequence
		["Ready your grenades",5],
		["Range is hot!",5],
		[[1],30],
		[[2],30],
		[[3],30],
		[[4],30],
		["Safe your weapon.",3],
		["Range complete.",0]
	],
	nil, // target grouping
	[4,3,2] // qualification tiers
] spawn cav_ranges_fnc_createRange;

[
	"targets", //range type
	"Grenade Launcher Range", // title text
	"r5", // range tag
	1, // lane count
	9, // targets per lane
	[ // Range sequence
		["Ready your grenades",5],
		["Range is hot!",5],
		[[1,2],15],
		[[3],15],
		[[4,5],15],
		[[6,7,8,9],15],
		["Safe your weapon.",3],
		["Range complete.",0]
	],
	nil, // target grouping
	[8,6,4] // qualification tiers
] spawn cav_ranges_fnc_createRange;

[
	"spawn", //range type 
	"AT Range", // title text
	"r6", // range tag
	1, // lane count
	4, // targets per lane
	nil, // Range sequence
	nil, // target grouping
	[3,2,1] // qualification tiers
] spawn cav_ranges_fnc_createRange;

_marksmanDelay = 20;
[
	"targets", //range type
	"Marksman Range", // title text
	"r7", // range tag
	1, // lane count
	11, // targets per lane
	[ // Range sequence
		["Load your magazine",5],
		["Range is hot!",5],
		[[1],_marksmanDelay],
		[[2],_marksmanDelay],
		[[3],_marksmanDelay],
		[[4],_marksmanDelay],
		[[5],_marksmanDelay],
		[[6],_marksmanDelay],
		[[7],_marksmanDelay],
		[[8],_marksmanDelay],
		[[9],_marksmanDelay],
		[[10],_marksmanDelay],
		[[11],_marksmanDelay],
		["Safe your weapon.",3],
		["Range complete.",0]
	],
	nil, // target grouping
	[11,9,7] // qualification tiers
] spawn cav_ranges_fnc_createRange;
