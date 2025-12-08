//	File: fn_initGangBldgs.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Initalizes the gangbldgs
//  Modified: 迁移到 PostgreSQL Mapper 层

// 使用 Mapper 获取建筑数量
private _countResult = ["countbuildings", [str olympus_server]] call DB_fnc_gangMapper;
if (isNil "_countResult" || {count _countResult == 0} || {isNil {_countResult select 0}}) exitWith {
	"[initGangBldgs] 无法获取帮派建筑数量" call OES_fnc_diagLog;
};
private _count = _countResult select 0;
if (isNil "_count" || {_count isEqualType ""}) then { _count = parseNumber str _count; };
format["[initGangBldgs] 帮派建筑总数: %1", _count] call OES_fnc_diagLog;

for [{_x=0},{_x<=_count},{_x=_x+10}] do {
	// 使用 Mapper 获取建筑列表
	private _queryResult = ["getallbuildings", [str olympus_server, _x]] call DB_fnc_gangMapper;
	if (isNil "_queryResult" || {count _queryResult == 0}) exitWith {};

	{
		if (isNil "_x" || {count _x < 15}) then { continue; };
		// 使用 Mapper 计算租期
		private _rentResult = ["getdaysuntilrent", [str (_x select 10), (_x select 11)]] call DB_fnc_gangMapper;
		private _queryResultT = if (isNil "_rentResult" || {count _rentResult == 0}) then { 0 } else { _rentResult select 0 };
		// 使用 Mapper 统计成员数量
		private _memberResult = ["countmembers", [str (_x select 6), (_x select 7)]] call DB_fnc_gangMapper;
		private _countResult = if (isNil "_memberResult" || {count _memberResult == 0}) then { 0 } else { _memberResult select 0 };
		private _pos = call compile format ["%1",_x select 3];
		private _building = _pos nearestObject "House_F";
		if !(typeOf _building isEqualTo (_x select 2)) exitWith {};

		if !(isNull _building) then {
			if (_building getVariable ["restricted_shed",false]) exitWith {
				format["GANG BLDG ERROR: Shed had the restricted shed variable and wasnt setup! id: %1  bldgGang: %2  bldgOwner: %3",(_x select 0),(_x select 7),(_x select 1)] call OES_fnc_diagLog;
			};
			_building setVariable ["bldg_id",(_x select 0),true];
			_building setVariable ["bldg_owner",(_x select 1),true];
			_building setVariable ["bldg_gangid",(_x select 6),true];
			_building setVariable ["bldg_gangName",(_x select 7),true];
			_building setVariable ["locked",true,true];
			_building setVariable ["inv_locked",true,true];
			_building setVariable ["bldg_payment",[_queryResultT,(_x select 11)],true];
			if ((_x select 12) isEqualTo 1) then {
				_building setVariable ["oilstorage",true,true];
			};

			private _storageCap = 1000;
			private _physicalStorageCap = 1000;

			// 解析库存数据 - 从 JSONB 返回 SQF 格式字符串
			private _trunk = [_x select 4, [[], 0]] call DB_fnc_parseJsonb;
			private _physicalTrunk = [_x select 13, [[], 0]] call DB_fnc_parseJsonb;

			_storageCap = (_x select 5);
			_physicalStorageCap = (_x select 14);
			_building setVariable ["trunk",_trunk,true];
			_building setVariable ["PhysicalTrunk",_physicalTrunk,true];
			_building setVariable ["storageCapacity",_storageCap,true];
			_building setVariable ["physicalStorageCapacity",_physicalStorageCap,true];
			if (_countResult < 8) then {
				_building setVariable ["bldg_locked",true,true];
			};
		};
	} forEach _queryResult;
};
