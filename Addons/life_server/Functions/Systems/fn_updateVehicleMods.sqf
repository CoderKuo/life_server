//	File: fn_updateVehicleMods.sqf
//	Author: Poseidon
//	Description: updates the vehicles mods
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_vehicle","_insured","_color","_uid","_plate","_dbInfo","_mods","_gangID"];
_vehicle = param [0,objNull,[objNull]];
_insured = param [1,0,[0]];
_color = param [2,["Default",0],[[]]];
_mods = param [3,[0,0,0,0,0,0,0,0],[[]]];

//Error checks
if(isNull _vehicle) exitWith {};

_dbInfo = _vehicle getVariable["dbInfo",[]];
if(count _dbInfo == 0) exitWith {};

_insured = [_insured] call OES_fnc_numberToString;

_color = (str _color) splitString '""';
_color = _color joinString "";

//_color = [_color] call OES_fnc_escapeArray;
_mods = [_mods] call OES_fnc_escapeArray;
_gangID = _vehicle getVariable ["gangID",0];

_uid = _dbInfo select 0;
_plate = _dbInfo select 1;

// 使用 vehicleMapper 更新车辆配置
if !(_gangID IsEqualTo 0) then {
	["updategangmods", [str _gangID, str _plate, str _insured, _mods, str _color]] call DB_fnc_vehicleMapper;
} else {
	["updatemods", [_uid, str _plate, str _insured, _mods, str _color]] call DB_fnc_vehicleMapper;
};
