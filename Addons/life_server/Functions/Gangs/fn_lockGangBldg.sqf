//	File: fn_lockGangBldg.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Locks out a gang building due to not enough members.

params [
	["_gangID",-2,[0]],
	["_gangName","",[""]]
];
if (_gangID < 0 || _gangName isEqualTo "") exitWith {};

private _check = (_gangName find "'" != -1);
if (_check) exitWith {};

private _query = format  ["SELECT id, pos, classname, gang_name FROM gangbldgs WHERE gang_id='%1' AND gang_name='%2' AND owned='1' AND server='%3'",_gangID,_gangName,olympus_server];
private _queryResult = [_query,2,true] call OES_fnc_asyncCall;
if (count _queryResult isEqualTo 0) exitWith {};

private _pos = call compile format ["%1",_queryResult select 2];
private _building = _pos nearestObject "House_F";
if !(typeOf _building isEqualTo (_queryResult select 3)) exitWith {};
if !(_building getVariable ["bldg_gangName",""] isEqualTo (_queryResult select 4)) exitWith {};
