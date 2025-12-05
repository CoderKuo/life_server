//	Original Author: Kurt
//	File: fn_updateTitle.sqf

params [
	["_title","",[""]],
	["_uid","",[""]]
];

private _check = (_title find "'" != -1);
if (_check) exitWith {};
private _check = (_uid find "'" != -1);
if (_check) exitWith {};

private _query = format["UPDATE players SET current_title = '%1' WHERE playerid='%2'",_title,_uid];
[_query,1] spawn OES_fnc_asyncCall;