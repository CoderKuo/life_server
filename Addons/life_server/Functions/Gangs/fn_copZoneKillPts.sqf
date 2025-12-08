//	File: fn_copZoneKillPts.sqf
//	Author: Kurt
// 	Modifications: TheCmdrRex
//	Description: Gives points to players for killing cops in warzone
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_killer",objNull,[objNull]],
	["_victim",objNull,[objNull]],
	["_mode",-1,[0]]
];

if (isNull _killer || isNull _victim) exitWith {};
//if !(side _victim isEqualTo west) exitWith {};

private _killerUID = getPlayerUID _killer;
private _victimUID = getPlayerUID _victim;

switch (_mode) do {

	// Warzone Cop Kill
	case 1: {
		private _points = _victim getVariable ["rank", 0];
		if (_points > 5) then {
			_points = 5;
		};
		// 使用 playerMapper 添加战争点数
		["addwarpts", [_killerUID, str _points]] spawn DB_fnc_playerMapper;

		if !(isNull _killer) then {
			[[0,5],format["Your war points have increased by %1 for killing a cop on warzone island.",_points]] remoteExec ["OEC_fnc_broadcast",_killer,false];
		};
		format ["-COPZONEWAR- %1(%2) gained %3 points for killing officer %4(%5) on warzone island.",name _killer,_killerUID,_points,name _victim,_victimUID] call OES_fnc_diagLog;
	};

	// Federal Reserve Cop Kill
	case 2: {

		if (fed_bank getVariable ["chargeplaced",false]) then {
			private _copLevel = _victim getVariable ["rank",0];

			if (_copLevel > 2) then {
				// 使用 playerMapper 添加战争点数
				["addwarpts", [_killerUID, "1"]] spawn DB_fnc_playerMapper;

				if !(isNull _killer) then {
					[[0,5],"Your war points have increased by 1 for killing a cop near the federal reserve."] remoteExec ["OEC_fnc_broadcast",_killer,false];
				};
				format ["-COPZONEWAR- %1(%2) gained 2 points for killing officer %3(%4) at the federal reserve.",name _killer,_killerUID,name _victim,_victimUID] call OES_fnc_diagLog;
			};
		};
	};

	// Blackwater Cop Kill
	case 3: {

		private _blackwaterDome = nearestObject [[20898.6,19221.7,0.00143909],"Land_Dome_Big_F"];
		if (_blackwaterDome getVariable ["chargeplaced",false]) then {
			private _copLevel = _victim getVariable ["rank",0];

			if (_copLevel > 2) then {
				// 使用 playerMapper 添加战争点数
				["addwarpts", [_killerUID, "2"]] spawn DB_fnc_playerMapper;

				if !(isNull _killer) then {
					[[0,5],"Your war points have increased by 2 for killing a cop near the Blackwater."] remoteExec ["OEC_fnc_broadcast",_killer,false];
				};
				format ["-COPZONEWAR- %1(%2) gained 2 points for killing officer %3(%4) at the Blackwater.",name _killer,_killerUID,name _victim,_victimUID] call OES_fnc_diagLog;
			};
		};
	};
};
