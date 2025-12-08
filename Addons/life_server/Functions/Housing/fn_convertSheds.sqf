// File: fn_convertSheds.sqf
// Author: Jesse "tkcjesse" Schultz
// Modified: 迁移到 PostgreSQL Mapper 层
if !(olympus_server isEqualTo 1) exitWith {};

private ["_query","_queryResult","_houseID","_crateQuery","_crates","_newInventory","_classnames","_items","_weapons","_magazines","_backpacks","_crateConents","_queryThree","_physInv","_weight","_itemWeight","_secondArray"];

// 使用 gangMapper 获取已拥有的帮派建筑数量
private _countResult = ["countownedbuildings", []] call DB_fnc_gangMapper;
private _recordNum = if (count _countResult > 0) then { (_countResult select 0) select 0 } else { 0 };

for [{_x=0},{_x<=_recordNum},{_x=_x+1}] do {
	// 使用 gangMapper 分页获取帮派建筑
	_queryResult = ["getownedbuildingpaged", [_x]] call DB_fnc_gangMapper;
	if (count _queryResult isEqualTo 0) exitWith {};

	{
		_houseID = _x select 0;
		_pid = _x select 1;
		diag_log format ["================= SHED %1 - GID %2 ==================",_houseID,_pid];
		_weight = 0;
		_newInventory = [];
		_classnames = [];

		// 使用 gangMapper 获取帮派箱子数据
		_crates = ["getgangcrates", [_pid, _houseID]] call DB_fnc_gangMapper;
		if (count _crates isEqualTo 0) exitWith {
			_physInv = [[],0];
			_physInv = [_physInv] call OES_fnc_escapeArray;
			// 使用 gangMapper 设置物理仓库
			["setbuildingphysinv", [_physInv, _houseID, _pid]] call DB_fnc_gangMapper;
		};

		{
			// 解析箱子内容 - 从 JSONB 返回 SQF 格式字符串
			_crateConents = [_x select 3, []] call DB_fnc_parseJsonb;
			diag_log format ["Crate %1 Building %2 GID %3",_x select 0,_x select 1,_x select 2];
			diag_log format ["Crate Contents: %1",_crateConents];
			diag_log format ["Current Inventory %1",_newInventory];
			if (count _crateConents isEqualTo 0) exitWith {diag_log format ["No crate contents for BuildingID: %1",_houseID];};

			_weapons = _crateConents select 0;
			diag_log format ["Weapons - %1",_weapons];
			_magazines = _crateConents select 1;
			diag_log format ["Magazines - %1",_magazines];
			_items = _crateConents select 2;
			diag_log format ["Items - %1",_items];
			_backpacks = _crateConents select 3;
			diag_log format ["Backpacks - %1",_backpacks];

			{
				if (_x in _classnames) then {
					_index = _classnames find _x;
					(_newInventory select _index) set [1,(((_newInventory select _index) select 1) + ((_weapons select 1) select _forEachIndex))];
					_itemWeight = getNumber (missionConfigFile >> "CfgWeights" >> _x >> "weight");
					_weight = _weight + (_itemWeight * ((_weapons select 1) select _forEachIndex));
				} else {
					_classnames pushBack _x;
					_newInventory pushBack [_x,((_weapons select 1) select _forEachIndex)];
				};
				_itemWeight = getNumber (missionConfigFile >> "CfgWeights" >> _x >> "weight");
				_weight = _weight + (_itemWeight * ((_weapons select 1) select _forEachIndex));
			} forEach (_weapons select 0);

			{
				if ((_x select 0) in _classnames) then {
					_index = _classnames find (_x select 0);
					(_newInventory select _index) set [1,(((_newInventory select _index) select 1) + (_x select 2))];
				} else {
					_classnames pushBack (_x select 0);
					_newInventory pushBack [_x select 0,_x select 2];
				};

				_itemWeight = getNumber (missionConfigFile >> "CfgWeights" >> (_x select 0) >> "weight");
				_weight = _weight + (_itemWeight * (_x select 2));
			} forEach _magazines;

			{
				if (_x in _classnames) then {
					_index = _classnames find _x;
					(_newInventory select _index) set [1,(((_newInventory select _index) select 1) + ((_items select 1) select _forEachIndex))];
				} else {
					_classnames pushBack _x;
					_newInventory pushBack [_x,((_items select 1) select _forEachIndex)];
				};

				_itemWeight = getNumber (missionConfigFile >> "CfgWeights" >> _x >> "weight");
				_weight = _weight + (_itemWeight * ((_items select 1) select _forEachIndex));
			} forEach (_items select 0);

			{
				if (_x in _classnames) then {
					_index = _classnames find _x;
					(_newInventory select _index) set [1,(((_newInventory select _index) select 1) + ((_backpacks select 1) select _forEachIndex))];
				} else {
					_classnames pushBack _x;
					_newInventory pushBack [_x,((_backpacks select 1) select _forEachIndex)];
				};

				_itemWeight = getNumber (missionConfigFile >> "CfgWeights" >> _x >> "weight");
				_weight = _weight + (_itemWeight * ((_backpacks select 1) select _forEachIndex));
			} forEach (_backpacks select 0);

		} forEach _crates;

		_secondArray = [];
		_secondArray pushBack _newInventory;
		_secondArray pushBack _weight;
		_secondArray = [_secondArray] call OES_fnc_escapeArray;
		diag_log format ["Sending to Server: %1",_secondArray];
		// 使用 gangMapper 设置物理仓库
		["setbuildingphysinv", [_secondArray, _houseID, _pid]] call DB_fnc_gangMapper;
		diag_log "================= END OF CRATES ==================";
		uiSleep 2;
	} forEach _queryResult;
};

diag_log "============================================================";
diag_log "=========== STORAGE CONVERSION HAS COMPLETED - SHEDS ===========";
diag_log "============================================================";
