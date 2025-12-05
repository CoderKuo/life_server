//	File: fn_updateVehOwnership.sqf
//	Author: TheCmdrRex
//	Description: Transfers ownership between vehicles

private["_vehID","_sender","_recipient","_senderID","_recipientID","_vehName","_query","_queryResult"];

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
_query = format["SELECT CONVERT(id, char) FROM "+dbColumVehicle+" WHERE pid='%1'", _senderID];
_queryResult = [_query,2] call OES_fnc_asyncCall;
if ((count _queryResult) isEqualTo 0) exitWith {};
// Check for max vehicles
_query = format["SELECT COUNT(id) FROM "+dbColumVehicle+" WHERE pid='%1' AND alive='1' AND side='%2'",_recipientID, "civ"];
_queryResult = [_query,2,false] call OES_fnc_asyncCall;
if ((count _queryResult) isEqualTo 0) exitWith {};
private _vehMax = 0;
if (_recipient getVariable ["restrictions", false]) then {_vehMax = 15;} else {_vehMax = 75;};
if ((_queryResult select 0) >= _vehMax) exitWith {
	[1,format["%1 does not have enough garage space for a %2",name _recipient,_vehName]] remoteExec ["OEC_fnc_broadcast",(owner _sender),false];
	[format['{"event":"Vehicle Transfer Failed ", "player":"%1", "player_id":"%2", "target":"%3", "target_id":"%4", "vehicle":"%5"}', name _sender, _senderID, name _recipient, _recipientID, _vehName]] call OES_fnc_logIt;
};

// Transfer Vehicle
_query = format["UPDATE "+dbColumVehicle+" SET pid='%1', color='""[-1,0]""' WHERE id=%2", _recipientID, _vehID];
_queryResult = [_query,1] call OES_fnc_asyncCall;
if (_queryResult) then {
	[1,format["%1 has transferred you a %2",name _sender,_vehName]] remoteExec ["OEC_fnc_broadcast",(owner _recipient),false];
};