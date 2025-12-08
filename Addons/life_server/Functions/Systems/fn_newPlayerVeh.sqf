//	File: fn_newPlayerVeh.sqf
//	Author: TheCmdrRex
//	Desciption: Gives a new player a free offroad upon entering the server if they don't already have one.
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_player",objNull,[objNull]]
];

private ["_player","_plate","_playerID","_queryResult"];
// Checks for protection
if (isNull _player) exitWith {};
if !(side _player isEqualTo civilian) exitWith {};

_playerID = getPlayerUID _player;

// 使用 vehicleMapper 检查玩家是否有车辆
_queryResult = ["countbyplayer", [_playerID, "civ"]] call DB_fnc_vehicleMapper;
if !((_queryResult select 0) > 0) then {
	_plate = round(floor(random(999999)));
	[_playerID,"civ","Car","C_Offroad_01_F",-1,_plate,0,true] call OES_fnc_insertVehicle;
	[1,format["你因为没有车辆和不熟悉服务器而获得了免费越野！"]] remoteExec ["OEC_fnc_broadcast",_player,false];
	[format['{"事件":"越野新手", "玩家":"%1", "player_id":"%2"}',name player, _playerID]] call OES_fnc_logIt;
};