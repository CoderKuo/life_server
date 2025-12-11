//  File: fn_gangBank
//	Author: Poseidon
//  Modified: 迁移到 PostgreSQL Mapper 层，移除不必要的延迟

params [
	["_mode",0,[0]],
	["_gangID",-1,[0]],
	["_unit",objNull,[objNull]],
	["_change",0,[0]],
	["_cash",0,[0]],
	["_cashRand",0,[0]],
	["_armsTax",false,[false]],
	["_gangName", "",[""]]
];

if(isNull _unit || _gangID isEqualTo -1) exitWith {};

switch (_mode) do {
	case 0: {
		// 获取帮派银行余额
		_queryResult = ["getgangbank", [str _gangID]] call DB_fnc_gangMapper;
		// 解析字符串为数字
		private _gangBank = parseNumber (_queryResult select 0);

		["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
		["oev_gangfund_ready",true] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
		["oev_gang_funds",_gangBank] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
	};

	case 1: {
		// 注意：旧代码有随机延迟(最多12秒)防止复制金钱漏洞，但PostgreSQL事务是原子性的，
		// 数据库本身保证并发安全，且取款前会重新查询余额，因此不需要人为延迟

		// 获取帮派银行余额
		_queryResult = ["getgangbank", [str _gangID]] call DB_fnc_gangMapper;
		// 解析字符串为数字
		private _currentBank = parseNumber (_queryResult select 0);

		if((_currentBank + _change) >= 0) then {
			if(isNull _unit) exitWith {};

			private _newBalance = _currentBank + _change;
			// 更新帮派银行 - 使用 safeNumber 避免科学计数法
			private _newBalanceStr = ["format", _newBalance] call OES_fnc_safeNumber;
			["updategangbank", [str _gangID, _newBalanceStr]] call DB_fnc_gangMapper;

			if(_change > 0) then {
				[
					["event","Gang Bank Deposit"],
					["player",name _unit],
					["player_id",getPlayerUID _unit],
					["value",_change],
					["gang_name",_gangName],
					["gang_id",_gangID],
					["new_gang_bank",_newBalance],
					["new_player_cash",_cash - _change]
				] call OES_fnc_logIt;

				// 记录历史
				["addbankhistory", [name _unit, getPlayerUID _unit, "1", str _change, str _gangID]] call DB_fnc_gangMapper;
			} else {
				[
					["event","Gang Bank Withdraw"],
					["player",name _unit],
					["player_id",getPlayerUID _unit],
					["value",_change],
					["gang_name",_gangName],
					["gang_id",_gangID],
					["new_gang_bank",_newBalance],
					["new_player_cash",_cash - _change]
				] call OES_fnc_logIt;

				// 记录历史
				["addbankhistory", [name _unit, getPlayerUID _unit, "2", str (_change * -1), str _gangID]] call DB_fnc_gangMapper;
			};

			if(isNull _unit) exitWith {};
			if(_change <= 0) then {
				["oev_cash",(_cash - _change)] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
			};
			["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
		} else {
			if(isNull _unit) exitWith {};

			if(_change >= 0) then {
				["oev_cash",_cash] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
			};
			["oev_cache_cash",_cashRand] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];


			[1,"Transaction failed to process. Insufficient funds."] remoteExec ["OEC_fnc_broadcast",(owner _unit),false];
			["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
		};
	};

	case 2: {
		if(isNull _unit) exitWith {};

		// 获取帮派银行余额
		private _queryResult = ["getgangbank", [str _gangID]] call DB_fnc_gangMapper;
		if (isNil "_queryResult" || {count _queryResult == 0}) exitWith {};
		// 解析字符串为数字
		private _currentBank = parseNumber (_queryResult select 0);

		if(_change > 0) then {
			if (_armsTax) then {
				format["Due to a purchase by %1(%2), $%5 was deposited into gang funds for GangID: %6. Previous Gang funds: $%3, New Gang funds: $%4", name _unit, getPlayerUID _unit, [_currentBank] call OEC_fnc_numberText, [(_currentBank + _change)] call OEC_fnc_numberText, [_change] call OEC_fnc_numberText, _gangID] call OES_fnc_diagLog;
			} else {
				format["Player %1(%2) deposited funds to gang. Previous Gang funds: $%3, New Gang funds: $%4, Total Change: $%5, GangID: %6", name _unit, getPlayerUID _unit, [_currentBank] call OEC_fnc_numberText, [(_currentBank + _change)] call OEC_fnc_numberText, [_change] call OEC_fnc_numberText, _gangID] call OES_fnc_diagLog;
			};
		} else {
			format["Player %1(%2) withdrew funds to gang. Previous Gang funds: $%3, New Gang funds: $%4, Total Change: $%5, GangID: %6", name _unit, getPlayerUID _unit, [_currentBank] call OEC_fnc_numberText, [(_currentBank + _change)] call OEC_fnc_numberText, [_change] call OEC_fnc_numberText, _gangID] call OES_fnc_diagLog;
		};

		if((_currentBank + _change) >= 0) then {
			private _newBalance = _currentBank + _change;
			// 更新帮派银行 - 使用 safeNumber 避免科学计数法
			private _newBalanceStr = ["format", _newBalance] call OES_fnc_safeNumber;
			["updategangbank", [str _gangID, _newBalanceStr]] call DB_fnc_gangMapper;
		};
	};
};
