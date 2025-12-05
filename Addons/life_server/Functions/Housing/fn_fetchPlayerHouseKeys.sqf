//	Author: Raykazi
//	Description:
//	Fetches all the houses that the player has keys to along with the owner's name.

private["_query","_houses"];
if(_this == "") exitWith {};

_query = format["select pid, pos, id, players.name FROM houses INNER JOIN players ON houses.pid = players.playerid WHERE `player_keys` LIKE '%1' AND server='%2'", "%"+_this+"%",olympus_server];
_houses = [_query,2,true] call OES_fnc_asyncCall;
_return = [];
_houseIDS = [];
{
	_pos = call compile format["%1",_x select 1];

	if((count (nearestObjects[_pos,["House_F"],10])) > 0) then {
		_return pushBack [_x select 1,_x select 3];
		_houseIDS pushBack (_x select 2);

	};
} forEach _houses;

missionNamespace setVariable[format["house_keys_%1",_this],_return];
missionNamespace setVariable[format["house_keys_IDS_%1",_this],_houseIDS];
