//	File: fn_newPlayerVeh.sqf
//	Author: TheCmdrRex
//	Desciption: Gives a new player a free offroad upon entering the server if they don't already have one.

params [
	["_player",objNull,[objNull]]
];

private ["_player","_plate","_playerID","_query","_queryResult"];
// Checks for protection
if (isNull _player) exitWith {};
if !(side _player isEqualTo civilian) exitWith {};

_playerID = getPlayerUID _player;

// Check if player has an existing vehicle
_query = format["SELECT COUNT(id) FROM "+dbColumVehicle+" WHERE pid='%1' AND side='%2'",_playerID,"civ"];
_queryResult = [_query,2,false] call OES_fnc_asyncCall;
if !((_queryResult select 0) > 0) then {
	_plate = round(floor(random(999999)));
	[_playerID,"civ","Car","C_Offroad_01_F",-1,_plate,0,true] call OES_fnc_insertVehicle;
	[1,format["你因为没有车辆和不熟悉服务器而获得了免费越野！"]] remoteExec ["OEC_fnc_broadcast",_player,false];
	[format['{"事件":"越野新手", "玩家":"%1", "player_id":"%2"}',name player, _playerID]] call OES_fnc_logIt;
};