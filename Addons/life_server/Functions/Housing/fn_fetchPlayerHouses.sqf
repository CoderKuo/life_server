//	Author: Bryan "Tonic" Boardwine
//	Description: Fetches all the players houses and sets them up.
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_keyPlayers"];
if(_this == "") exitWith {};

// 使用 Mapper 获取玩家房屋
private _houses = ["getbyplayer", [_this, str olympus_server, 5]] call DB_fnc_houseMapper;
if (isNil "_houses" || {!(_houses isEqualType [])}) then { _houses = []; };

_return = [];
_houseIDS = [];
{
	if (isNil "_x" || {!(_x isEqualType [])} || {count _x < 3}) then { continue; };
	_pos = call compile format["%1",_x select 1];

	if((count (nearestObjects[_pos,["House_F"],10])) > 0) then {
		_house = ((nearestObjects[_pos,["House_F"],10]) select 0);

		_house setVariable["slots",[],true];

		_return pushBack [_x select 1,[]];
		_houseIDS pushBack (_x select 2);

		_numOfDoors = getNumber(configFile >> "CfgVehicles" >> (typeOf _house) >> "numberOfDoors");
		for "_i" from 1 to _numOfDoors do {
				_house setVariable[format["bis_disabled_Door_%1",_i],1,true];
		};
	};
} forEach _houses;

missionNamespace setVariable[format["houses_%1",_this],_return];
missionNamespace setVariable[format["houseIDS_%1",_this],_houseIDS];

{
	_pos = call compile format["%1",_x select 1];

	if((count (nearestObjects[_pos,["House_F"],10])) > 0) then {
		_house = ((nearestObjects[_pos,["House_F"],10]) select 0);
		if (oev_conquestData select 0 && {getPos _house inPolygon (oev_conquestData select 1 select 1)}) then {
		_numOfDoors = getNumber(configFile >> "CfgVehicles" >> (typeOf _house) >> "numberOfDoors");
		for "_i" from 1 to _numOfDoors do {
				_house setVariable[format["bis_disabled_Door_%1",_i],0,true];
			};
		};
	};
} forEach _houses;
