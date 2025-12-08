//	File: fn_updateRequest.sqf
//	Author: Bryan "Tonic" Boardwine
//	Modified: 迁移到 PostgreSQL Mapper 层

//	Description:
//	Ain't got time to describe it, READ THE FILE NAME!
private["_uid","_side","_cash","_bank","_name","_coordinates"];
_uid = param [0,"",[""]];
_name = param [1,"",[""]];
_side = param [2,sideUnknown,[civilian]];
_cash = param [3,0,[0]];
_bank = param [4,5000,[0]];
_coordinates = param [5,[],[[]]];

//Get to those error checks.
if((_uid == "") || (_name == "")) exitWith {};

private _check = (_uid find "'" != -1);
if (_check) exitWith {};

format["Player %1(%2) sync request. Side: %3, Cash: $%4, Bank: $%5, Position: %6",_name,_uid,_side,[_cash] call OEC_fnc_numberText,[_bank] call OEC_fnc_numberText,_coordinates] call OES_fnc_diagLog;

//Parse and setup some data.
_name = [_name] call OES_fnc_escapeString; //Clense the name of bad chars.
_name = _name splitString " " joinString " "; //Remove any extra white space, one space is fine
_cash = [_cash] call OES_fnc_numberToString;
_bank = [_bank] call OES_fnc_numberToString;
_coordinates = [_coordinates] call OES_fnc_escapeArray;

switch (_side) do {
	case west: {
		["updatebasic", [_uid, _name, _cash, _bank]] call DB_fnc_playerMapper;
	};
	case civilian: {
		["syncwithposition", [_uid, _name, _cash, _bank, _coordinates, dbColumnPosition]] call DB_fnc_playerMapper;
	};
	case independent: {
		["updatebasic", [_uid, _name, _cash, _bank]] call DB_fnc_playerMapper;
	};
};
