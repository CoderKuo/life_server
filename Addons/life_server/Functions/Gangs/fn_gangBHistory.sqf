//	File: fn_gangBHistory.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Pulls relevant gang bank data from the table and passes back to player for Display 100300

params [
	["_gangID",-1,[0]],
	["_unit",objNull,[objNull]]
];
if (_gangID isEqualTo -1 || isNull _unit) exitWith {};

private _query = format ["SELECT name, playerid, type, amount FROM gangbankhistory WHERE gangid='%1' ORDER BY timestamp DESC LIMIT 20",_gangID];
private _queryResult = [_query,2,true] call OES_fnc_asyncCall;

["oev_gangHistory_Ready",true] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
["oev_gangBank_History",_queryResult] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];