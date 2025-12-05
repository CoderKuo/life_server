//	File: fn_warGetEnemy.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: fetches the opposing gangs with active wars for a player

params [
	["_owner",objNull,[objNull]],
	["_gangID",0,[0]],
	["_gangName","",[""]]
];
if (isNull _owner || _gangID isEqualTo 0 || _gangName isEqualTo "") exitWith {};

private _check = (_gangName find "'" != -1);
if (_check) exitWith {};

private _query = format ["SELECT init_gangid, init_gangname, acpt_gangid, acpt_gangname FROM gangwars WHERE active='1' AND (init_gangid='%1' OR acpt_gangid='%1')",_gangID];
private _queryResult = [_query,2,true] call OES_fnc_asyncCall;
if ((count _queryResult) isEqualTo 0) exitWith {};

if (isNull _owner) exitWith {};
[_queryResult] remoteExec ["OEC_fnc_warLoadActive",_owner,false];