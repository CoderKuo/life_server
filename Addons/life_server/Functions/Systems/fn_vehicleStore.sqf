//	File: fn_vehicleStore.sqf
//  Author: Bryan "Tonic" Boardwine
//	Description: Stores the vehicle in the 'Garage'
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_vehicle","_impound","_vInfo","_vInfo","_plate","_uid","_unit","_ownerID","_vehGangID"];
params [
	["_vehicle",ObjNull,[ObjNull]],
	["_impound",false,[true]],
	["_unit",ObjNull,[ObjNull]],
	["_gangID",0,[0]]
];
_vehGangID = _vehicle getVariable ["gangID",0];
_ownerID = owner _unit;
if(isNull _vehicle || isNull _unit) exitWith {oev_impound_inuse = false; _ownerID publicVariableClient "oev_impound_inuse";oev_garage_store = false;_ownerID publicVariableClient "oev_garage_store";}; //Bad data passed.

_vInfo = _vehicle getVariable["dbInfo",[]];

if(count _vInfo > 0) then {
	_plate = _vInfo select 1;
	_uid = _vInfo select 0;
};

if(_impound) then {
	if(count _vInfo isEqualTo 0) then {
		oev_impound_inuse = false;
		_ownerID publicVariableClient "oev_impound_inuse";
		if(!isNil "_vehicle" && {!isNull _vehicle}) then {
			life_serv_vehicles deleteAt (life_serv_vehicles find _vehicle);
			deleteVehicle _vehicle;
		};
	} else {
		//Is it a gang vehicle?
		if !(_vehGangID isEqualTo 0) then {
			// 使用 vehicleMapper 停用帮派车辆
			["setganginactive", [str _vehGangID, str _plate]] call DB_fnc_vehicleMapper;
		} else {
			// 使用 vehicleMapper 停用玩家车辆
			["setinactive", [_uid, str _plate]] call DB_fnc_vehicleMapper;
		};
		if(!isNil "_vehicle" && {!isNull _vehicle}) then {
			life_serv_vehicles deleteAt (life_serv_vehicles find _vehicle);
			deleteVehicle _vehicle;
		};
		oev_impound_inuse = false;
		_ownerID publicVariableClient "oev_impound_inuse";
	};
} else {
	//Is it a gang vehicle?
	if (_vehGangID isEqualTo _gangID) then {
		if(count _vInfo isEqualTo 0) exitWith {
			[1,(localize "STR_Garage_Store_NotPersistent")] remoteExec ["OEC_fnc_broadcast",_ownerID,false];
			oev_garage_store = false;
			_ownerID publicVariableClient "oev_garage_store";
		};
		// 使用 vehicleMapper 停用帮派车辆
		["setganginactive", [str _gangID, str _plate]] call DB_fnc_vehicleMapper;
		if(!isNil "_vehicle" && {!isNull _vehicle}) then {
			life_serv_vehicles deleteAt (life_serv_vehicles find _vehicle);
			deleteVehicle _vehicle;
		};
		oev_garage_store = false;
		_ownerID publicVariableClient "oev_garage_store";
		[1,(localize "STR_Garage_Store_Success")] remoteExec ["OEC_fnc_broadcast",_ownerID,false];
	} else {
		if(count _vInfo isEqualTo 0) exitWith {
			[1,(localize "STR_Garage_Store_NotPersistent")] remoteExec ["OEC_fnc_broadcast",_ownerID,false];
			oev_garage_store = false;
			_ownerID publicVariableClient "oev_garage_store";
		};

		if !(_uid isEqualTo getPlayerUID _unit) exitWith	{
			[1,(localize "STR_Garage_Store_NoOwnership")] remoteExec ["OEC_fnc_broadcast",_ownerID,false];
			oev_garage_store = false;
			_ownerID publicVariableClient "oev_garage_store";
		};

		// 使用 vehicleMapper 停用玩家车辆
		["setinactive", [_uid, str _plate]] call DB_fnc_vehicleMapper;
		if(!isNil "_vehicle" && {!isNull _vehicle}) then {
			life_serv_vehicles deleteAt (life_serv_vehicles find _vehicle);
			deleteVehicle _vehicle;
		};
		oev_garage_store = false;
		_ownerID publicVariableClient "oev_garage_store";
		[1,(localize "STR_Garage_Store_Success")] remoteExec ["OEC_fnc_broadcast",_ownerID,false];
	};
};