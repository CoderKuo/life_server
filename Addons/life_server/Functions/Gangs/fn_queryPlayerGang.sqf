//	Author: Bryan "Tonic" Boardwine
//	Description:
//	Queries to see if the player belongs to any gang.

private _check = (_this find "'" != -1);
if (_check) exitWith {};

private _query = format ["SELECT gangid, gangname, rank FROM gangmembers WHERE playerid='%1'",_this];
private _queryResult = [_query,2] call OES_fnc_asyncCall;

_query = format ["SELECT pos FROM gangbldgs WHERE gang_id='%1' AND server='%2' AND owned='1'",(_queryResult select 0),olympus_server];
private _newQuery = [_query,2] call OES_fnc_asyncCall;

_queryResult pushBack (call compile (_newQuery select 0));
missionNamespace setVariable[format["gang_%1",_this],_queryResult];