//	File: fn_vehicleDelete.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description:
//	Doesn't actually delete since we don't give our DB user that type of
//	access so instead we set it to alive=0 so it never shows again.
params [
	["_vid","",[""]],
	["_pid","",[""]],
	["_sp",2500,[0]],
	["_unit",objNull,[objNull]],
	["_type","",[""]]
];

private _check = (_pid find "'" != -1);
if (_check) exitWith {};
private _check = (_type find "'" != -1);
if (_check) exitWith {};

if(_vid isEqualTo "" || {_pid isEqualTo ""} || {_sp isEqualTo 0} || {isNull _unit} || {_type isEqualTo ""}) exitWith {};

[(format["UPDATE vehicles SET alive='0' WHERE pid='%1' AND id=%2",_pid,_vid]),1] call OES_fnc_asyncCall;