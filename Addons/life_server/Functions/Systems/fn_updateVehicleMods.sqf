//	File: fn_updateVehicleMods.sqf
//	Author: Poseidon
//	Description: updates the vehicles mods

private["_vehicle","_insured","_color","_uid","_plate","_dbInfo","_mods","_query","_sql","_gangID"];
_vehicle = param [0,objNull,[objNull]];
_insured = param [1,0,[0]];
_color = param [2,["Default",0],[[]]];
_mods = param [3,[0,0,0,0,0,0,0,0],[[]]];

//Error checks
if(isNull _vehicle) exitWith {};

_dbInfo = _vehicle getVariable["dbInfo",[]];
if(count _dbInfo == 0) exitWith {};

_insured = [_insured] call OES_fnc_numberSafe;

_color = (str _color) splitString '""';
_color = _color joinString "";

//_color = [_color] call OES_fnc_mresArray;
_mods = [_mods] call OES_fnc_mresArray;
_gangID = _vehicle getVariable ["gangID",0];

_uid = _dbInfo select 0;
_plate = _dbInfo select 1;
_query = format["UPDATE "+dbColumVehicle+" SET insured='%1', modifications='%2', color='%3' WHERE pid='%4' AND plate='%5'",_insured,_mods,str _color,_uid,_plate];
if !(_gangID IsEqualTo 0) then {
	_query = format["UPDATE "+dbColumGangVehicle+" SET insured='%1', modifications='%2', color='%3' WHERE gang_id='%4' AND plate='%5'",_insured,_mods,str _color,_gangID,_plate];
};
_sql = [_query,1] call OES_fnc_asyncCall;
