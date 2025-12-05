// File: fn_createServVeh.sqf
// Author: Jesse "tkcjesse" Schultz
// Creates what use to be a client side vehicle server side...
params [
	["_className","",[""]],
	["_type","",[""]],
	["_markerPos",[],[[]]],
	["_markerDir",-1,[0]],
	["_uid","",[""]],
	["_name","",[""]],
	["_color",[-1,0],[[]]],
	["_side","",[""]],
	["_withMods", false, [false]],
	["_defaultMods", [0,0,0,0,0,0,0,0], [[]]],
	["_unit",objNull,[objNull]]
];
diag_log _this;

if (_uid isEqualTo "" || {_className isEqualTo ""} || {_name isEqualTo ""} || {_markerPos isEqualTo []} || {_markerDir isEqualTo -1} || {_side isEqualTo ""} || {_type isEqualTo ""}) exitWith {diag_log "SERVER EXITED"};

private _plate = round(floor(random(999999)));
_boat = [allMapMarkers, _markerPos] call BIS_fnc_nearestPosition isEqualTo "reb_boat1_2";
_airCarrier = [allMapMarkers, _markerPos] call BIS_fnc_nearestPosition isEqualTo "civ_plane_16";
private _check = (_className find "'" != -1);
if (_check) exitWith {};
private _check = (_type find "'" != -1);
if (_check) exitWith {};
private _check = (_uid find "'" != -1);
if (_check) exitWith {};
private _check = (_name find "'" != -1);
if (_check) exitWith {};
private _check = (_side find "'" != -1);
if (_check) exitWith {};


[format ["INSERT INTO vehicles (side,classname,type,pid,alive,active,inventory,color,plate,insured,modifications) VALUES ('%1','%2','%3','%4','1','%5','""[]""','""[%6,%7]""','%8','0','""%9""')",_side,_className,_type,_uid,olympus_server,parseText(_color select 0),_color select 1,_plate,_defaultMods],1] call OES_fnc_asyncCall;
private _SpecialVehicles = ["I_Heli_Transport_02_F","O_Heli_Transport_04_F","O_Heli_Transport_04_bench_F","B_Heli_Transport_03_unarmed_F"];

_markerPos set [2,(_markerPos select 2) + 0.25];
private _vehicle = createVehicle [_className, _markerPos, [], 0, "NONE"];
waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
[_vehicle] remoteExec ["OEC_fnc_unblockVehSpawn", remoteExecutedOwner];
_vehicle allowDamage false;
_vehicle lock 2;
if(_boat || _airCarrier) then {
	if(_boat) then {
		_markerPos set [2,8.5];
	};
	if(_airCarrier) then {
		_markerPos set [2,23.5435];
	};
	_vehicle setPosASL _markerPos;
} else {
	_vehicle setPos _markerPos;
};
_vehicle setVectorUp (surfaceNormal(_markerPos));
_vehicle setDir _markerDir;
[_vehicle] remoteExecCall ["OEC_fnc_revealVeh", _unit];

[_uid,side _unit,_vehicle,1] call OES_fnc_keyManagement;
_vehicle setVariable ["oev_veh_color",_color,true];
[_vehicle,_color] remoteExec ["OEC_fnc_colorVehicle",0,true];
if !(remoteExecutedOwner isEqualTo 0) then {
	[_vehicle] remoteExecCall ["OEC_fnc_addVehicle2Chain",remoteExecutedOwner];
};
_vehicle setVariable ["dbInfo",[_uid,_plate],true];
_vehicle setVariable ["vehicle_info_owners",[[_uid,_name]],true];
_vehicle setVariable ["isBlackwater",false,true];
_vehicle setVariable ["defaultModMass",(getMass _vehicle),true];
_vehicle setVariable ["modifications",_defaultMods,true];
_vehicle setVariable ["insured",0,true];
_vehicle setVariable ["side",_side,true];
//_vehicle addEventHandler ["Killed","[_this select 0] spawn OES_fnc_vehicleDead"];
_vehicle enableRopeAttach false;
_vehicle disableTIEquipment true;

[_vehicle,_side] call OEC_fnc_clearVehicleAmmo;

if(_vehicle isKindOf "LandVehicle" || _vehicle isKindOf "Air" || _vehicle isKindOf "Ship") then {
	life_serv_vehicles pushBack _vehicle;
	if(_vehicle isKindOf "Air") then {
		_vehicle addEventHandler ["RopeAttach", {
			if !(owner (currentPilot (_this select 0)) isEqualTo owner (_this select 2)) then {
				(_this select 2) setOwner (owner (currentPilot (_this select 0)));
			};
			if (count crew (_this select 2) > 0) then {
				hint "警告！携带玩家的吊挂车辆不稳定，绳索可能断裂!";
				{
					['警告！携带玩家的吊挂车辆不稳定，绳索可能断裂!'] remoteExec['hint',_x];
				} forEach (crew (_this select 2));
				[(_this select 2),(_this select 0),owner (currentPilot (_this select 0))] spawn{
					waitUntil{(count crew (_this select 0) isEqualTo 0) && (owner (currentPilot (_this select 1)) isEqualTo (_this select 2))};
					(_this select 0) setOwner (_this select 2);
				};
			};
		}];
	};
};

if (_withMods) then {
	[_vehicle, _withMods] remoteExec ["OEC_fnc_modShopMenu",remoteExecutedOwner];
};
if (typeOf _vehicle in _SpecialVehicles) then{
	_vehicle setDamage 0.10;
	uiSleep 0.5;
	_vehicle setDamage 0;
};

if (_side isEqualTo "cop" && {!(remoteExecutedOwner isEqualTo 0)} && {(_className isEqualTo "C_Offroad_01_F" || _className isEqualTo "C_Offroad_01_comms_F" || _className isEqualTo "C_Offroad_01_covered_F")}) then {
	[_vehicle,"cop_offroad",true] remoteExec ["OEC_fnc_vehicleAnimate",remoteExecutedOwner];
};

if (_side isEqualTo "med" && {!(remoteExecutedOwner isEqualTo 0)} && {_className in ["C_Offroad_01_F","C_Van_02_medevac_F","C_Offroad_01_comms_F"]}) then {
	if (_className isEqualTo "C_Van_02_medevac_F") then {
		_vehicle removeWeaponTurret ["AmbulanceHorn",[-1]];
		_vehicle addWeaponTurret ["SportCarHorn",[-1]];
	} else {
		[_vehicle,"med_offroad",true] remoteExec ["OEC_fnc_vehicleAnimate",remoteExecutedOwner];
	};
};
if (_className isEqualTo "I_G_Offroad_01_armed_F") then {
	[_vehicle,["Guerilla_12",1], ["Hide_Shield",0,"Hide_Rail",0,"HideDoor1",0,"HideDoor2",0,"HideDoor3",0,"HideBackpacks",0,"HideBumper1",1,"HideBumper2",0,"HideConstruction",0]] call BIS_fnc_initVehicle;
};

if (_side in ["cop","med"]) then {
	_vehicle setVariable ["lights",false,true];
};

//if (_className isEqualTo "O_LSV_02_unarmed_viper_F") then {
//	[_vehicle,"qilin_doors",true] remoteExec ["OEC_fnc_vehicleAnimate",remoteExecutedOwner];
//};

format ["在位置%1为UID%2创建的车辆",_markerPos,_uid] call A3LOG_fnc_log;

if (remoteExecutedOwner isEqualTo 0) exitWith {};

private _SpecialVehicles = ["I_Heli_Transport_02_F","O_Heli_Transport_04_F","O_Heli_Transport_04_bench_F","B_Heli_Transport_03_unarmed_F"];

if (typeOf _vehicle in _SpecialVehicles) then {
	[1,"你的车准备好了！按U键可锁定和解锁车辆."] remoteExecCall ["OEC_fnc_broadcast",remoteExecutedOwner];
	uiSleep .85;
	_vehicle allowDamage true;
}
else {
	_vehicle allowDamage true;
	[1,"你的车准备好了！按U键可锁定和解锁车辆."] remoteExecCall ["OEC_fnc_broadcast",remoteExecutedOwner];
};
