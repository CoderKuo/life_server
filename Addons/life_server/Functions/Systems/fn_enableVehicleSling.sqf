// File: fn_enableVehicleSling.sqf
// Description: Gets owner of the car, calls the function.

params [["_vehicle",objNull,[objNull]]];

if(isNull _vehicle) exitWith {};

_vehicle enableRopeAttach true;