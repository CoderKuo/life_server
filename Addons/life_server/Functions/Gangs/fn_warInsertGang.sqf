//	File: fn_warInsertGang.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Inserts an accepted war into the DB
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_instigator",objNull,[objNull]],
	["_invGangID",0,[0]],
	["_invGangName","",[""]],
	["_acptGangID",0,[0]],
	["_acptGangName","",[""]],
	["_acceptor",objNull,[objNull]]
];

if (isNull _instigator || isNull _acceptor) exitWith {};
if (_invGangID isEqualTo 0 || _acptGangID isEqualTo 0) exitWith {};
if (_invGangID isEqualTo _acptGangID) exitWith {};
if (_acptGangName isEqualTo "" || _invGangName isEqualTo "") exitWith {};

private _check = (_invGangName find "'" != -1);
if (_check) exitWith {};
private _check = (_acptGangName find "'" != -1);
if (_check) exitWith {};

private _instigUID = getPlayerUID _instigator;
private _acptUID = getPlayerUID _acceptor;

// 使用 Mapper 检查战争是否已存在
private _queryResult = ["warexists", [str _invGangID, str _acptGangID]] call DB_fnc_gangMapper;

if !(count _queryResult isEqualTo 0) exitWith {};

// 使用 Mapper 宣战
["declarewar", [_instigUID, str _invGangID, _invGangName, _acptUID, str _acptGangID, _acptGangName]] call DB_fnc_gangMapper;
