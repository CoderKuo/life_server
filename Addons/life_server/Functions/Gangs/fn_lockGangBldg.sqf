//	File: fn_lockGangBldg.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Locks out a gang building due to not enough members.
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_gangID",-2,[0]],
	["_gangName","",[""]]
];
if (_gangID < 0 || _gangName isEqualTo "") exitWith {};

private _check = (_gangName find "'" != -1);
if (_check) exitWith {};

// 使用 Mapper 获取建筑详情
private _queryResult = ["getbuildingdetails", [str _gangID, _gangName, str olympus_server]] call DB_fnc_gangMapper;
if (count _queryResult isEqualTo 0) exitWith {};

private _pos = call compile format ["%1",_queryResult select 2];
private _building = _pos nearestObject "House_F";
if !(typeOf _building isEqualTo (_queryResult select 3)) exitWith {};
if !(_building getVariable ["bldg_gangName",""] isEqualTo (_queryResult select 4)) exitWith {};
