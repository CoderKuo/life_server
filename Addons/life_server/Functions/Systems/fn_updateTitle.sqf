//	Original Author: Kurt
//	File: fn_updateTitle.sqf
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_title","",[""]],
	["_uid","",[""]]
];

private _check = (_title find "'" != -1);
if (_check) exitWith {};
private _check = (_uid find "'" != -1);
if (_check) exitWith {};

// 使用 playerMapper 更新标题
["updatetitle", [_title, _uid]] spawn DB_fnc_playerMapper;
