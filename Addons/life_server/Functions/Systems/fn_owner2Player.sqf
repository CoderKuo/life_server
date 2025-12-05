//  File: fn_owner2Player.sqf
//	Author: Fusah
//	Description: Will grab plr object from client-ID FOR USE ON SERVER ONLY

params [
	["_clientID",0]
];

if !(isServer) exitWith {};
if (_clientID isEqualTo 0) exitWith {};

private _ret = objNull;

{
	if (owner _x isEqualTo _clientID) exitWith {_ret = _x};
} forEach playableUnits;

_ret;