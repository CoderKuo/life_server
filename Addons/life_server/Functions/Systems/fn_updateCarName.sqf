//  File: fn_updateCarName.sqf
//	Author: Tech
//	Description: Updates customName on the DB
params [
  ["_name","",[""]],
  ["_pid","",[""]],
  ["_vid","",[""]]
];

//Check the name
_nameChar = toArray(_name);
if(count _nameChar > 15) exitWith {};
_allowed = toArray("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_ ");
_badChar = false;
_hasLetters = false;
{if(!(_x in _allowed)) exitWith {_badChar = true;};} forEach _nameChar;
{if(_x in (_allowed - (toArray " "))) exitWith {_hasLetters = true;};} forEach _nameChar;
if(_badChar) exitWith {};
if(!_hasLetters) exitWith {};

if(_name isEqualTo "" || _pid isEqualTo "" || _vid isEqualTo "") exitWith {};
//Update DB
_query = format["UPDATE "+dbColumVehicle+" SET customName='%1' WHERE pid='%2' AND id='%3'",_name,_pid,_vid];
_sql = [_query,1] call OES_fnc_asyncCall;
