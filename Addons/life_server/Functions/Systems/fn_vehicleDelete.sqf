//	File: fn_vehicleDelete.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description:
//	Doesn't actually delete since we don't give our DB user that type of
//	access so instead we set it to alive=0 so it never shows again.
//  Modified: 迁移到 PostgreSQL Mapper 层
params [
	["_vid","",[""]],
	["_pid","",[""]],
	["_sp",2500,[0]],
	["_unit",objNull,[objNull]],
	["_type","",[""]]
];

private _check = (_pid find "'" != -1);
if (_check) exitWith {};
private _check = (_type find "'" != -1);
if (_check) exitWith {};

if(_vid isEqualTo "" || {_pid isEqualTo ""} || {_sp isEqualTo 0} || {isNull _unit} || {_type isEqualTo ""}) exitWith {};

// 使用 vehicleMapper 删除车辆
["deletebyid", [_pid, _vid]] call DB_fnc_vehicleMapper;