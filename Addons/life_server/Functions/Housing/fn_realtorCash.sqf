//	File: fn_realtorCash.sqf
//	Author: TheCmdrRex
//	Description: Queries server for realtor_cash and returns cash value

private ["_query","_queryResult","_player","_foundCash","_mode"];

params [
	["_player",objNull,[objNull]],
	["_mode",-1,[0]]
];

// Simple check cause why not.
if (isNull _player) exitWith {};
if (!isPlayer _player) exitWith {};

//Query the server
_query = format ["SELECT realtor_cash FROM players WHERE playerid='%1'", getPlayerUID _player];
_queryResult = [_query,2] call OES_fnc_asyncCall;


if ((count _queryResult) isEqualTo 0) then {
	_foundCash = -2; // If server was dumb and something messed up
} else {
	_foundCash = (_queryResult select 0);
};
// Return Found cash
if (_mode != 2) then {
	if (_foundCash > 0) then {
		_query = format ["UPDATE players SET realtor_cash = '0' WHERE playerid='%1'", getPlayerUID _player];
		_queryResult = [_query,1] call OES_fnc_asyncCall;
	};
	[nil,nil,nil,[_foundCash,1]] remoteExec ["OEC_fnc_checkRealtor",remoteExecutedOwner];
} else {
	[nil,nil,nil,[_foundCash,2]] remoteExec ["OEC_fnc_checkRealtor",remoteExecutedOwner];
};