//	Author: Raykazi
//	Description: Fetches all the houses that the player has keys to along with the owner's name.
//  Modified: 迁移到 PostgreSQL Mapper 层

if(_this == "") exitWith {};

// 使用 Mapper 获取玩家钥匙房屋
private _houses = ["getbykeys", [_this, str olympus_server]] call DB_fnc_houseMapper;
if (isNil "_houses" || {!(_houses isEqualType [])}) then { _houses = []; };

_return = [];
_houseIDS = [];
{
	if (isNil "_x" || {!(_x isEqualType [])} || {count _x < 4}) then { continue; };
	_pos = call compile format["%1",_x select 1];

	if((count (nearestObjects[_pos,["House_F"],10])) > 0) then {
		_return pushBack [_x select 1,_x select 3];
		_houseIDS pushBack (_x select 2);

	};
} forEach _houses;

missionNamespace setVariable[format["house_keys_%1",_this],_return];
missionNamespace setVariable[format["house_keys_IDS_%1",_this],_houseIDS];
