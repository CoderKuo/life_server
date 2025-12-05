//	Author: Bryan "Tonic" Boardwine
//	Description: Inserts the gang into the database.

private["_query","_queryResult","_group","_gangID"];
params [
	["_owner",objNull,[objNull]],
	["_uid","",[""]],
	["_gangName","",[""]]
];
_group = group _owner;

if(isNull _owner || _uid isEqualTo "" || _gangName isEqualTo "") exitWith {}; //Fail

private _check = (_uid find "'" != -1);
if (_check) exitWith {};
private _check = (_gangName find "'" != -1);
if (_check) exitWith {};

_gangName = [_gangName] call OES_fnc_mresString;

_query = format["SELECT id FROM gangs WHERE name='%1' AND active='1'",_gangName];
_queryResult = [_query,2] call OES_fnc_asyncCall;

//Check to see if the gang name already exists.
if !(count _queryResult isEqualTo 0) exitWith {
	[4,"There is already a gang created with that name please pick another name."] remoteExec ["OEC_fnc_broadcast",(owner _owner),false];
};

//Check to see if a gang with that name already exists but is inactive.
_query = format["SELECT id, active FROM gangs WHERE name='%1' AND active='0'",_gangName];
_queryResult = [_query,2] call OES_fnc_asyncCall;

if !(count _queryResult isEqualTo 0) then {
	_query = format["UPDATE gangs SET active='1' WHERE id='%1'",(_queryResult select 0)];
} else {
	_query = format["INSERT INTO gangs (name) VALUES('%1')",_gangName];
};

_queryResult = [_query,1] call OES_fnc_asyncCall;
_group setVariable["gang_name",_gangName,true];

uiSleep 0.35;
_query = format["SELECT id FROM gangs WHERE name='%1' AND active='1'",_gangName];
_queryResult = [_query,2] call OES_fnc_asyncCall;
_gangID = (_queryResult select 0);
_group setVariable["gang_id",_gangID,true];

["oev_gang_data",[(_queryResult select 0),_gangName,5]] remoteExec ["OEC_fnc_netSetVar",(owner _owner),false];

_query = format["SELECT id FROM gangmembers WHERE playerid='%1'",(getPlayerUID _owner)];

_queryResult = [_query,2] call OES_fnc_asyncCall;

if !(count _queryResult isEqualTo 0) then {
	_query = format["UPDATE gangmembers SET name='%1', gangname='%2', gangid='%3', rank='%4' WHERE id='%5'",_owner getVariable["realname",name _owner],_gangName,_gangID,5,(_queryResult select 0)];
} else {
	_query = format["INSERT INTO gangmembers (playerid,name,gangname,gangid,rank) VALUES('%1','%2','%3','%4','%5')",(getPlayerUID _owner),_owner getVariable["realname",name _owner],_gangName,_gangID,5];
};

[_query,1] call OES_fnc_asyncCall;

[_group] remoteExec ["OEC_fnc_gangCreated",(owner _owner),false];