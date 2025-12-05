//	File: fn_updateGangOil.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Gives the gang building the ability to have oil storage
params [
	["_building",objNull,[objNull]],
	["_player",objNull,[objNull]]
];

if (isNull _building || !(typeOf _building isEqualTo "Land_i_Shed_Ind_F") || isNull _player) exitWith {
	[1,"An error has occured. Try again later."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

if (_building getVariable ["oilstorage",false]) exitWith {
	[1,"Your gang building already has oil storage capability or an error has occured."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

private _gangID = _building getVariable ["bldg_gangid",-2];
private _gangName = _building getVariable ["bldg_gangName",""];
if (_gangID isEqualTo -2 || _gangName isEqualTo "") exitWith {
	[1,"An error has occured. Try again later."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

private _query = format["SELECT bank FROM gangs WHERE id='%1'",_gangID];
private _queryResult = (([_query,2] call OES_fnc_asyncCall) select 0);

if (_queryResult < 500000) exitWith {
	[1,"Purchase request denied. Your gang doesn't have the required gang funds to make the purchase!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

[2,_gangID,_player,-(500000)] call OES_fnc_gangBank;
_building setVariable ["oilstorage",true,true];

_query = format ["UPDATE gangbldgs SET oil='1' WHERE gang_id='%1' AND gang_name='%2' AND server='%3' AND owned='1'",_gangID,_gangName,olympus_server];
[_query,1] call OES_fnc_asyncCall;

[1,"Your gang building has been renovated!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];

format["Player %1(%2) purchased oil storage for the shed owned by %3(%4) on server %5",name _player,getPlayerUID _player,_gangName,_gangID,olympus_server] call OES_fnc_diagLog;

private _logHistory = format ["INSERT INTO gangbankhistory (name,playerid,type,amount,gangid) VALUES('%1','%2','7','%3','%4')",name _player,getPlayerUID _player,500000,_gangID];
[_logHistory,1] call OES_fnc_asyncCall;