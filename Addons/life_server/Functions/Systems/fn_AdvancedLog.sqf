// fn_AdvancedLog.sqf
// Author: dakuo
// Modified: 迁移到 PostgreSQL Mapper 层

params[
	["_player",objNull,[objNull]],
	["_action","",[""]],
	["_actionValue","",[""]],
	["_actionId",0,[0]],
	["_instanceId",1,[0]]
];

// 使用 miscMapper 记录操作日志
// 参数: [playerid, playername, action, action_detail, actionid, instanceid]
["addactionlog", [getPlayerUID _player, name _player, _action, _actionValue, str _actionId, str _instanceId]] call DB_fnc_miscMapper;
