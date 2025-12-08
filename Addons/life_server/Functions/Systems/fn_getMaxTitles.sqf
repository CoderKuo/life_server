//	File: fn_getMaxTitles.sqf
//	Author: Kurt
//	Description: Get the PIDs of players with max of a certain stat.
//  Modified: 迁移到 PostgreSQL Mapper 层

// 等待数据库函数加载完成
"[getMaxTitles] Waiting for database functions..." call OES_fnc_diagLog;
waitUntil {uiSleep 0.1; !isNil "DB_fnc_dbExecute" && !isNil "DB_fnc_miscMapper"};
format["[getMaxTitles] DB functions loaded. dbExecute=%1, miscMapper=%2", !isNil "DB_fnc_dbExecute", !isNil "DB_fnc_miscMapper"] call OES_fnc_diagLog;

"[getMaxTitles] Starting query..." call OES_fnc_diagLog;

// 使用 miscMapper 调用存储过程获取最大值
private _query = ["callselectmax", []] call DB_fnc_miscMapper;

// 确保 _query 有效
if (isNil "_query") then { _query = []; };
format ["[getMaxTitles] Raw query result: %1 (type: %2)", _query, typeName _query] call OES_fnc_diagLog;

private _queryResult = [];
if (_query isEqualType [] && {count _query > 0}) then {
	_queryResult = _query;
} else {
	if (_query isEqualType "" && {_query != ""}) then {
		_queryResult = call compile _query;
		if (isNil "_queryResult") then { _queryResult = []; };
	};
};
if (!(_queryResult isEqualType [])) then { _queryResult = []; };

//Assemble a new array
private _pidList = [];
{
	if (!isNil "_x" && {_x isEqualType []} && {count _x > 0}) then {
		_pidList pushBack (_x select 0);
	};
} forEach _queryResult;

oev_title_pid = _pidList;
// 0 - PID of most warpoints, 1 - PID of highest bank balance, 2 - PID of most cop kills, 3 - PID of most vigilante arrests, 4 - PID of the fastest time at the gokart pit
publicVariable "oev_title_pid";
