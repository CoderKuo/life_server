// File: fn_convertStorage.sqf
// Author: Jesse "tkcjesse" Schultz
// Modified: 迁移到 PostgreSQL Mapper 层
private ["_query","_queryResult","_houseID","_crateQuery","_crates","_newInventory","_classnames","_items","_weapons","_magazines","_backpacks","_crateConents","_queryThree","_physInv","_weight","_itemWeight","_secondArray","_queryFour"];

// 使用 houseMapper 获取已拥有房屋数量
private _countResult = ["count", [str olympus_server]] call DB_fnc_houseMapper;
private _recordNum = if (count _countResult > 0) then { (_countResult select 0) select 0 } else { 0 };

for [{_x=0},{_x<=_recordNum},{_x=_x+1}] do {
	// 使用 houseMapper 分页获取房屋
	_queryResult = ["getownedhousepaged", [_x, str olympus_server]] call DB_fnc_houseMapper;
	if (count _queryResult isEqualTo 0) exitWith {};

	{
		_houseID = _x select 0;
		_pid = _x select 1;
		diag_log format ["================= HOUSE %1 - PID %2 ==================",_houseID,_pid];
		_weight = 0;
		_newInventory = [];
		_classnames = [];

		// 使用 houseMapper 获取房屋箱子数据
		_crates = ["gethousecrates", [_pid, _houseID, str olympus_server]] call DB_fnc_houseMapper;
		if (count _crates isEqualTo 0) exitWith {
			_physInv = [[],0];
			_physInv = [_physInv] call OES_fnc_escapeArray;
			// 使用 houseMapper 设置物理仓库
			["setphysinventory", [_physInv, _houseID, _pid, str olympus_server]] call DB_fnc_houseMapper;
		};

		{
			// 解析箱子内容 - 从 JSONB 返回 SQF 格式字符串
			_crateConents = [_x select 3, []] call DB_fnc_parseJsonb;
			diag_log format ["Crate %1 PID %2 House %3",_x select 0,_x select 1,_x select 2];
			diag_log format ["Current Inventory %1",_newInventory];
			// 使用 playerMapper 增加银行余额
			["incrementbank", [_x select 1, 200000]] call DB_fnc_playerMapper;
			if (count _crateConents isEqualTo 0) exitWith {diag_log format ["No crate contents for HouseID: %1",_houseID];};

			_weapons = (_crateConents select 1) select 0;
			diag_log format ["Weapons - %1",_weapons];
			_magazines = (_crateConents select 1) select 1;
			diag_log format ["Magazines - %1",_magazines];
			_items = (_crateConents select 1) select 2;
			diag_log format ["Items - %1",_items];
			_backpacks = (_crateConents select 1) select 3;
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
		// 使用 houseMapper 设置物理仓库
		["setphysinventory", [_secondArray, _houseID, _pid, str olympus_server]] call DB_fnc_houseMapper;
		diag_log "================= END OF CRATES ==================";
		uiSleep 2;
	} forEach _queryResult;
};

diag_log "============================================================";
diag_log format ["=========== STORAGE CONVERSION HAS COMPLETED - SERVER %1 ===========",olympus_server];
diag_log "============================================================";
