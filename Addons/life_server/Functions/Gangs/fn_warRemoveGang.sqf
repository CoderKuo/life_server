//	File: fn_warRemoveGang.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Sets an active war to be inactive to prepare for deletion.

params [
	["_gangID",0,[0]],
	["_endID",0,[0]]
];

if (_gangID isEqualTo 0 || _endID isEqualTo 0) exitWith {};

private _query = format ["UPDATE gangwars SET active = '0' WHERE ((init_gangid='%1' AND acpt_gangid='%2') OR (acpt_gangid='%1' AND init_gangid='%2'))",_gangID,_endID];
[_query,1] call OES_fnc_asyncCall;