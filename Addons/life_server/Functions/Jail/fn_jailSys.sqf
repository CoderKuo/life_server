//	File: fn_jailSys.sqf
//  Author: Bryan "Tonic" Boardwine

private["_unit","_bad","_id","_ret"];
_unit = param [0,Objnull,[Objnull]];
if(isNull _unit) exitWith {};
_bad = param [1,false,[false]];
_id = owner _unit;

_ret = [_unit] call OES_fnc_wantedPerson;
[[_ret,_bad],"OEC_fnc_jailMe",_id,false] spawn OEC_fnc_MP;