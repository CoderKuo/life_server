//	File: fn_msgRequest.sqf
//	Author: Silex
//	Fills the Messagelist

params [
	["_uid","",[""]],
	["_player",objNull,[objNull]]
];

if(isNull _player) exitWith {};

private _queryResult = [format["SELECT fromID, toID, message, fromName, toName FROM messages WHERE toID='%1' ORDER BY time DESC LIMIT 10",_uid] , 2, true] call OES_fnc_asyncCall;
if(count _queryResult isEqualTo 0) exitWith {};

{
	[1,_x] remoteExec ["OEC_fnc_smartphone",(owner _player),false];
} forEach _queryResult;