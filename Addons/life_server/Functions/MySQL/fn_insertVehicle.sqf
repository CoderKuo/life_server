//	File: fn_insertVehicle.sqf
//	Author: Bryan "Tonic" Boardwine
//  Modified: 迁移到 PostgreSQL Mapper 层

//	Description:
//	Inserts the vehicle into the database

private["_uid","_side","_type","_className","_color","_plate","_spawnInGarage"];

_uid = param [0,"",[""]];
_side = param [1,"",[""]];
_type = param [2,"",[""]];
_className = param [3,"",[""]];
_color = param [4,-2,[]];
_plate = param [5,-1,[0]];
_gangID = param [6,0,[0]];
_spawnInGarage = param [7,false,[false]];
_mods = param [8,[0,0,0,0,0,0,0,0],[[]]];

private _check = (_uid find "'" != -1);
if (_check) exitWith {};
private _check = (_side find "'" != -1);
if (_check) exitWith {};
private _check = (_type find "'" != -1);
if (_check) exitWith {};
private _check = (_className find "'" != -1);
if (_check) exitWith {};

if (_color isEqualType 0) then {_color = str _color};
//Stop bad data being passed.
if(_uid == "" || _side == "" || _type == "" || _className == "" || _color isEqualTo -2 || _plate == -1) exitWith {};

// 使用 vehicleMapper 插入车辆
if !(_gangID isEqualTo 0) then {
	// 帮派车辆
	["insertgang", [_side, _className, _type, str _gangID, "0", parseText _color, str _plate, str _mods]] call DB_fnc_vehicleMapper;
} else {
	// 个人车辆
	private _active = if (_spawnInGarage) then { "0" } else { str olympus_server };
	["insert", [_side, _className, _type, _uid, _active, parseText _color, str _plate, str _mods]] call DB_fnc_vehicleMapper;
};
