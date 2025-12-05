//  File: fn_logIt.sqf | Headless Client
//	Author: Tech
//	Description: Turns list of keys and values into json that is A3Log'd. Also logs strings but don't do that.

//Usage [[key1,value1],[key2,value2],[key3,value3]] call OEC_fnc_logIt;
//			"string" call OEC_fnc_logIt

private["_string"];

if(_this isEqualType "") exitWith {
	_this call A3Log;
};
if(_this select 0 isEqualType "") exitWith {
	_this call A3Log;
};

if(count _this isEqualTo 0) exitWith {};

_string = "{";
{
	if(_x select 1 isEqualType "") then {
		_string = format['%1"%2":"%3",',_string,_x select 0,_x select 1];
	} else {
		_string = format['%1"%2":%3,',_string,_x select 0,_x select 1];
	};
} forEach _this; //forEach all params

_string = ([_string, 0, count _string-2] call BIS_fnc_trimString) + "}";

[_string] call A3Log;
