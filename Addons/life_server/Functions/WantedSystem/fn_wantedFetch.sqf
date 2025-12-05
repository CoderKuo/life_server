//	File: fn_wantedFetch.sqf
//	Author: Bryan "Tonic" Boardwine"
//	Description: Displays wanted list information sent from the server.

params [["_ret",objNull,[objNull]]];
if (isNull _ret) exitWith {};

_ret = owner _ret;

private _list = [];
{
	if ([_x select 1] call OEC_fnc_isUIDActive) then {
			_list pushBack _x;
	};
} forEach life_wanted_list;

[_list] remoteExec ["OEC_fnc_wantedList",_ret,false];