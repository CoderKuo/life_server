//	File: fn_updateRequest.sqf
//	Author: Bryan "Tonic" Boardwine

//	Description:
//	Ain't got time to describe it, READ THE FILE NAME!
private["_uid","_side","_cash","_bank","_name","_query","_thread","_coordinates"];
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
_name = [_name] call OES_fnc_mresString; //Clense the name of bad chars.
_name = _name splitString " " joinString " "; //Remove any extra white space from mresString, one space is fine
_cash = [_cash] call OES_fnc_numberSafe;
_bank = [_bank] call OES_fnc_numberSafe;
_coordinates = [_coordinates] call OES_fnc_mresArray;

switch (_side) do {
	case west: {_query = format["UPDATE players SET name='%1', cash='%2', bankacc='%3' WHERE playerid='%4'",_name,_cash,_bank,_uid];};
	case civilian: {_query = format["UPDATE players SET name='%1', cash='%2', bankacc='%3', "+dbColumnPosition+"='%4' WHERE playerid='%5'",_name,_cash,_bank,_coordinates,_uid];};
	case independent: {_query = format["UPDATE players SET name='%1', cash='%2', bankacc='%3' WHERE playerid='%4'",_name,_cash,_bank,_uid];};
};

_queryResult = [_query,1] call OES_fnc_asyncCall;
