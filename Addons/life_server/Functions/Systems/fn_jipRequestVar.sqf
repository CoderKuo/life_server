// File: fn_jipRequestVar.sqf
// Author: codeYeTi
// Description: Allows a client to request a variable from server namespace
params [
	["_varName", "", [""]]
];

if (_varName == "") exitWith {};
if (isNil _varName) exitWith {};
if (!isRemoteExecuted) exitWith {};

if (getNumber (configFile >> "CfgJIPRequestVar" >> _varName) <= 0) exitWith {};

private _value = missionNamespace getVariable _varName;
[_varName, _value] remoteExecCall ["OEC_fnc_netSetVar", remoteExecutedOwner];