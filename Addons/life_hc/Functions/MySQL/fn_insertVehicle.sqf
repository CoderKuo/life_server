//	File: fn_insertVehicle.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description:
//	Inserts the vehicle into the database

private ["_query"];
params [
	["_uid", "", [""]],
	["_side", "", [""]],
	["_type", "", [""]],
	["_className", "", [""]],
	["_color", -2, [0]],
	["_plate", -1, [0]],
	["_gangID", 0, [0]],
	["_spawnInGarage", false, [false]]
];

if (_uid find "'" != -1) exitWith {};
if (_side find "'" != -1) exitWith {};
if (_type find "'" != -1) exitWith {};
if (_className find "'" != -1) exitWith {};

//Stop bad data being passed.
if(_uid == "" || _side == "" || _type == "" || _className == "" || _color == -2 || _plate == -1) exitWith {};
if !(_spawnInGarage) then {
	_query = format["INSERT INTO "+dbColumVehicle+" (side, classname, type, pid, alive, active, inventory, color, plate, insured, modifications) VALUES ('%1', '%2', '%3', '%4', '1','%5','""[]""', '""[%6,0]""', '%7', '0', '""[0,0,0,0,0,0,0,0]""')",_side,_className,_type,_uid,olympus_server,_color,_plate];
} else {
	_query = format["INSERT INTO "+dbColumVehicle+" (side, classname, type, pid, alive, active, inventory, color, plate, insured, modifications) VALUES ('%1', '%2', '%3', '%4', '1','0','""[]""', '""[%5,0]""', '%6', '0', '""[0,0,0,0,0,0,0,0]""')",_side,_className,_type,_uid,_color,_plate];
};

if !(_gangID isEqualTo 0) then {
	_query = format["INSERT INTO "+dbColumGangVehicle+" (side, classname, type, gang_id, alive, active, inventory, color, plate, insured, modifications) VALUES ('%1', '%2', '%3', '%4', '1','%5','""[]""', '""[%6,0]""', '%7', '0', '""[0,0,0,0,0,0,0,0]""')",_side,_className,_type,_gangID,0,_color,_plate];
};
[_query,1] call HC_fnc_asyncCall;
