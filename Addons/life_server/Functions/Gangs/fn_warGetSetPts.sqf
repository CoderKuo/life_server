//File: fn_warGetSetPts.sqf
//Author: Jesse "tkcjesse" Schultz
params [
	["_mode",-1,[0]],
	["_value",0,[0]],
	["_player",objNull,[objNull]]
];

if (isNull _player) exitWith {};
if (_mode isEqualTo -1) exitWith {};
private ["_uid","_query","_queryResult"];

_uid = getPlayerUID _player;

switch (_mode) do {
	case 0: {
		_query = format["SELECT warpts FROM players WHERE playerid='%1'",_uid];
		_queryResult = [_query,2] call OES_fnc_asyncCall;

		["oev_warpts_count",(_queryResult select 0)] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	};

	case 1: {
		_query = format["UPDATE players SET warpts = warpts - %2 WHERE playerid='%1'",_uid,_value];
		_queryResult = [_query,2] call OES_fnc_asyncCall;
	};

	default {};
};
