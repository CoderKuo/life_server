//	File: fn_gangClaim.sqf
//	Author: Jesse "tkcjesse" Schultz
//  Modified by: Kurt
//	Description: Switches vehicle owner in DB for the gang
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_vehicle",objNull,[objNull]],
	["_player",objNull,[objNull]],
	["_gangID",0,[0]]
];
//Check if the vehicle can be added to the garage
if (isNull _vehicle || isNull _player || !(alive _vehicle)) exitWith {
	"-CLAIM- A vehicle failed to be added to the gang." call OES_fnc_diagLog;
};

private _vInfo = _vehicle getVariable ["dbInfo",[]];
if (count _vInfo isEqualTo 0) exitWith {
	//Is the vehicle spawned in??
	format ["-CLAIM- A %1 was attempted to be added to a gang but was deleted by the server for improper info.",getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")] call OES_fnc_diagLog;
	deleteVehicle _vehicle;
	[1,"The vehicle had bad info and was possibly spawned in, it has been deleted."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["life_claim_done",true] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

//Is the vehicle currently being added to the gang shed??
if (_vehicle getVariable ["rekey",false]) exitWith {
	[1,"This vehicle is currently being added to your gang shed."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["life_claim_done",true] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

//The vehicle is now being added to the gang garage
_vehicle setVariable ["rekey",true,true];

//Lock the vehicle
[_vehicle,2] remoteExec ["OEC_fnc_lockVehicle",_vehicle,false];
uiSleep random(5);

//Can't add cop cars to the gang garage
if ((_vehicle getVariable ["side",""]) == "cop") exitWith {
	[1,"You cannnot claim law enforcement vehicles."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["life_claim_done",true] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

//Get the vehicle info
private _uid = _vInfo select 0;
private _plate = _vInfo select 1;
private _color = _vehicle getVariable["oev_veh_color",[0,0]];
_color = _color select 0;
_claimerUID = getPlayerUID _player;
_claimerName = name _player;

uiSleep random(5);
uiSleep random(5);

//Finished claiming the vehicle, alert the user
if (isNull _vehicle || !(alive _vehicle)) exitWith {
	["life_claim_done",true] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

//Get vehicle information
private _pos = getPos _vehicle;
private _dir = getDir _vehicle;

// 使用 vehicleMapper 获取车辆详情
private _vInformation = ["getdetailsbyplate", [_uid, str olympus_server, _plate]] call DB_fnc_vehicleMapper;
private _vid = _vInformation select 0;
deleteVehicle _vehicle;

// 使用 vehicleMapper 将车辆从所有者处移除
["deactivateandkill", [_uid, _plate]] call DB_fnc_vehicleMapper;

uiSleep 0.5;
[_uid,_vInformation select 1,_vInformation select 3,_vInformation select 2,_color,_vInformation select 4,_gangID,false,call compile (_vInformation select 5)] remoteExec ["OES_fnc_insertVehicle",2];
uiSleep 0.5;

["life_claim_success",true] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
["life_claim_done",true] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];

format ["-CLAIM- A %1 (%5) owned by %2 was stored in the gang garage of (ID): by %3(%4)",typeOf _vehicle,_uid,_claimerUID,_claimerName,_vehicle] call OES_fnc_diagLog;
