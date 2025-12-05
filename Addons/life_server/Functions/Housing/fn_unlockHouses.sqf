//	File: fn_unlockHouses.sqf
//	Author: Jesse "tkcjesse" Schultz
//  Modified by: Fusah
//	Description: Unlocks player houses when they disconect.

params [
	["_uid","",[""]]
];
if (_uid isEqualTo "") exitWith {};

private _check = (_uid find "'" != -1);
if (_check) exitWith {};

private _query = format["SELECT pos FROM houses WHERE pid='%2' AND owned='1' AND server='%1' LIMIT 5",olympus_server,_uid];
private _queryResult = [_query,2,true] call OES_fnc_asyncCall;
if(count _queryResult isEqualTo 0) exitWith {};

{
	private _pos = call compile format["%1",_x select 0];
	if((count (nearestObjects[_pos,["House_F"],10])) > 0) then {
		_house = ((nearestObjects[_pos,["House_F"],10]) select 0);
		_numOfDoors = getNumber(configFile >> "CfgVehicles" >> (typeOf _house) >> "numberOfDoors");
		for "_i" from 1 to _numOfDoors do {
			_house setVariable[format["bis_disabled_Door_%1",_i],0,true];
			if ((_house getVariable [format["disabled_Door_%1",_i],0]) isEqualTo 1) then {
				_house setVariable[format["disabled_Door_%1",_i],0,true];
			};
		};
	};
} forEach _queryResult;
