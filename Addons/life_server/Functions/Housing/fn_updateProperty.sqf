//  File: fn_updateProperty
//	Description: Updates the property with the new modification in the database.

private["_propertyID","_propertyPos","_query","_queryResult","_failed"];
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

	_query = format["SELECT id FROM houses WHERE pos='%1' AND owned='1' AND pid='%2' AND server='%3'",_propertyPos,_pid,olympus_server];
	_queryResult = [_query,2] call OES_fnc_asyncCall;

	if(count _queryResult != 0) then {
		_propertyID = (_queryResult select 0);
	} else {
		_failed = true;
	};
};

if(_failed) exitWith {[[1,"House renovations failed. (error occurred)"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP; [["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP; [["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;};

switch (_mode) do {
	case "storage": {
		//upgrades storage by 700
		_query = format["UPDATE houses SET storageCapacity='%1' WHERE id='%2' AND pid='%3' AND server='%4'",((_property getVariable ["storageCapacity",100]) + 700),_propertyID,_pid,olympus_server];
		_property setVariable["storageCapacity",((_property getVariable ["storageCapacity",100]) + 700),true];
	};
	case "physicalstorage": {
		//upgrades storage by 100
		_query = format["UPDATE houses SET physicalStorageCapacity='%1' WHERE id='%2' AND pid='%3' AND server='%4'",((_property getVariable ["physicalStorageCapacity",100]) + 200),_propertyID,_pid,olympus_server];
		_property setVariable["physicalStorageCapacity",((_property getVariable ["physicalStorageCapacity",100]) + 200),true];
	};
	case "oil": {
		_query = format ["UPDATE houses SET oil='1' WHERE id='%1' AND pid='%2' AND server='%3'",_propertyID,_pid,olympus_server];
		_property setVariable ["oilstorage",true,true];
	};
};


[_query,1] call OES_fnc_asyncCall;
[[1,"House renovations were successful."],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
[["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
