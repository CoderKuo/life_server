//	File: fn_realtorCash.sqf
//	Author: TheCmdrRex
//	Description: Queries server for realtor_cash and returns cash value
//  Modified: 迁移到 PostgreSQL Mapper 层

private ["_queryResult","_player","_foundCash","_mode"];

params [
	["_player",objNull,[objNull]],
	["_mode",-1,[0]]
];

if (isNull _player) exitWith {};
if (!isPlayer _player) exitWith {};

// 使用 Mapper 获取房产经纪人现金
_queryResult = ["getrealtorcash", [getPlayerUID _player]] call DB_fnc_playerMapper;

if ((count _queryResult) isEqualTo 0) then {
	_foundCash = -2;
} else {
	_foundCash = (_queryResult select 0);
};

if (_mode != 2) then {
	if (_foundCash > 0) then {
		// 重置房产经纪人现金
		["updaterealtorcash", [getPlayerUID _player, 0, "reset"]] call DB_fnc_playerMapper;
	};
	[nil,nil,nil,[_foundCash,1]] remoteExec ["OEC_fnc_checkRealtor",remoteExecutedOwner];
} else {
	[nil,nil,nil,[_foundCash,2]] remoteExec ["OEC_fnc_checkRealtor",remoteExecutedOwner];
};
