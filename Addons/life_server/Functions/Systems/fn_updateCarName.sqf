//  File: fn_updateCarName.sqf
//	Author: Tech
//	Description: Updates customName on the DB
//  Modified: 迁移到 PostgreSQL Mapper 层
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
// 使用 vehicleMapper 更新车辆自定义名称
["updatecustomname", [_pid, _vid, _name]] call DB_fnc_vehicleMapper;
