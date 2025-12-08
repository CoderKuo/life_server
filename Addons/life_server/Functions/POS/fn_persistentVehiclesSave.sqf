//	Author: Poseidon
//	Description: Checks all vehicles on map, and saves those which have an owner nearby to the database so they can be spawned next restart
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_dbInfo","_vehicle","_ownerID","_plate","_className","_position","_direction","_side","_tickTime","_trunkData","_gangID"];
_savedOwners = [];//Only allow 1 vehicle per person to be saved

_tickTime = diag_tickTime;

{
	_vehicle = _x;
	_dbInfo = _vehicle getVariable["dbInfo",[]];
	_side = _vehicle getVariable["side",""];
	_gangID = _vehicle getVariable ["gangID",0];

	if((count _dbInfo > 0) && (_side == "civ")) then {
		if !(_gangID isEqualTo 0) exitWith{};
		_ownerID = _dbInfo select 0;
		_plate = _dbInfo select 1;

		if(_ownerID in _savedOwners) exitWith {};//Player already has a vehicle saved

		_player = [_ownerID, false] call OES_fnc_getPlayer;

		if(isNull _player) exitWith {};//Player not online or error
		if(!isPlayer _player) exitWith {};

		_vehicle setVariable["trunkLocked",true,true];

		_className = typeof _vehicle;
		_position = getPos _vehicle;
		_direction = getDir _vehicle;

		if((_position select 2 > 20) && (speed _vehicle > 5)) exitWith {};//Vehicle is too far off ground and currently moving
		if(_player distance _position > 150) exitWith {};//Too far from their own vehicle, dont save it
		_savedOwners pushBack _ownerID;

		_position = [_position] call OES_fnc_escapeArray;

		_vehicle setVariable ["trunkLocked",true,true];
		_trunkData = _vehicle getVariable["Trunk",[[],0]];
		_trunkData = [_trunkData] call OES_fnc_escapeArray;

		// 使用 vehicleMapper 更新车辆库存和持久化状态
		["updateinventory", [_ownerID, _plate, _className, _trunkData, str olympus_server, _position, str _direction]] call DB_fnc_vehicleMapper;
	};
}foreach vehicles;

"------------- Persistent Vehicles Save  -------------" call OES_fnc_diagLog;
format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)] call OES_fnc_diagLog;
format["Total Persistent Vehicles: %1", count _savedOwners] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

olympusVehiclesSaved = true;

