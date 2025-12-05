//	File: fn_vehicleDead.sqf
//	Description:
//	Tells the database that this vehicle has died and can't be recovered.

private["_vehicle","_plate","_uid","_query","_dbInfo","_isInsured","_color","_gangID"];
_vehicle = param [0,ObjNull,[ObjNull]];
if(isNull _vehicle) exitWith {}; //NULL
private _handle = [_vehicle] spawn OES_fnc_pulloutDead;
waitUntil {uiSleep 0.5; scriptDone _handle;};
if (typeOf _vehicle in ["O_Truck_03_repair_F","O_Truck_03_ammo_F","B_Truck_01_ammo_F","O_LSV_02_armed_F","B_T_Truck_01_transport_F"]) exitWith {
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

switch (_isInsured) do {
	case 0: {
		if (_gangID isEqualTo 0) then {
			_query = format["UPDATE "+dbColumVehicle+" SET alive='0' WHERE pid='%1' AND plate='%2'",_uid,_plate];
		} else {
			_query = format["UPDATE "+dbColumGangVehicle+" SET alive='0' WHERE gang_id='%1' AND plate='%2'",_gangID,_plate];
		};
	};
	case 1: {
		_mods set [0,0];
		_mods set [1,0];
		_mods set [2,0];
		if (_gangID isEqualTo 0) then {
			_query = format["UPDATE "+dbColumVehicle+" SET active='0', insured='0', modifications='""%4""', inventory='""[]""', color='""[%3,0]""', persistentServer='0' WHERE pid='%1' AND plate='%2'",_uid,_plate,parseText _color,_mods];
		} else {
			_query = format["UPDATE "+dbColumGangVehicle+" SET active='0', insured='0', modifications='""%4""', inventory='""[]""', color='""[%3,0]""', persistentServer='0' WHERE gang_id='%1' AND plate='%2'",_gangID,_plate,_color,_mods];
		};
	};
	case 2: {
		if (_gangID isEqualTo 0) then {
			_query = format["UPDATE "+dbColumVehicle+" SET active='0', insured='0', inventory='""[]""', persistentServer='0' WHERE pid='%1' AND plate='%2'",_uid,_plate];
		} else {
			_query = format["UPDATE "+dbColumGangVehicle+" SET active='0', insured='0', inventory='""[]""', persistentServer='0' WHERE gang_id='%1' AND plate='%2'",_gangID,_plate];
		};
	};
};

[_query,1] call OES_fnc_asyncCall;
if(!isNil "_vehicle" && {!isNull _vehicle}) then {
	deleteVehicle _vehicle;
};
