//	File: fn_gangBHistory.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Pulls relevant gang bank data from the table and passes back to player for Display 100300
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_gangID",-1,[0]],
	["_unit",objNull,[objNull]]
];
if (_gangID isEqualTo -1 || isNull _unit) exitWith {};

// 使用 Mapper 获取银行历史
private _queryResult = ["getbankhistory", [str _gangID]] call DB_fnc_gangMapper;

["oev_gangHistory_Ready",true] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
["oev_gangBank_History",_queryResult] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
