//  File: fn_updateProperty
//	Description: Updates the property with the new modification in the database.
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_propertyID","_propertyPos","_queryResult","_failed"];
params [
	["_property",objNull,[objNull]],
	["_player",objNull,[objNull]],
	["_mode","",[""]]
];
_failed = false;
if(isNull _player) exitWith {};
_pid = getPlayerUID _player;
if(isNull _property || _mode == "" || _pid == "") exitWith {[[1,"House renovations failed. (error occurred)"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP; [["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP; [["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;};


_propertyID = _property getVariable["house_id",-1];

if(_propertyID == -1) then {
	_propertyPos = getPosATL _property;
	// 获取房屋ID
	_queryResult = ["exists", [str _propertyPos, str olympus_server]] call DB_fnc_houseMapper;

	if(count _queryResult != 0) then {
		_propertyID = (_queryResult select 0);
	} else {
		_failed = true;
	};
};

if(_failed) exitWith {[[1,"House renovations failed. (error occurred)"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP; [["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP; [["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;};

switch (_mode) do {
	case "storage": {
		// 升级虚拟存储 +700
		private _newCapacity = (_property getVariable ["storageCapacity",100]) + 700;
		["updatestorage", [str _propertyID, _pid, str _newCapacity, str olympus_server]] call DB_fnc_houseMapper;
		_property setVariable["storageCapacity",_newCapacity,true];
	};
	case "physicalstorage": {
		// 升级物理存储 +200
		private _newCapacity = (_property getVariable ["physicalStorageCapacity",100]) + 200;
		["updatephysicalstorage", [str _propertyID, _pid, str _newCapacity, str olympus_server]] call DB_fnc_houseMapper;
		_property setVariable["physicalStorageCapacity",_newCapacity,true];
	};
	case "oil": {
		["upgradeoil", [str _propertyID, _pid, str olympus_server]] call DB_fnc_houseMapper;
		_property setVariable ["oilstorage",true,true];
	};
};

[[1,"House renovations were successful."],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
[["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
