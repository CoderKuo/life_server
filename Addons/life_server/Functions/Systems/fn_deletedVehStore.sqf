// File: fn_deletedVehStore.sqf
// Author: Astral
// Description: Replaces a vehicle in a players garage after it is deleted by an admin.
// Modified: 迁移到 PostgreSQL Mapper 层

private["_plate","_uid","_vehicle","_vinfo","_vehGangID"];

_vehicle = param [0,ObjNull,[ObjNull]];
_vInfo = _vehicle getVariable["dbInfo",[]];
_vehGangID = _vehicle getVariable ["gangID",0];
_plate = -1;
_uid = "";

if(_vehicle getVariable ["isBlackwater",false] || count _vInfo == 0) exitWith {deleteVehicle _vehicle;}; // no need to update garage here

if(count _vInfo > 0) then {
	_plate = _vInfo select 1;
	_uid = _vInfo select 0;
};

// 使用 vehicleMapper 设置车辆为非激活状态
if !(_vehGangID isEqualTo 0) then {
	["setganginactive", [str _vehGangID, _plate]] call DB_fnc_vehicleMapper;
} else {
	["setinactive", [_uid, _plate]] call DB_fnc_vehicleMapper;
};

deleteVehicle _vehicle;
