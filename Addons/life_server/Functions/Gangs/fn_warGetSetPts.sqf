//File: fn_warGetSetPts.sqf
//Author: Jesse "tkcjesse" Schultz
//Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_mode",-1,[0]],
	["_value",0,[0]],
	["_player",objNull,[objNull]]
];

if (isNull _player) exitWith {};
if (_mode isEqualTo -1) exitWith {};
private ["_uid","_queryResult"];

_uid = getPlayerUID _player;

switch (_mode) do {
	case 0: {
		// 使用 playerMapper 获取战争点数
		_queryResult = ["getwarpts", [_uid]] call DB_fnc_playerMapper;

		["oev_warpts_count",(_queryResult select 0)] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	};

	case 1: {
		// 使用 playerMapper 扣除战争点数
		["deductwarpts", [_uid, str _value]] call DB_fnc_playerMapper;
	};

	default {};
};
