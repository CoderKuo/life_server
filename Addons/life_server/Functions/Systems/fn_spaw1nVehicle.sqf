//	File: fn_spaw1nVehicle.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description:
//	Sends the query request to the database, if an array is returned then it creates
//	the vehicle if it's not in use or dead.

private["_query","_sql","_vehicle","_nearVehicles","_name","_side","_tickTime","_turbo","_gangID","_playerIDs","_owners","_modifications","_boat"];
params [
	["_vid","",[""]],
	["_pid","",[""]],
	["_sp",[],[[],""]],
	["_unit",objNull,[objNull]],
	["_price",0,[0]],
	["_dir",0,[0]],
	["_gangID",0,[0]],
	["_gangName","",[""]],
	["_override",false,[false]]
];

private _check = (_pid find "'" != -1);
if (_check) exitWith {};
private _check = (_gangName find "'" != -1);
if (_check) exitWith {};


_query = "";
_unit_return = _unit;
_name = name _unit;
_side = side _unit;
_unit = owner _unit;
_playerIDs = [];
_owners = [];
_boat = (getMarkerPos "reb_boat1_2" distance2D _unit_return <= 100);
_airCarrier = (getMarkerPos "civ_plane_16" distance2D _unit_return <= 100);
if(_vid isEqualTo "" || _pid isEqualTo "") exitWith {};
if(_vid in serv_sv_use) exitWith {};
serv_sv_use pushBack _vid;
if !(_gangID isEqualTo 0) then {
	_query = format["SELECT CONVERT(id, char), side, classname, type, gang_id, alive, active, plate, color, insured, modifications FROM "+dbColumGangVehicle+" WHERE id=%1 AND gang_id='%2'",_vid,_gangID];
} else {
	_query = format["SELECT CONVERT(id, char), side, classname, type, pid, alive, active, plate, color, insured, modifications, customName FROM "+dbColumVehicle+" WHERE id=%1 AND pid='%2'",_vid,_pid];
};


_tickTime = diag_tickTime;
_queryResult = [_query,2] call OES_fnc_asyncCall;


_new = (_queryResult select 8) splitString "[,]";
_new = [_new select 0, call compile (_new select 1)];
//_new = [(_queryResult select 8)] call OES_fnc_mresToArray;
if(_new isEqualType "") then {_new = call compile format["%1", _new];};
_queryResult set[8,_new];

_new = [(_queryResult select 10)] call OES_fnc_mresToArray;
if(_new isEqualType "") then {_new = call compile format["%1", _new];};
_queryResult set[10,_new];

"------------- Spawn Selected Vehicle -------------" call OES_fnc_diagLog;
format["QUERY: %1",_query] call OES_fnc_diagLog;
format["完成时间: %1 (in seconds)",(diag_tickTime - _tickTime)] call OES_fnc_diagLog;
format["车辆查询结果: %1",_queryResult] call OES_fnc_diagLog;
"--------------------------------------------------" call OES_fnc_diagLog;

if(_queryResult isEqualType "") exitWith {};

_vInfo = _queryResult;
if(isNil "_vInfo") exitWith {serv_sv_use = serv_sv_use - [_vid];};
if(count _vInfo isEqualTo 0) exitWith {serv_sv_use = serv_sv_use - [_vid];};

if((_vInfo select 5) isEqualTo 0) exitWith {
	serv_sv_use = serv_sv_use - [_vid];
	[1,format[(localize "STR_Garage_SQLError_Destroyed"),getText(configFile >> "CfgVehicles" >> (_vInfo select 2) >> "displayName")]] remoteExec ["OEC_fnc_broadcast",_unit,false];
};

if((_vInfo select 6) isEqualTo 1) exitWith {
	serv_sv_use = serv_sv_use - [_vid];
	[1,format[(localize "STR_Garage_SQLError_Active"),getText(configFile >> "CfgVehicles" >> (_vInfo select 2) >> "displayName")]] remoteExec ["OEC_fnc_broadcast",_unit,false];
};

if(typeName _sp != "STRING") then {
	if !(_override) then {
		_nearVehicles = count(nearestObjects[_sp,["Car","Ship"],5]) + count(nearestObjects[_sp,["Air"],8]);
	} else {
		_nearVehicles = 0;
	};
} else {
	_nearVehicles = 0;
};

if(_boat) then {
	_sp set[2,8.5];
	_nearVehicles = _nearVehicles + count(nearestObjects[_sp,["Car","Ship","Air"],5]);
};
if(_airCarrier) then {
	_sp set[2,23.5435];
	_nearVehicles = _nearVehicles + count(nearestObjects[_sp,["Car","Ship","Air"],5]);
};

if(_nearVehicles > 0) exitWith {
	serv_sv_use = serv_sv_use - [_vid];
	[_price,_unit_return] remoteExec ["OEC_fnc_garageRefund",_unit,false];
	[1,(localize "STR_Garage_SpawnPointError")] remoteExec ["OEC_fnc_broadcast",_unit,false];
};

private _isInsured = (_vInfo select 9);

switch (_isInsured) do {
	case 0: {
		[0,"这辆车没有保险，如果它被毁坏了，你就拿不回来了！"] remoteExecCall ["OEC_fnc_broadcast",_unit,false];
	};
	case 1: {
		[0,"该车有基本保障，销毁后会更换。替换车辆没有保险或改装."] remoteExecCall ["OEC_fnc_broadcast",_unit,false];
	};
	case 2: {
		[0,"该车全覆盖，销毁后会更换。替换车辆将包含您的所有修改，但没有保险."] remoteExecCall ["OEC_fnc_broadcast",_unit,false];
	};
};

if !(_gangID isEqualTo 0) then {
	_query = format["UPDATE "+dbColumGangVehicle+" SET active='%1', persistentServer='0' WHERE gang_id='%2' AND id=%3",olympus_server,_gangID,_vid];
} else {
	_query = format["UPDATE "+dbColumVehicle+" SET active='%1', persistentServer='0' WHERE pid='%2' AND id=%3",olympus_server,_pid,_vid];
};

private _SpecialVehicles = ["I_Heli_Transport_02_F","O_Heli_Transport_04_F","O_Heli_Transport_04_bench_F","B_Heli_Transport_03_unarmed_F"];
[_query,1] spawn OES_fnc_asyncCall;
if(_sp isEqualType "") then {
	_vehicle = createVehicle[(_vInfo select 2),[0,0,999],[],0,"NONE"];
	waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
	_vehicle allowDamage false;
	_vehicle lock 2;
	_hs = nearestObjects[getMarkerPos _sp,["Land_Hospital_side2_F"],175] select 0;
	_vehicle setPosATL (_hs modelToWorld [-0.4,-4,12.65]);
	_vehicle setVectorUp [0,0,-1];
	uiSleep 0.6;
} else {
	_sp set [2,(_sp select 2) + 0.25];
	_vehicle = createVehicle [(_vInfo select 2),_sp,[],0,"NONE"];
	waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
	_vehicle allowDamage false;
	_vehicle lock 2;
	if(_boat || _airCarrier) then { //Rebel boat & aircraft carrier check
		if(_boat) then {
			_sp set [2,8.5];
		};
		if(_airCarrier) then {
			_sp set [2,23.5435];
		};
		_vehicle setPosASL _sp; //Use ASL coords instead
	} else {
		_vehicle setPos _sp;
	};
	_vehicle setVectorUp (surfaceNormal _sp);
	_vehicle setDir _dir;
};
[_vehicle] remoteExecCall ["OEC_fnc_revealVeh", _unit_return];
if (typeOf _vehicle in _SpecialVehicles) then{
	_vehicle setDamage 0.10;
	uiSleep 0.5;
	_vehicle setDamage 0;
};

[_pid,_side,_vehicle,1] call OES_fnc_keyManagement;
//Reskin the vehicle
[_vehicle,_vInfo select 8,_side] remoteExec ["OEC_fnc_colorVehicle",0,true];
_vehicle setVariable ["isBlackwater",false,true];

//Is it a gang vehicle?
if !(_gangID isEqualTo 0) then {
	_vehicle setVariable ["gangID",_gangID,true];
	_vehicle setVariable ["gangName",_gangName,true];

	//Distribute keys to gang members
	{
		if ((side _x isEqualTo civilian) && {(((_x getVariable ["gang_data",[0,"",0]]) select 0) isEqualTo _gangID)}) then {
			_owners pushBack [getPlayerUID _x,_x getVariable["realname",name _x]];
			//Send keys over the network.
			[_vehicle,true] remoteExec ["OEC_fnc_addVehicle2Chain",_x,false];
			[getPlayerUID _x,side _x,_vehicle,1] spawn OES_fnc_keyManagement;
		};
	} forEach playableUnits;
	_vehicle setVariable ["vehicle_info_owners",_owners,true];
} else {
	_vehicle setVariable ["vehicle_info_owners",[[_pid,_name]],true];
	//Send keys over the network.
	[_vehicle] remoteExec ["OEC_fnc_addVehicle2Chain",_unit,false];
};

_modifications = _vInfo select 10;
_customName = "";
if (_gangID isEqualTo 0) then {
	_customName = _vInfo select 11;
};
_vehicle setVariable ["dbInfo",[(_vInfo select 4),_vInfo select 7],true];
_vehicle setVariable ["defaultModMass",(getMass _vehicle),true];
_vehicle setVariable ["insured",_isInsured,true];
_vehicle setVariable ["side",(_vInfo select 1),true];
_vehicle setVariable ["modifications",_modifications,true];
if !(_customName isEqualTo "") then {
	_vehicle setVariable ["customName",_customName,true];
};
//_vehicle addEventHandler ["Killed","[_this select 0] spawn OES_fnc_vehicleDead"];
_vehicle enableRopeAttach false;
_vehicle disableTIEquipment true;

if(_vehicle isKindOf "LandVehicle" || _vehicle isKindOf "Air" || _vehicle isKindOf "Ship") then {
	life_serv_vehicles pushBack _vehicle;
	if(_vehicle isKindOf "Air") then {
		_vehicle addEventHandler ["RopeAttach", {
			if !(owner (currentPilot (_this select 0)) isEqualTo owner (_this select 2)) then {
				(_this select 2) setOwner (owner (currentPilot (_this select 0)));
			};
			if (count crew (_this select 2) > 0) then {
				hint "Warning! Slinging vehicles with players in them is unstable and the rope may break!";
				{
					['Warning! Slinging vehicles with players in them is unstable and the rope may break!'] remoteExec['hint',_x];
				} forEach (crew (_this select 2));
				[(_this select 2),(_this select 0),owner (currentPilot (_this select 0))] spawn{
					waitUntil{(count crew (_this select 0) isEqualTo 0) && (owner (currentPilot (_this select 1)) isEqualTo (_this select 2))};
					(_this select 0) setOwner (_this select 2);
				};
			};
		}];
	};
};

_turbo = _modifications select 0;
switch (_turbo) do {
	case 0: {_turbo = 1;};
	case 1: {_turbo = 1.22;};
	case 2: {_turbo = 1.44;};
	case 3: {_turbo = 1.66;};
	case 4: {_turbo = 1.88;};
};
if(_turbo > 0) then {
	if(_vInfo select 3 == "Air" || _vInfo select 3 == "Plane") then {
		_vehicle setMass ((getMass _vehicle)*(_turbo));
	} else {
		_vehicle setMass ((getMass _vehicle)/(_turbo));
	};
};

[_vehicle, (_vInfo select 1)] call OEC_fnc_clearVehicleAmmo;

_customName = "";
if (_gangID isEqualTo 0) then {
	_customName = _vInfo select 11;
};
if(_customName != "") then {
	_vehicle setVariable ["customName", _customName];
};

//Sets of animations
if((_vInfo select 1) == "cop" && ((_vInfo select 2) isEqualTo "C_Offroad_01_F" || (_vInfo select 2) isEqualTo "C_Offroad_01_comms_F" || (_vInfo select 2) isEqualTo "C_Offroad_01_covered_F")) then {
	[_vehicle,"cop_offroad",true] remoteExec ["OEC_fnc_vehicleAnimate",_unit,false];

};

if((_vInfo select 1) == "med" && ((_vInfo select 2) == "C_Offroad_01_F" || (_vInfo select 2) isEqualTo "C_Offroad_01_comms_F")) then {
	[_vehicle,"med_offroad",true] remoteExec ["OEC_fnc_vehicleAnimate",_unit,false];
};

if((_vInfo select 1) == "med" && (_vInfo select 2) == "C_Van_02_medevac_F") then {
	_vehicle removeWeaponTurret ["AmbulanceHorn",[-1]];
	_vehicle addWeaponTurret ["SportCarHorn",[-1]];
};

if ((_vInfo select 2) isEqualTo "I_G_Offroad_01_AT_F") then {
	_vehicle setVehicleAmmo 0.3;
	_vehicle setObjectTextureGlobal [0,"\A3\Soft_F_Bootcamp\Offroad_01\Data\offroad_01_ext_IG_01_CO.paa"];
};

if((_vInfo select 1) in ["med","cop"]) then {
	_vehicle setVariable ["lights",false,true];
};

if ((_vInfo select 2) isEqualTo "I_G_Offroad_01_armed_F") then {
	[_vehicle,["Guerilla_12",1], ["Hide_Shield",0,"Hide_Rail",0,"HideDoor1",0,"HideDoor2",0,"HideDoor3",0,"HideBackpacks",0,"HideBumper1",1,"HideBumper2",0,"HideConstruction",0]] call BIS_fnc_initVehicle;
};
//if((_vInfo select 2) isEqualTo "O_LSV_02_unarmed_viper_F") then {
//	[_vehicle,"qilin_doors",true] remoteExec ["OEC_fnc_vehicleAnimate",_unit];
//};

if ((_modifications select 2) >= 3) then {
	[_vehicle, false] remoteExec ["OEC_fnc_installTracker", _unit];
};

["vehicle_info_lastSeen", position _vehicle, _vehicle] remoteExecCall ["OEC_fnc_netSetVar", _unit];

//uiSleep 0.3;

[_vehicle] remoteExec ["OEC_fnc_unblockVehSpawn", _unit];

if (typeOf _vehicle in _SpecialVehicles) then {
	serv_sv_use = serv_sv_use - [_vid];
	uiSleep .85;
	_vehicle allowDamage true;
}
else {
	_vehicle allowDamage true;
	[1,"您的载具已经准备就绪!"] remoteExecCall ["OEC_fnc_broadcast",_unit,false];
	serv_sv_use = serv_sv_use - [_vid];
};


//_vehicle allowDamage true;

//[1,"Your vehicle is ready!"] remoteExecCall ["OEC_fnc_broadcast",_unit,false];
//serv_sv_use = serv_sv_use - [_vid];
