//	File: fn_warRemoveGang.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Sets an active war to be inactive to prepare for deletion.
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_gangID",0,[0]],
	["_endID",0,[0]]
];

if (_gangID isEqualTo 0 || _endID isEqualTo 0) exitWith {};

// 使用 Mapper 结束战争
["endwar", [str _gangID, str _endID]] call DB_fnc_gangMapper;
