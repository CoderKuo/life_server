//	Author: Bryan "Tonic" Boardwine
//  File: fn_keyManagement.sqf
//	Description:
//	Keeps track of an array locally on the server of a players keys.

private["_pid","_side","_input","_mode","_arr"];
_pid = param [0,"",[""]];
_side = param [1,sideUnknown,[sideUnknown]];
_mode = param [3,0,[0]];

if(_pid == "" || _side == sideUnknown) exitWith {}; //BAAAAAAAAADDDDDDDD

switch(_mode) do {
	case 0: {
		_input = param [2,[],[[]]];
		_arr = [];
		{
			if(!isNull _x && {!(_x isKindOf "House")}) then {
				_arr pushBack _x;
			};
		} foreach _input;

		_arr = _arr - [ObjNull];
		missionNamespace setVariable[format["%1_KEYS_%2",_pid,_side],_arr];
	};

	case 1: {
		_input = param [2,ObjNull,[ObjNull]];
		if(isNull _input) exitWith {};
		if(_input isKindOf "House") exitWith {
			private _houseTempKeys = _input getVariable ["houseTempKeys",[]];
			_houseTempKeys pushBack _pid;
			_input setVariable ["houseTempKeys",_houseTempKeys,true];
		};
		_arr = missionNamespace getVariable [format["%1_KEYS_%2",_pid,_side],[]];
		_arr pushBack _input;
		_arr = _arr - [ObjNull];
		missionNamespace setVariable[format["%1_KEYS_%2",_pid,_side],_arr];
	};

	case 2: {
		_arr = missionNamespace getVariable[format["%1_KEYS_%2",_pid,_side],[]];
		_arr = _arr - [ObjNull];
		missionNamespace setVariable[format["%1_KEYS_%2",_pid,_side],_arr];
	};
};