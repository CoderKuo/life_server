//  File: fn_warGetData.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Gets Kills and Deaths for gang wars
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_mode",0,[0]],
	["_unit",objNull,[objNull]],
	["_gangID",0,[0]],
	["_gangIDTwo",0,[0]]
];
if (isNull _unit || _gangID isEqualTo 0 || _gangIDTwo isEqualTo 0) exitWith {};

switch (_mode) do {
	case 0: {
		// 使用 Mapper 获取战争状态
		_queryResult = ["getwarstatus", [str _gangID, str _gangIDTwo]] call DB_fnc_gangMapper;
		if ((count _queryResult) isEqualTo 0) exitWith {};

		["life_gang_warReady",true] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
		["life_gang_warData",(_queryResult select 0)] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
	};
	case 1: {};
};
