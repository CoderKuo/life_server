//	File: fn_warGetEnemy.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: fetches the opposing gangs with active wars for a player
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_owner",objNull,[objNull]],
	["_gangID",0,[0]],
	["_gangName","",[""]]
];
if (isNull _owner || _gangID isEqualTo 0 || _gangName isEqualTo "") exitWith {};

private _check = (_gangName find "'" != -1);
if (_check) exitWith {};

// 使用 Mapper 获取战争敌人
private _queryResult = ["getwarenemy", [str _gangID]] call DB_fnc_gangMapper;
if ((count _queryResult) isEqualTo 0) exitWith {};

if (isNull _owner) exitWith {};
[_queryResult] remoteExec ["OEC_fnc_warLoadActive",_owner,false];
