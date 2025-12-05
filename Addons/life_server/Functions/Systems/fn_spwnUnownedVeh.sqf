//	File: fn_spwnUnownedVeh.sqf
//	Author: Jesse "tkcjesse" Schultz

//	Description: Creates a vehicle that is "unowned" which will be used in fn_claimVehicle to give ownership.

params ["_vehicleClass"];

if !(isClass (configFile >> "CfgVehicles" >> _vehicleClass)) exitWith {};

private _position = [20906.7,19220.9,0];
private _direction = 24.6267;
private _distance = 8;
private _turbo = 1.88;
if (_vehicleClass in ["B_Heli_Transport_03_black_F","B_Heli_Transport_01_camo_F"]) then {
	_position = [20887.7,19266.3,0];
	_direction = 110;
	_distance = 16;
};

{deleteVehicle _x;} forEach nearestObjects[_position,["Car","Air","Ship","Armored","Submarine"],_distance];

private _vehicle = createVehicle [_vehicleClass,_position,[],0,"NONE"];
private _defaultMass = getMass _vehicle;
if(typeof _vehicle in ["B_Heli_Light_01_F","O_Heli_Light_02_unarmed_F","I_Heli_Transport_02_F","B_Heli_Transport_01_F","B_Heli_Transport_01_camo_F","C_Heli_Light_01_civil_F","O_Heli_Transport_04_F","O_Heli_Transport_04_repair_F","O_Heli_Transport_04_bench_F","O_Heli_Transport_04_covered_F","O_Heli_Transport_04_medevac_F","B_Heli_Transport_03_unarmed_F","C_Plane_Civil_01_F","C_Plane_Civil_01_racing_F","B_T_VTOL_01_vehicle_F","B_T_VTOL_01_infantry_F","B_Heli_Transport_03_F","B_Heli_Transport_03_unarmed_green_F","O_Heli_Transport_04_fuel_F","I_Heli_light_03_unarmed_F","I_Heli_light_03_dynamicLoadout_F"]) then {
	_vehicle setMass (_defaultMass*(_turbo));
} else {
	_vehicle setMass (_defaultMass/(_turbo));
};
//_vehicle setMass ((getMass _vehicle)/(_turbo));
waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
_vehicle allowDamage false;
_vehicle setDir _direction;

_vehicle spawn{
	sleep 10;
	_this allowDamage true;
};

if (_vehicleClass isEqualTo "I_G_Offroad_01_AT_F") then {
	_vehicle setVehicleAmmo 0.3;
	_vehicle setObjectTextureGlobal [0,"\A3\Soft_F_Bootcamp\Offroad_01\Data\offroad_01_ext_IG_01_CO.paa"];
};

[_vehicle,"civ"] call OEC_fnc_clearVehicleAmmo;

_vehicle setVariable ["isBlackwater",true,true];
_vehicle setVariable ["dbinfo","1234",true];
_vehicle setVariable ["side","civ",true];
_vehicle setVariable ["vehicle_info_owners",["01234","Blackwater Vehicle"],true];
_vehicle setVariable ["defaultModMass",(getMass _vehicle),true];
_vehicle setVariable ["modifications",[4,0,0,0,0,0,0,0],true];
_vehicle setVariable ["insured",0,true];
//_vehicle addEventHandler ["Killed","[_this select 0] spawn OES_fnc_vehicleDead"];
_vehicle enableRopeAttach false;
