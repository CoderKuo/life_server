//	File: fn_insertVehicle.sqf
//	Author: Bryan "Tonic" Boardwine

//	Description:
//	Inserts the vehicle into the database

private["_uid","_side","_type","_className","_color","_plate","_query","_sql","_spawnInGarage"];

_uid = param [0,"",[""]];
_side = param [1,"",[""]];
_type = param [2,"",[""]];
_className = param [3,"",[""]];
_color = param [4,-2,[]];
_plate = param [5,-1,[0]];
_gangID = param [6,0,[0]];
_spawnInGarage = param [7,false,[false]];
_mods = param [8,[0,0,0,0,0,0,0,0],[[]]];

private _check = (_uid find "'" != -1);
if (_check) exitWith {};
private _check = (_side find "'" != -1);
if (_check) exitWith {};
private _check = (_type find "'" != -1);
if (_check) exitWith {};
private _check = (_className find "'" != -1);
if (_check) exitWith {};

if (_color isEqualType 0) then {_color = str _color};
//Stop bad data being passed.
if(_uid == "" || _side == "" || _type == "" || _className == "" || _color isEqualTo -2 || _plate == -1) exitWith {};
if !(_spawnInGarage) then {
	_query = format["INSERT INTO "+dbColumVehicle+" (side, classname, type, pid, alive, active, inventory, color, plate, insured, modifications) VALUES ('%1', '%2', '%3', '%4', '1','%5','""[]""', '""[%6,0]""', '%7', '0', '""%8""')",_side,_className,_type,_uid,olympus_server,parseText _color,_plate,_mods];
} else {
	_query = format["INSERT INTO "+dbColumVehicle+" (side, classname, type, pid, alive, active, inventory, color, plate, insured, modifications) VALUES ('%1', '%2', '%3', '%4', '1','0','""[]""', '""[%5,0]""', '%6', '0', '""%7""')",_side,_className,_type,_uid,parseText _color,_plate,_mods];
};

if !(_gangID isEqualTo 0) then {
	_query = format["INSERT INTO "+dbColumGangVehicle+" (side, classname, type, gang_id, alive, active, inventory, color, plate, insured, modifications) VALUES ('%1', '%2', '%3', '%4', '1','%5','""[]""', '""[%6,0]""', '%7', '0', '""%8""')",_side,_className,_type,_gangID,0,parseText _color,_plate,_mods];
};
[_query,1] call OES_fnc_asyncCall;
