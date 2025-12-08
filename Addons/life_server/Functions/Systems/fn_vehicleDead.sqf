//	File: fn_vehicleDead.sqf
//	Description:
//	Tells the database that this vehicle has died and can't be recovered.
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_vehicle","_plate","_uid","_dbInfo","_isInsured","_color","_gangID"];
_vehicle = param [0,ObjNull,[ObjNull]];
waitUntil {uiSleep 1; _pos = getPosATL _vehicle; uiSleep 1;(_pos distance getPosATL _vehicle) < 10 || isNull _vehicle};
if(isNull _vehicle) exitWith {}; //NULL
private _handle = [_vehicle] spawn OES_fnc_pulloutDead;
waitUntil {uiSleep 0.5; scriptDone _handle};
if (typeOf _vehicle in ["O_Truck_03_repair_F","O_Truck_03_ammo_F","B_Truck_01_ammo_F","O_LSV_02_armed_F"]) exitWith {
	if(!isNil "_vehicle" && {!isNull _vehicle}) then {
		deleteVehicle _vehicle;
	};
};

_gangID = _vehicle getVariable ["gangID",0];
_dbInfo = _vehicle getVariable["dbInfo",[]];
_isInsured = _vehicle getVariable["insured",1];
private _mods = _vehicle getVariable["modifications",[0,0,0,0,0,0,0,0]];
_color = (_vehicle getVariable["oev_veh_color",["Default",0]]) select 0;
if(count _dbInfo == 0) exitWith {
	if(!isNil "_vehicle" && {!isNull _vehicle}) then {
		deleteVehicle _vehicle;
	};
};
_uid = _dbInfo select 0;
_plate = _dbInfo select 1;

if (_color isEqualType 0) then {_color = str _color};
format["car blew up, car %1, dbinfo %2, insured %3",_vehicle,_dbInfo,_isInsured] call OES_fnc_diagLog;

// 使用 vehicleMapper 根据保险类型处理车辆死亡
switch (_isInsured) do {
	case 0: {
		// 无保险 - 标记为死亡
		if (_gangID isEqualTo 0) then {
			["markdead", [_uid, _plate]] call DB_fnc_vehicleMapper;
		} else {
			["markgangdead", [str _gangID, _plate]] call DB_fnc_vehicleMapper;
		};
	};
	case 1: {
		// 基本保险 - 重置部分改装
		_mods set [0,0];
		_mods set [1,0];
		_mods set [2,0];
		if (_gangID isEqualTo 0) then {
			["deadbasicins", [_uid, _plate, parseText _color, str _mods]] call DB_fnc_vehicleMapper;
		} else {
			["deadgangbasicins", [str _gangID, _plate, _color, str _mods]] call DB_fnc_vehicleMapper;
		};
	};
	case 2: {
		// 全覆盖保险 - 保留改装
		if (_gangID isEqualTo 0) then {
			["deadfullins", [_uid, _plate]] call DB_fnc_vehicleMapper;
		} else {
			["deadgangfullins", [str _gangID, _plate]] call DB_fnc_vehicleMapper;
		};
	};
};

if(!isNil "_vehicle" && {!isNull _vehicle}) then {
	deleteVehicle _vehicle;
};
