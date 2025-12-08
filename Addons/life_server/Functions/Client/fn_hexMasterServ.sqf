//author: trimorphious
//case 0 queries db on login to set player variables for hex icons
//case 1 rolls for a random hex icon and sets the according db values
//case 2 sets the hex icon as their currently equipped icon in db
//case 3 unequips the selected icon and sets their currently equipped to "" in db
//Modified: 迁移到 PostgreSQL Mapper 层

switch(_this select 1) do {
	case 0: {
		// 使用 miscMapper 获取 hex 图标数据
		private _hexArray = ["hexget", [getPlayerUID (_this select 0)]] call DB_fnc_miscMapper;
		if (isNil "_hexArray") then { _hexArray = []; };
		if (count _hexArray != 0) then {
				[4,_hexArray] remoteExec["OEC_fnc_hexIconMaster",(_this select 0)];
		} else {
			// 使用 miscMapper 创建 hex 图标记录
			["createhexicon", [getPlayerUID (_this select 0)]] call DB_fnc_miscMapper;
			_hexArray = ["hexget", [getPlayerUID (_this select 0)]] call DB_fnc_miscMapper;
			if (isNil "_hexArray") then { _hexArray = []; };
			[4,_hexArray] remoteExec["OEC_fnc_hexIconMaster",(_this select 0)];
		};
	};

	case 1: {
		_locked = [];
		_iconArray = _this select 2;
		{
			if(_forEachIndex > 0) then {
				if(_x == 0) then {
					_locked pushBack _forEachIndex;
				};
			};
		} forEach _iconArray;
		if(count _locked == 0) exitWith {};
		_rand = selectRandom _locked;
		_iconArray set [_rand,1];
		[3,_rand, _iconArray] remoteExec["OEC_fnc_hexIconMaster",(_this select 0)];
		// 使用 playerMapper 减少 hex 图标兑换次数
		["decrementhexredemptions", [getPlayerUID (_this select 0)]] call DB_fnc_playerMapper;
		// 使用 miscMapper 更新 hex 图标
		["updatehexicon", [getText(((missionConfigFile >> "CfgIcons") select (_rand-1)) >> "name"), getPlayerUID (_this select 0)]] call DB_fnc_miscMapper;
	};

	case 2: {
		// 使用 playerMapper 更新 hex 图标
		["updatehexicon", [getPlayerUID (_this select 0), (_this select 2)]] call DB_fnc_playerMapper;
	};

	case 3: {
		// 使用 playerMapper 清空 hex 图标
		["updatehexicon", [getPlayerUID (_this select 0), ""]] call DB_fnc_playerMapper;
	};
};
