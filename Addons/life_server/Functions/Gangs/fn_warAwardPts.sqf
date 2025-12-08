//	File: fn_warAwardPts.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Determines number of pts to award and inserts into DB
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_killerUID","",[""]],
	["_killerGID",-1,[0]],
	["_victimUID","",[""]],
	["_victimGID",-1,[0]],
	["_killDist",-1,[0]],
	["_killerGS",-1,[0]],
	["_victimGS",-1,[0]],
	["_killer",objNull,[objNull]],
	["_victim",objNull,[objNull]],
	["_mode",-1,[0]]
];

if (_killDist isEqualTo -1 || _killerGS isEqualTo -1 || _victimGS isEqualTo -1) exitWith {};
if (!(_mode in [2,3]) && {_killerGID isEqualTo -1 || _victimGID isEqualTo -1}) exitWith {};
if (_killerUID isEqualTo "" || _victimUID isEqualTo "") exitWith {};
if (_killerGID isEqualTo _victimGID) exitWith {};

private _victimFinal = _victimGS - _killerGS;
private _killerFinal = _victimGS - _killerGS;

private _distPoints = switch (true) do {
	case (_killDist >= 1200): {12};
	case (_killDist >= 1100): {11};
	case (_killDist >= 1000): {10};
	case (_killDist >= 900): {9};
	case (_killDist >= 800): {8};
	case (_killDist >= 700): {7};
	case (_killDist >= 600): {6};
	case (_killDist >= 500): {5};
	case (_killDist >= 400): {4};
	case (_killDist >= 300): {3};
	case (_killDist >= 200): {2};
	case (_killDist >= 75): {1};
	default {0};
};

if ((_killerFinal <= 0) && (_killerFinal >= -3)) then {_killerFinal = 2;};
if (_killerFinal <= -4) then {_killerFinal = 1;};
if ((_victimGS <= 3) && (_killerGS >= 3)) then {_victimFinal = 1;};
if (_victimFinal < 0) then {_victimFinal = (-1 * _victimFinal);};
if (_victimFinal isEqualTo 0) then {_victimFinal = 1;};
if ((_victimFinal >= 3) && (_victimFinal <= 5)) then {_victimFinal = 2;};
if (_victimFinal >= 6) then {_victimFinal = 3;};
if ((_killerFinal < 3) && (_victimFinal > 2)) then {_victimFinal = 1; _killerFinal = 1;};

_killerFinal = _killerFinal + _distPoints;

private _bonusPoints = 0;

if ((_killer getVariable ["killStreak", 0]) >= 3) then {
	private _ks = _killer getVariable ["killStreak", 0];
	if (_ks >= 15) exitWith {_killerFinal = _killerFinal + 5; _bonusPoints = 5};
	if (_ks >= 12) exitWith {_killerFinal = _killerFinal + 4; _bonusPoints = 4};
	if (_ks >= 9) exitWith {_killerFinal = _killerFinal + 3; _bonusPoints = 3};
	if (_ks >= 6) exitWith {_killerFinal = _killerFinal + 2; _bonusPoints = 2};
	if (_ks >= 3) exitWith {_killerFinal = _killerFinal + 1; _bonusPoints = 1};
};

private _recentKill = false;
if !(serv_timeFucked) then {
	private _exit = false;

	{
		if (((_x select 0) isEqualTo _killerUID) && ((_x select 1) isEqualTo _victimUID)) then {
			if ((_x select 2) > serverTime) exitWith {_exit = true; _killerFinal = 1; _victimFinal = 1; _recentKill = true;};
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

if (_recentKill && (_killer getVariable ["killStreak", 0] > 0)) then {
	_killer setVariable ["killStreak", (_killer getVariable ["killStreak", 1]) - 1, true];
};
if (_mode in [2,3]) then {
	if(_mode isEqualTo 3) then {
		_victimFinal = 1;
	};
	// 使用 playerMapper 更新战争点数
	["addwarpts", [_killerUID, str _killerFinal]] spawn DB_fnc_playerMapper;
	["deductwarptssafe", [_victimUID, str _victimFinal]] spawn DB_fnc_playerMapper;
} else {
	// 使用 gangMapper 设置战争统计
	["setwarstats", [_killerUID, _victimUID, str _killerGID, str _victimGID, str _killerFinal, str _victimFinal, str _mode]] spawn DB_fnc_gangMapper;
};
if !(isNull _victim) then {
	[[0,format["Your war points have decreased by %1 points.",_victimFinal]],"OEC_fnc_broadcast",_victim,false] spawn OEC_fnc_MP;
};

if !(isNull _killer) then {
	if (_distPoints isEqualTo 0) then {
		[[0,5],format["Your war points have increased by %1 points.",_killerFinal]] remoteExec ["OEC_fnc_broadcast",_killer,false];
	} else {
		[[0,5],format["Your war points have increased by %1 points. You got bonus point(s) for your %2m kill!",_killerFinal,[ceil(_killDist)] call OEC_fnc_numberText]] remoteExec ["OEC_fnc_broadcast",_killer,false];
	};
	if (_bonusPoints > 0) then {
		[0,format["You have received %1 bonus points for your killstreak of %2.",_bonusPoints, _killer getVariable ["killStreak", 0]]] remoteExec ["OEC_fnc_broadcast",_killer,false];
	};
};

if (_mode in [2,3]) then {
	format ["-ZONEWAR- %1(%2) gained %3 points. %4(%5) lost %6 points Distance Points: %7",name _killer,_killerUID,_killerFinal,name _victim,_victimUID,_victimFinal,_distPoints] call OES_fnc_diagLog;
} else {
	format ["-GANGWAR- %1(%2) gained %3 points. %4(%5) lost %6 points Distance Points: %7",name _killer,_killerUID,_killerFinal,name _victim,_victimUID,_victimFinal,_distPoints] call OES_fnc_diagLog;
};
