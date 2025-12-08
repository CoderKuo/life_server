//	File: fn_msgRequest.sqf
//	Author: Silex
//	Fills the Messagelist
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_uid","",[""]],
	["_player",objNull,[objNull]]
];

if(isNull _player) exitWith {};

// 使用 messageMapper 获取最近消息
private _queryResult = ["getrecent", [_uid, "10"]] call DB_fnc_messageMapper;
// 添加 nil 检查
if (isNil "_queryResult") exitWith {};
if (!(_queryResult isEqualType [])) exitWith {};
if (count _queryResult isEqualTo 0) exitWith {};

{
	[1,_x] remoteExec ["OEC_fnc_smartphone",(owner _player),false];
} forEach _queryResult;