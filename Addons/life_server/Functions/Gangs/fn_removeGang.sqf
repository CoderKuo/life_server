//	Author: Bryan "Tonic" Boardwine
//	File: fn_removeGang
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_onlineMembers",[],[[]]],
	["_groupID",0,[0]]
];

if(count _onlineMembers isEqualTo 0 || _groupID isEqualTo 0) exitWith {};

// 使用 Mapper 停用帮派
["deactivategang", [str _groupID]] call DB_fnc_gangMapper;

// 移除所有成员
["removeallmembers", [str _groupID]] call DB_fnc_gangMapper;

// 检查帮派是否仍然活动
_result = ["checkgangactive", [str _groupID]] call DB_fnc_gangMapper;

[_groupID] remoteExec ["OEC_fnc_gang1Disbanded",_onlineMembers,false];
