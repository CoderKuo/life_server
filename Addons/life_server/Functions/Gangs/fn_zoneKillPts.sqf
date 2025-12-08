//	File: fn_zoneKillPts.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Gives and removes points for players in the warzone area and cartels
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_killer",objNull,[objNull]],
	["_victim",objNull,[objNull]]
];

if (isNull _killer || isNull _victim) exitWith {};

private _killerUID = getPlayerUID _killer;
private _victimUID = getPlayerUID _victim;
private _killerGang = ((_killer getVariable ["gang_data",[0,"",0]]) select 0);
private _victimGang = ((_victim getVariable ["gang_data",[-1,"",0]]) select 0);

if (_killerGang isEqualTo _victimGang) exitWith {};

private _recentKill = false;
if !(serv_timeFucked) then {
	private _exit = false;

	{
		if (((_x select 0) isEqualTo _killerUID) && ((_x select 1) isEqualTo _victimUID)) then {
			if ((_x select 2) > serverTime) exitWith {_exit = true; _recentKill = true;};
			if ((_x select 2) <= serverTime) then {
				serv_gangwar_kills deleteAt _forEachIndex;
				_exit = true;
			};
		};
		if (_exit) exitWith {};
	} forEach serv_gangwar_kills;

	if !(_recentKill) then {
		serv_gangwar_kills pushBack [_killerUID,_victimUID,(serverTime + 900)];
	};
};

if (_recentKill) exitWith {};

// 使用 gangMapper 设置区域击杀
["setzonekill", [_killerUID, _victimUID]] spawn DB_fnc_gangMapper;

if !(isNull _victim) then {
	[0,"Your war points have decreased by 1 point."] remoteExec ["OEC_fnc_broadcast",_victim,false];
};

if !(isNull _killer) then {
	[[0,5],"Your war points have increased by 1 point."] remoteExec ["OEC_fnc_broadcast",_killer,false];
};

format ["-ZONEWAR- %1(%2) gained 1 point. %3(%4) lost 1 point.",name _killer,_killerUID,name _victim,_victimUID] call OES_fnc_diagLog;
