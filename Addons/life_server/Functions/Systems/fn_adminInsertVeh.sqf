//	File: fn_adminInsertVeh.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Adds a vehicle to a player from admin island request
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_classname","",[""]],
	["_playerid","",[""]],
	["_admin",objNull,[objNull]]
];

if (_classname isEqualTo "" || _playerid isEqualTo "" || isNull _admin) exitWith {};

private _check = (_playerid find "'" != -1);
if (_check) exitWith {};
private _check = (_classname find "'" != -1);
if (_check) exitWith {};

// 使用 playerMapper 检查玩家是否存在
private _queryResult = ["getuid", [_playerid]] call DB_fnc_playerMapper;

if ((count _queryResult) isEqualTo 0) exitWith {
	[[4,"The player you attempted to give a vehicle to doesn't exist in our database!"],"OEC_fnc_broadcast",(owner _admin),false] spawn OEC_fnc_MP;
};

private _type = switch (_classname) do {
	case "O_T_LSV_02_armed_F": {"Car"};
	case "B_T_LSV_01_armed_F": {"Car"};
	case "I_G_Offroad_01_AT_F": {"Car"};
	case "I_C_Offroad_02_LMG_F": {"Car"};
	case "I_MRAP_03_F": {"Car"};
	case "B_MRAP_01_F": {"Car"};
	case "O_MRAP_02_F": {"Car"};
	case "O_LSV_02_unarmed_viper_F": {"Car"};
	case "B_LSV_01_unarmed_black_F": {"Car"};
	case "B_G_Offroad_01_armed_F": {"Car"};
	case "B_G_Offroad_01_F": {"Car"};
	case "B_Truck_01_box_F": {"Car"};
	case "B_Truck_01_fuel_F": {"Car"};
	case "B_Truck_01_transport_F": {"Car"};
	case "C_Hatchback_01_sport_F": {"Car"};
	case "C_Hatchback_01_F": {"Car"};
	case "I_Truck_02_transport_F": {"Car"};
	case "I_Truck_02_fuel_F": {"Car"};
	case "I_Truck_02_covered_F": {"Car"};
	case "O_Truck_03_transport_F": {"Car"};
	case "O_Truck_03_fuel_F": {"Car"};
	case "O_Truck_03_device_F": {"Car"};
	case "O_Truck_03_covered_F": {"Car"};
	case "B_Heli_Light_01_F": {"Air"};
	case "B_Heli_Transport_01_F": {"Air"};
	case "B_Heli_Transport_03_unarmed_F": {"Air"};
	case "C_Heli_Light_01_civil_F": {"Air"};
	case "B_Heli_Transport_03_black_F": {"Air"};
	case "I_Heli_Transport_02_F": {"Air"};
	case "B_Heli_Transport_01_camo_F": {"Air"};
	case "I_Heli_light_03_unarmed_F": {"Air"};
	case "O_Heli_Light_02_unarmed_F": {"Air"};
	case "O_Heli_Transport_04_bench_F": {"Air"};
	case "O_Heli_Transport_04_covered_F": {"Air"};
	case "O_Heli_Transport_04_F": {"Air"};
	case "O_Heli_Transport_04_fuel_F": {"Air"};
	case "C_Plane_Civil_01_F": {"Plane"};
	case "C_Plane_Civil_01_racing_F": {"Plane"};
	case "B_T_VTOL_01_vehicle_F": {"Plane"};
	case "B_T_VTOL_01_infantry_F": {"Plane"};
	case "O_Plane_CAS_02_F": {"Plane"};
	case "B_Plane_CAS_01_F": {"Plane"};
	case "I_Plane_Fighter_03_CAS_F": {"Plane"};
	case "C_Van_02_vehicle_F": {"Car"};
	case "C_Van_02_transport_F": {"Car"};
	case "B_Heli_Transport_01_camo_F": {"Air"};
	case "I_Plane_Fighter_04_F": {"Plane"};
	case "B_Plane_Fighter_01_F": {"Plane"};
	case "O_Plane_Fighter_02_F": {"Plane"};
};

private _plate = round(random(999999));

[_playerid,"civ",_type,_classname,-1,_plate,0,true] call OES_fnc_insertVehicle;
[[4,"The vehicle has been successfully added to the players garage! You might have to wait till after restart for it to appear!"],"OEC_fnc_broadcast",(owner _admin),false] spawn OEC_fnc_MP;

format ["-ISLAND- Admin %1 (%2) has inserted a %3 (%4) into this persons garage: %5",name _admin,getPlayerUID _admin,getText(configFile >> "cfgVehicles" >> _classname >> "displayName"),_classname,_playerid] call OES_fnc_diagLog;
