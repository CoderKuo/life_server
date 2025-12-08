//  File: fn_propertyUpdateKeys
//	Description: Updates the key list for a property
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_property","_mode","_propertyID","_propertyPos","_player","_queryResult","_failed","_keyPlayers"];
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
	// 获取房屋ID
	_queryResult = ["exists", [str _propertyPos, str olympus_server]] call DB_fnc_houseMapper;
	format["PUK1: exists query for pos %1",_propertyPos] call OES_fnc_diagLog;
	format["PUK2: %1",_queryResult] call OES_fnc_diagLog;

	if(count _queryResult != 0) then {
		_propertyID = (_queryResult select 0);
	} else {
		_failed = true;
	};
};

if(_failed) exitWith {[[1,"Could not give player key. (error occurred)"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;};

_property setVariable["keyPlayers",_keyPlayers,true];
_keyPlayers = [_keyPlayers] call OES_fnc_escapeArray;

// 使用 Mapper 更新钥匙
["updatekeys", [str _propertyID, _pid, _keyPlayers, str olympus_server]] call DB_fnc_houseMapper;
