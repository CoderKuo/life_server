// File: fn_deletedVehStore.sqf
// Author: Astral
// Description: Replaces a vehicle in a players garage after it is deleted by an admin.

private["_plate","_uid","_vehicle","_vinfo","_vehGangID","_query"];

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

if !(_vehGangID isEqualTo 0) then {
	_query = format["UPDATE gangvehicles SET active='0', persistentServer='0' WHERE gang_id='%1' AND plate='%2'",_vehGangID,_plate];
} else {
	_query = format["UPDATE vehicles SET active='0', persistentServer='0' WHERE pid='%1' AND plate='%2'",_uid,_plate];
};

[_query,1] call OES_fnc_asyncCall;
deleteVehicle _vehicle;
