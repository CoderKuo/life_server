//	File: fn_updateVehOwnership.sqf
//	Author: TheCmdrRex
//	Description: Transfers ownership between vehicles
//	Modified: 迁移到 PostgreSQL Mapper 层

private["_vehID","_sender","_recipient","_senderID","_recipientID","_vehName","_queryResult"];

params [
	["_vehID","",[""]],
	["_sender",objNull,[objNull]],
	["_recipient",objNull,[objNull]],
	["_senderID","",[""]],
	["_recipientID","",[""]],
	["_vehName","",[""]]
];

//Stop bad data being passed.
if (_vehID == "" || _senderID == "" || _recipientID == "") exitWith {};
if (isNull _sender) exitWith {};
if (isNull _recipient) exitWith {};

// Check if sender actually owns vehicle
_queryResult = ["getbyplayer", [_senderID]] call DB_fnc_vehicleMapper;
if (isNil "_queryResult" || {count _queryResult == 0}) exitWith {};

// Check for max vehicles
_queryResult = ["countbyplayer", [_recipientID, "civ"]] call DB_fnc_vehicleMapper;
if (isNil "_queryResult" || {count _queryResult == 0}) exitWith {};

private _vehCount = if (_queryResult isEqualType [] && {count _queryResult > 0}) then { _queryResult select 0 } else { 0 };
private _vehMax = 0;
if (_recipient getVariable ["restrictions", false]) then {_vehMax = 15;} else {_vehMax = 75;};
if (_vehCount >= _vehMax) exitWith {
	[1,format["%1 does not have enough garage space for a %2",name _recipient,_vehName]] remoteExec ["OEC_fnc_broadcast",(owner _sender),false];
	[format['{"event":"Vehicle Transfer Failed ", "player":"%1", "player_id":"%2", "target":"%3", "target_id":"%4", "vehicle":"%5"}', name _sender, _senderID, name _recipient, _recipientID, _vehName]] call OES_fnc_logIt;
};

// Transfer Vehicle
["transfer", [_vehID, _recipientID]] call DB_fnc_vehicleMapper;
[1,format["%1 has transferred you a %2",name _sender,_vehName]] remoteExec ["OEC_fnc_broadcast",(owner _recipient),false];
