//	Author: Bryan "Tonic" Boardwine
//	Modified: 迁移到 PostgreSQL Mapper 层

//	Description:
//	Takes partial data of a player and updates it, this is meant to be
//	less network intensive towards data flowing through it for updates.

private["_uid","_side","_value","_mode","_verify"];
_uid = param [0,"",[""]];
_side = param [1,sideUnknown,[civilian]];
_mode = param [3,-1,[0]];

private _check = (_uid find "'" != -1);
if (_check) exitWith {};

if(_uid == "" || _side == sideUnknown) exitWith {}; //Bad.

switch(_mode) do {
	// Case 0: Update cash only
	case 0: {
		_value = param [2,0,[0]];
		format["Player %1 partial sync. Side: %2, Cash: $%3",_uid, _side, [_value] call OEC_fnc_numberText] call OES_fnc_diagLog;
		_value = str ([_value] call OES_fnc_numberToString);
		["updatecash", [_uid, _value]] call DB_fnc_playerMapper;
	};

	// Case 1: Update bank only
	case 1: {
		_value = param [2,0,[0]];
		// 添加详细调试日志 - 追踪银行更新来源
		format["[DEBUG BANK UPDATE] Player %1, Side: %2, New Bank Value: $%3, remoteExecutedOwner: %4", _uid, _side, _value, remoteExecutedOwner] call OES_fnc_diagLog;
		// 如果银行值为0或负数，阻止更新（可能是bug）
		if (_value <= 0) exitWith {
			format["[WARNING] Bank update BLOCKED for player %1! Value is %2 (likely a bug). Full params: %3", _uid, _value, _this] call OES_fnc_diagLog;
		};
		format["Player %1 partial sync. Side: %2, Bank: $%3",_uid, _side, [_value] call OEC_fnc_numberText] call OES_fnc_diagLog;
		_value = str ([_value] call OES_fnc_numberToString);
		["updatebank", [_uid, _value]] call DB_fnc_playerMapper;
	};

	// Case 2: Update licenses
	case 2: {
		_value = param [2,[],[[]]];
		for "_i" from 0 to count(_value)-1 do {
			_bool = [(_value select _i) select 1] call OES_fnc_bool;
			_value set[_i,[(_value select _i) select 0,_bool]];
		};
		_value = [_value] call OES_fnc_escapeArray;
		private _type = switch(_side) do {
			case west: { "cop" };
			case civilian: { "civ" };
			case independent: { "med" };
		};
		["updatelicenses", [_uid, _value, _type]] call DB_fnc_playerMapper;
	};

	// Case 3: Update gear
	case 3: {
		_value = param [2,[],[[]]];
		format["Player %1 partial sync. Side: %2, Gear: %3",_uid, _side, _value] call OES_fnc_diagLog;
		_value = [_value] call OES_fnc_escapeArray;
		private _gearCol = switch(_side) do {
			case west: { dbColumnGearCop };
			case civilian: { dbColumnGearCiv };
			case independent: { dbColumnGearMed };
		};
		["updategear", [_uid, _value, _gearCol]] call DB_fnc_playerMapper;
	};

	// Case 4: Update alive status
	case 4: {
		_value = param [2,false,[true]];
		_value = str ([_value] call OES_fnc_bool);
		["updatealive", [_uid, _value]] call DB_fnc_playerMapper;
	};

	// Case 5: Update arrested/jail info
	case 5: {
		_array = param [2,[0,0,0],[[]]];
		format["Player %1 partial sync. Side: %2, JailInfo: %3",_uid, _side, _array] call OES_fnc_diagLog;
		_array = [_array] call OES_fnc_escapeArray;
		["updatearrested", [_uid, _array]] call DB_fnc_playerMapper;
	};

	// Case 6: Update cash and bank together
	case 6: {
		_value1 = param [2,0,[0]];
		_value2 = param [4,0,[0]];
		format["Player %1 partial sync. Side: %2, Cash: $%3, Bank: $%4",_uid, _side, [_value1] call OEC_fnc_numberText, [_value2] call OEC_fnc_numberText] call OES_fnc_diagLog;
		_value1 = str ([_value1] call OES_fnc_numberToString);
		_value2 = str ([_value2] call OES_fnc_numberToString);
		["updatecashbank", [_uid, _value1, _value2]] call DB_fnc_playerMapper;
	};

	// Case 7: Key management (unchanged - calls another function)
	case 7: {
		_array = param [2,[],[[]]];
		[_uid,_side,_array,0] call OES_fnc_keyManagement;
	};

	// Case 8: Update aliases
	case 8: {
		_aliases = param [2,[],[[]]];
		_aliases = [_aliases] call OES_fnc_escapeArray;
		["updatealiases", [_uid, _aliases]] call DB_fnc_playerMapper;
	};

	// Case 9: Update player stats
	case 9: {
		_array = param [2,[0,0,0,0,0,0,0,0,0,0],[[]]];
		_verify = format["%1",_array];
		if((count toArray(_verify)) <= 14) exitWith {};
		_array = [_array] call OES_fnc_escapeArray;
		["updatestats", [_uid, _array]] call DB_fnc_playerMapper;
	};

	// Case 10: Update wanted status
	case 10: {
		_array = param [2,[],[[]]];
		_array = [_array] call OES_fnc_escapeArray;
		["updatewanted", [_uid, _array]] call DB_fnc_playerMapper;
	};

	// Case 11: Player died on civilian - reset cash, gear, position
	case 11: {
		_value1 = "0";
		_array1 = ["U_C_Poloshirt_stripped","","","","",["ItemMap","ItemCompass","ItemWatch"],"","","",[],[],[],[],[],[],[],[],[]];
		_array2 = [];
		format["Player %1 partial sync. Player just died on civilian. Side: %2",_uid, _side] call OES_fnc_diagLog;
		_array1 = [_array1] call OES_fnc_escapeArray;
		_array2 = [_array2] call OES_fnc_escapeArray;
		["updateoncivdeath", [_uid, _value1, _array1, _array2, dbColumnGearCiv, dbColumnPosition]] call DB_fnc_playerMapper;
	};

	// Case 12: Update position only
	case 12: {
		_array = param [2,[],[[]]];
		format["Player %1 partial sync. Side: %2, Position: %3",_uid, _side, _array] call OES_fnc_diagLog;
		_array = [_array] call OES_fnc_escapeArray;
		["updateposition", [_uid, _array, dbColumnPosition]] call DB_fnc_playerMapper;
	};

	// Case 13: Update war points
	case 13: {
		_value = param [2, 0, [0]];
		format ["Player %1 partial sync. Side: %2. War Points: %3", _uid, _side, _value] call OES_fnc_diagLog;
		["updatewarptssimple", [_uid, str _value]] call DB_fnc_playerMapper;
	};
};
