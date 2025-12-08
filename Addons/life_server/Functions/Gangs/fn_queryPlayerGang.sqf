//	Author: Bryan "Tonic" Boardwine
//	Description: Queries to see if the player belongs to any gang.
//  Modified: 迁移到 PostgreSQL Mapper 层

private _check = (_this find "'" != -1);
if (_check) exitWith {};

// 使用 Mapper 获取玩家帮派信息
private _queryResult = ["getplayergang", [_this]] call DB_fnc_gangMapper;
if (isNil "_queryResult" || {!(_queryResult isEqualType [])} || {count _queryResult == 0}) exitWith {
	missionNamespace setVariable[format["gang_%1",_this], []];
};

// 获取帮派建筑位置
private _gangId = _queryResult select 0;
if (isNil "_gangId") exitWith {
	missionNamespace setVariable[format["gang_%1",_this], _queryResult];
};

private _newQuery = ["getbuildingpositions", [str _gangId, str olympus_server]] call DB_fnc_gangMapper;
if (!isNil "_newQuery" && {_newQuery isEqualType []} && {count _newQuery > 0}) then {
	private _posData = _newQuery select 0;
	if (!isNil "_posData" && {_posData isEqualType ""}) then {
		_queryResult pushBack (call compile _posData);
	} else {
		_queryResult pushBack [];
	};
} else {
	_queryResult pushBack [];
};
missionNamespace setVariable[format["gang_%1",_this],_queryResult];
