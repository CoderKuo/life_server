//	File: fn_getSetHit.sqf
//	Author: TheCmdrRex
//	Description: Server-side function which either sets hit on player or fetches a hit placed on owner player at login

params [
	["_mode",-1,[0]],
	["_target",objNull,[objNull]],
	["_issuer",objNull,[objNull]],
	["_bounty",-1,[0]],
	["_bountyTime",-1,[0]]
];
private ["_queryResult","_query"];

// Yay some checks
if (_mode < 1 || _mode > 3) exitWith {};
if (isNull _target) exitWith {};

// Mode for setting hit onto a player
if (_mode == 1) then {
	if (_bounty < 200000 || _bounty > 50000000) exitWith {};
	if (isNull _issuer) exitWith {};
	if (_bountyTime < 720) exitWith {};
	_query = format["INSERT INTO hitman (targetPID, bounty, targetTime, issuerPID, active) VALUES('%1','%2','%3','%4','1')", getPlayerUID _target, _bounty, _bountyTime, getPlayerUID _issuer];
	_queryResult = [_query,2] call OES_fnc_asyncCall;

	_target setVariable ["hitmanBounty",_bounty,true];
};

// Mode for retreiving current bounty from server
if (_mode == 2) then {
	_query = format ["SELECT bounty, targetTime FROM hitman WHERE targetPID='%1' AND active='1'", getPlayerUID _target];
	_queryResult = [_query,2] call OES_fnc_asyncCall;
	if ((count _queryResult) isEqualTo 0) exitWith {
		_target setVariable ["hitmanBounty",0,true];
	};

	_target setVariable ["hitmanBounty",(_queryResult select 0),true];
	[_target,(_queryResult select 0),(_queryResult select 1)] remoteExec ["OEC_fnc_handleHit",_target,false];
};

// Mode for removing bounty from DB
if (_mode == 3) then {
	_query = format["UPDATE hitman SET active ='0' WHERE targetPID='%1' AND active='1'", getPlayerUID _target];
	_queryResult = [_query,2] call OES_fnc_asyncCall;

	_target setVariable ["hitmanBounty",0,true];
};