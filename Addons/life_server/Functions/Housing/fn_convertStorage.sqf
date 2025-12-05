// File: fn_convertStorage.sqf
// Author: Jesse "tkcjesse" Schultz
private ["_query","_queryResult","_houseID","_crateQuery","_crates","_newInventory","_classnames","_items","_weapons","_magazines","_backpacks","_crateConents","_queryThree","_physInv","_weight","_itemWeight","_secondArray","_queryFour"];
private _recordNum = ([format["SELECT COUNT(*) FROM houses%1 WHERE owned='1'",olympus_server],2] call OES_fnc_asyncCall) select 0;

for [{_x=0},{_x<=_recordNum},{_x=_x+1}] do {
	_query = format ["SELECT id, pid FROM houses%2 WHERE owned='1' LIMIT %1,1",_x,olympus_server];
	_queryResult = [_query,2,true] call OES_fnc_asyncCall;
	if (count _queryResult isEqualTo 0) exitWith {};

	{
		_houseID = _x select 0;
		_pid = _x select 1;
		diag_log format ["================= HOUSE %1 - PID %2 ==================",_houseID,_pid];
		_weight = 0;
		_newInventory = [];
		_classnames = [];

		_crateQuery = format ["SELECT id, pid, houseid, inventory FROM crates%1 WHERE owned='1' AND pid='%2' AND houseid='%3'",olympus_server,_pid,_houseID];
		_crates = [_crateQuery,2,true] call OES_fnc_asyncCall;
		if (count _crates isEqualTo 0) exitWith {
			_physInv = [[],0];
			_physInv = [_physInv] call OES_fnc_mresArray;
			_queryThree = format ["UPDATE houses%1 SET physical_inventory='%2' WHERE id='%3' AND pid='%4'",olympus_server,_physInv,_houseID,_pid];
			[_queryThree,1] call OES_fnc_asyncCall;
		};

		{
			_crateConents = [_x select 3] call OES_fnc_mresToArray;
			diag_log format ["Crate %1 PID %2 House %3",_x select 0,_x select 1,_x select 2];
			diag_log format ["Current Inventory %1",_newInventory];
			_queryFour = format ["UPDATE players SET bankacc = bankacc+200000 WHERE playerid='%1'",(_x select 1)];
			[_queryFour,1] call OES_fnc_asyncCall;
			if (_crateConents isEqualType "") then {_crateConents = call compile format ["%1", _crateConents];};
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
		_secondArray = [_secondArray] call OES_fnc_mresArray;
		diag_log format ["Sending to Server: %1",_secondArray];
		_queryThree = format ["UPDATE houses%1 SET physical_inventory='%2' WHERE id='%3' AND pid='%4'",olympus_server,_secondArray,_houseID,_pid];
		[_queryThree,1] call OES_fnc_asyncCall;
		diag_log "================= END OF CRATES ==================";
		uiSleep 2;
	} forEach _queryResult;
};

diag_log "============================================================";
diag_log format ["=========== STORAGE CONVERSION HAS COMPLETED - SERVER %1 ===========",olympus_server];
diag_log "============================================================";