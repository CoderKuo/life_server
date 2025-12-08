//  File: fn_initHouses.sqf
//	Author: Bryan "Tonic" Boardwine
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_queryResult","_keyPlayers","_storageCapacity","_trunk","_physicalTrunk","_physicalStorageCapacity"];

// 获取房屋总数
private _countResult = ["count", [str olympus_server]] call DB_fnc_houseMapper;
if (isNil "_countResult" || {count _countResult == 0} || {isNil {_countResult select 0}}) exitWith {
	"[initHouses] 无法获取房屋数量" call OES_fnc_diagLog;
};
private _count = _countResult select 0;
if (isNil "_count" || {_count isEqualType ""}) then { _count = parseNumber str _count; };
format["[initHouses] 房屋总数: %1", _count] call OES_fnc_diagLog;

for [{_x=0},{_x<=_count},{_x=_x+10}] do {
	// 使用 Mapper 获取所有房屋 (PostgreSQL 原生语法)
	_queryResult = ["getall", [_x, str olympus_server]] call DB_fnc_houseMapper;
	if (isNil "_queryResult" || {count _queryResult == 0}) exitWith {};

	{
		if (isNil "_x" || {!(_x isEqualType [])} || {count _x < 12}) then { continue; };
		_pos = call compile format["%1",_x select 2];
		_house = _pos nearestObject "House_F";

		if(!isNull _house) then {
			_house allowDamage false;

			_house setVariable["house_owner",[_x select 1,_x select 3],true];
			_house setVariable["house_id",_x select 0,true];
			_house setVariable["locked",true,true];
			_house setVariable["house_expire",(_x select 11),true];
			if ((_x select 7) isEqualTo 0) then {
				_house setVariable["for_sale","",true];
			} else {
				_house setVariable["for_sale",[_x select 1,_x select 7],true];
			};

			// 解析钥匙玩家数据 - 从 JSONB 返回 SQF 格式字符串
			private _keyPlayers = [_x select 4, []] call DB_fnc_parseJsonb;
			_house setVariable["keyPlayers",_keyPlayers,true];

			_storageCapacity = 100;
			_physicalStorageCapacity = 100;

			// 解析库存数据 - 从 JSONB 返回 SQF 格式字符串
			private _trunk = [_x select 5, [[], 0]] call DB_fnc_parseJsonb;
			private _physicalTrunk = [_x select 9, [[], 0]] call DB_fnc_parseJsonb;

			_storageCapacity = _x select 6;
			_physicalStorageCapacity = _x select 10;
			_house setVariable["Trunk",_trunk,true];
			_house setVariable["PhysicalTrunk",_physicalTrunk,true];

			_house setVariable["storageCapacity",_storageCapacity,true];
			_house setVariable["physicalStorageCapacity",_physicalStorageCapacity,true];

			if ((_x select 8) isEqualTo 1) then {
				_house setVariable ["oilstorage",true,true];
			};

			if ((_x select 11) <= 5) then {
				format ["-HOUSEEXPIRE- House id %1 owned by %2 will expire in %3 days.",(_x select 0),(_x select 1),(_x select 11)] call A3LOG_fnc_log;
			};
		};
	} forEach _queryResult;
};
