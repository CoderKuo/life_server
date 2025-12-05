//	Author: Bryan "Tonic" Boardwine

//	Description:
//	Takes partial data of a player and updates it, this is meant to be
//	less network intensive towards data flowing through it for updates.

private["_uid","_side","_value","_mode","_query","_verify"];
_uid = param [0,"",[""]];
_side = param [1,sideUnknown,[civilian]];
_mode = param [3,-1,[0]];

private _check = (_uid find "'" != -1);
if (_check) exitWith {};

if(_uid == "" || _side == sideUnknown) exitWith {}; //Bad.
_query = "";

switch(_mode) do {
	case 0: {
		_value = param [2,0,[0]];

		format["Player %1 partial sync. Side: %2, Cash: $%3",_uid, _side, [_value] call OEC_fnc_numberText] call HC_fnc_diagLog;

		_value = [_value] call HC_fnc_numberSafe;
		_query = format["UPDATE players SET cash='%1' WHERE playerid='%2'",_value,_uid];
	};

	case 1: {
		_value = param [2,0,[0]];

		format["Player %1 partial sync. Side: %2, Bank: $%3",_uid, _side, [_value] call OEC_fnc_numberText] call HC_fnc_diagLog;

		_value = [_value] call HC_fnc_numberSafe;
		_query = format["UPDATE players SET bankacc='%1' WHERE playerid='%2'",_value,_uid];
	};

	case 2: {
		_value = param [2,[],[[]]];
		for "_i" from 0 to count(_value)-1 do {
			_bool = [(_value select _i) select 1] call HC_fnc_bool;
			_value set[_i,[(_value select _i) select 0,_bool]];
		};
		_value = [_value] call HC_fnc_mresArray;
		switch(_side) do {
			case west: {_query = format["UPDATE players SET cop_licenses='%1' WHERE playerid='%2'",_value,_uid];};
			case civilian: {_query = format["UPDATE players SET civ_licenses='%1' WHERE playerid='%2'",_value,_uid];};
			case independent: {_query = format["UPDATE players SET med_licenses='%1' WHERE playerid='%2'",_value,_uid];};
		};
	};

	case 3: {
		_value = param [2,[],[[]]];

		format["Player %1 partial sync. Side: %2, Gear: %3",_uid, _side, _value] call HC_fnc_diagLog;

		_value = [_value] call HC_fnc_mresArray;
		switch(_side) do {
			case west: {_query = format["UPDATE players SET cop_gear='%1' WHERE playerid='%2'",_value,_uid];};
			case civilian: {_query = format["UPDATE players SET civ_gear='%1' WHERE playerid='%2'",_value,_uid];};
			case independent: {_query = format["UPDATE players SET med_gear='%1' WHERE playerid='%2'",_value,_uid];};
		};
	};

	case 4: {
		_value = param [2,false,[true]];
		_value = [_value] call HC_fnc_bool;
		_query = format["UPDATE players SET alive='%1' WHERE playerid='%2'",_value,_uid];
	};

	case 5: {
		_array = param [2,[0,0,0],[[]]];

		format["Player %1 partial sync. Side: %2, JailInfo: %3",_uid, _side, _array] call HC_fnc_diagLog;

		_array = [_array] call HC_fnc_mresArray;
		_query = format["UPDATE players SET arrested='%1' WHERE playerid='%2'",_array,_uid];
	};

	case 6: {
		_value1 = param [2,0,[0]];
		_value2 = param [4,0,[0]];

		format["Player %1 partial sync. Side: %2, Cash: $%3, Bank: $%4",_uid, _side, [_value1] call OEC_fnc_numberText, [_value2] call OEC_fnc_numberText] call HC_fnc_diagLog;

		_value1 = [_value1] call HC_fnc_numberSafe;
		_value2 = [_value2] call HC_fnc_numberSafe;
		_query = format["UPDATE players SET cash='%1', bankacc='%2' WHERE playerid='%3'",_value1,_value2,_uid];
	};

	case 7: {
		//_array = param [2,[],[[]]];
		//[_uid,_side,_array,0] call OES_fnc_keyManagement;
	};

	case 8: {
		_aliases = param [2,[],[[]]];
		_aliases = [_aliases] call HC_fnc_mresArray;
		_query = format["UPDATE players SET aliases='%1' WHERE playerid='%2'",_aliases,_uid];
	};

	case 9: {
		_array = param [2,[0,0,0,0,0,0,0,0,0,0],[[]]];
		_verify = format["%1",_array];
		if((count toArray(_verify)) <= 14) exitWith {_query = ""};
		_array = [_array] call HC_fnc_mresArray;
		_query = format["UPDATE players SET player_stats='%1' WHERE playerid='%2'",_array,_uid];
	};

	case 10: {
		_array = param [2,[],[[]]];
		_array = [_array] call HC_fnc_mresArray;
		_query = format["UPDATE players SET wanted='%1' WHERE playerid='%2'",_array,_uid];
	};

	case 11: {
		_value1 = 0;
		_array1 = ["U_C_Poloshirt_stripped","","","","",["ItemMap","ItemCompass","ItemWatch"],"","","",[],[],[],[],[],[],[],[],[]];
		_array2 = [];

		format["Player %1 partial sync. Player just died on civilian. Side: %2",_uid, _side] call HC_fnc_diagLog;

		_value1 = [_value1] call HC_fnc_numberSafe;
		_array1 = [_array1] call HC_fnc_mresArray;
		_array2 = [_array2] call HC_fnc_mresArray;

		_query = format["UPDATE players SET cash='%1', civ_gear='%2', coordinates='%3' WHERE playerid='%4'",_value1,_array1,_array2,_uid];
	};

	case 12: {
		_array = param [2,[],[[]]];

		format["Player %1 partial sync. Side: %2, Position: %3",_uid, _side, _array] call HC_fnc_diagLog;

		_array = [_array] call HC_fnc_mresArray;
		_query = format["UPDATE players SET coordinates='%1' WHERE playerid='%2'",_array,_uid];
	};

	case 13: {
		_value = param [2, 0, [0]];
		format ["Player %1 partial sync. Side: %2. War Points: %3", _uid, _side, _value] call HC_fnc_diagLog;
		_query = format ["UPDATE players SET warpts='%1' WHERE playerid='%2'", _value, _uid];
	};
};

if(_query == "") exitWith {};
[_query,1] call HC_fnc_asyncCall;
