//	File: fn_copSeizeVeh.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Will seize the car
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_unit","_vehicle","_gangID"];
_unit = param [0,objNull,[objNull]];
_vehicle = param [1,objNull,[objNull]];
_seizerUID = getPlayerUID _unit;
_gangID = _vehicle getVariable ["gangID",0];
//Error checks
if(isNull _unit) exitWith {};
_unit = owner _unit;
if(isNull _vehicle) exitWith {
	[["oev_action_inUse",false],"OEC_fnc_netSetVar",_unit,false] spawn OEC_fnc_MP;
};

_dbInfo = _vehicle getVariable["dbInfo",[]];

_uid = _dbInfo select 0;
_plate = _dbInfo select 1;

if([_vehicle] call OEC_fnc_skinName isEqualTo "APD Vandal" && _gangID isEqualTo 0 && typeOf _vehicle isEqualTo "C_Hatchback_01_sport_F") then {
	// APD vandal skins in personal garages get transferred on seize
	// 使用 vehicleMapper 转移并设置为警用
	["seizeandtransfer", [_uid, str _plate, _seizerUID, "'[Police,0]'", "cop"]] call DB_fnc_vehicleMapper;
} else {
	if((typeof _vehicle) in ["B_Heli_Transport_01_F"]) then {
		// 直升机不处理
	}else{
		if !(_gangID isEqualTo 0) then {
			// 使用 vehicleMapper 删除帮派车辆
			["deletegangbyplate", [str _gangID, str _plate]] call DB_fnc_vehicleMapper;
		} else {
			// 使用 vehicleMapper 删除玩家车辆
			["sell", [_uid, str _plate]] call DB_fnc_vehicleMapper;
		};
	};
};

deleteVehicle _vehicle;
[["oev_action_inUse",false],"OEC_fnc_netSetVar",_unit,false] spawn OEC_fnc_MP;
