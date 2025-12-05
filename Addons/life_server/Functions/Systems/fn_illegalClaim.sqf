//	File: fn_illegalClaim.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Switches vehicle owner in DB

params [
	["_vehicle",objNull,[objNull]],
	["_player",objNull,[objNull]],
	["_skins",[],[[]]],
	["_donorLevel",0,[0]]
];

if (isNull _vehicle || isNull _player || !(alive _vehicle)) exitWith {
	"-CLAIM- A vehicle failed to claim." call OES_fnc_diagLog;
};

private _vInfo = _vehicle getVariable ["dbInfo",[]];
if (count _vInfo isEqualTo 0) exitWith {
	format ["-CLAIM- A %1 was attempted to be claimed but was deleted by the server for improper info.",getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")] call OES_fnc_diagLog;
	deleteVehicle _vehicle;
	[[1,"The vehicle had bad info and was possibly spawned in, it has been deleted."],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
	[["life_claim_done",true],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};

if (_vehicle getVariable ["rekey",false]) exitWith {
	[[1,"This vehicle is currently being claimed."],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
	[["life_claim_done",true],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};

_vehicle setVariable ["rekey",true,true];
[[_vehicle,2],"OEC_fnc_lockVehicle",_vehicle,false] spawn OEC_fnc_MP;
uiSleep random(5);

private _uid = _vInfo select 0;
private _plate = _vInfo select 1;
_claimerUID = getPlayerUID _player;
_claimerName = name _player;

uiSleep random(5);
uiSleep random(5);

if (isNull _vehicle || !(alive _vehicle) || !(alive _player)) exitWith {
	[["life_claim_done",true],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};

private _pos = getPos _vehicle;
private _dir = getDir _vehicle;
private _gangID = _vehicle getVariable ["gangID",0];
private _query = format ["SELECT CONVERT(id, char) FROM %1 WHERE pid='%2' AND active='%3'",dbColumVehicle,_uid,olympus_server];
if !(_gangID isEqualTo 0) then {
	_query = format ["SELECT CONVERT(id, char), side, classname, type, plate FROM gangvehicles WHERE gang_id='%1' AND active='%2' AND plate='%3'",_gangID,olympus_server,_plate];
};
private _vInformation = [_query,2] call OES_fnc_asyncCall;
private _vid = (_vInformation select 0);

//Prevent non donors claiming donor skins
private _color = (_vehicle getVariable ["oev_veh_color",["Default",0]]) select 0;
if !(_color isEqualTo "-1") then {
	_currentSkin = -1;
	{if ((_x select 0) isEqualTo _color) exitWith {_currentSkin = _forEachIndex}}forEach _skins; // Get color index

	if !(_currentSkin isEqualTo -1) then {
		_color = _skins select _currentSkin select 0;
	} else {
		private _index = floor(random(count _skins));
		_color = _skins select _index select 0;
	}
};

if ((_vehicle getVariable ["side",""]) == "cop") then {
	switch(typeOf _vehicle) do {
		case "C_Hatchback_01_sport_F": {_color = "APDVandal"};
	};
};
if (_color isEqualType 0) then {_color = str _color};
deleteVehicle _vehicle;

_query = format ["UPDATE %1 SET active='0', persistentServer='0', pid='%2', color='""[%5,0]""', side='civ' WHERE pid='%3' AND plate='%4'",dbColumVehicle,_claimerUID,_uid,_plate,parseText _color];
if !(_gangID isEqualTo 0) then {
	//Kill the vehicle in the gang's garage
	_query = format ["UPDATE gangvehicles SET active='0', persistentServer='0', alive='0' WHERE gang_id='%1' AND plate='%2'",_gangID,_plate];
	[_query,1] call OES_fnc_asyncCall;
	uiSleep 0.5;
	//Add the vehicle to the claimer's garage
	_query = format["INSERT INTO "+dbColumVehicle+" (side, classname, type, pid, alive, active, inventory, color, plate, insured, modifications) VALUES ('%1', '%2', '%3', '%4', '1','%5','""[]""', '""[%6,0]""', '%7', '0', '""[0,0,0,0,0,0,0,0]""')",_vInformation select 1,_vInformation select 2,_vInformation select 3,_claimerUID,0,parseText _color,_vInformation select 4];
	[_query,1] call OES_fnc_asyncCall;
	uiSleep 0.5;
	//Get the new vid from the vehicle database
	_query = format ["SELECT CONVERT(id, char) FROM %1 WHERE pid='%2' AND active='%3' AND alive='1' AND plate='%4'",dbColumVehicle,_claimerUID,0,_vInformation select 4];
	uiSleep 1;
	_vid = ([_query,2] call OES_fnc_asyncCall) select 0;
} else {
	[_query,1] call OES_fnc_asyncCall;
};

uiSleep 2;
[[_vid,_claimerUID,_pos,_player,0,_dir],"OES_fnc_spaw1nVehicle",false,false] spawn OEC_fnc_MP;
[["life_claim_success",true],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
[["life_claim_done",true],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;

if !(_gangID isEqualTo 0) then {
	format ["-CLAIM- A %1 (%5) owned by %2(%6) was claimed by %3(%4)",typeOf _vehicle,_gangID,_claimerUID,_claimerName,_vehicle,_vehicle getVariable ["gangName","Error: No Gang Name"]] call OES_fnc_diagLog;
} else {
	format ["-CLAIM- A %1 (%5) owned by %2 was claimed by %3(%4)",typeOf _vehicle,_uid,_claimerUID,_claimerName,_vehicle] call OES_fnc_diagLog;
};
