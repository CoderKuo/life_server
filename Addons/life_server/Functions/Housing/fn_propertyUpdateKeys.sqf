//  File: fn_propertyUpdateKeys
//	Description: Updates the key list for a property

private["_property","_mode","_propertyID","_propertyPos","_player","_query","_queryResult","_failed","_keyPlayers"];
_property = param [0,ObjNull,[ObjNull]];
_keyPlayers = param [1,[],[[]]];
_player = param [2,ObjNull,[ObjNull]];

_failed = false;
if(isNull _player) exitWith {};
_pid = getPlayerUID _player;
if(isNull _property) exitWith {[[1,"Could not give player key. (error occurred)"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;};


_propertyID = _property getVariable["house_id",-1];

if(_propertyID == -1) then {
	_propertyPos = getPosATL _property;

	_query = format["SELECT id FROM houses WHERE pos='%1' AND owned='1' AND pid='%2' AND server='%3'",_propertyPos,_pid,olympus_server];
	format["PUK1: %1",_query] call OES_fnc_diagLog;
	_queryResult = [_query,2] call OES_fnc_asyncCall;
	format["PUK2: %1",_queryResult] call OES_fnc_diagLog;

	if(count _queryResult != 0) then {
		_propertyID = (_queryResult select 0);
	} else {
		_failed = true;
	};
};

if(_failed) exitWith {[[1,"Could not give player key. (error occurred)"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;};

_property setVariable["keyPlayers",_keyPlayers,true];
_keyPlayers = [_keyPlayers] call OES_fnc_mresArray;
_query = format["UPDATE houses SET player_keys='%1' WHERE id='%2' AND pid='%3' AND server='%4'",_keyPlayers,_propertyID,_pid,olympus_server];
[_query,1] call OES_fnc_asyncCall;
