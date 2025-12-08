//	Author: Poseidon
//	Description: Checks all vehicles on map, and saves those which have an owner nearby to the database so they can be spawned next restart
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_dbInfo","_vehicle","_plate","_className","_position","_direction","_side","_tickTime","_trunkData","_gangID","_player","_savedOwners","_nearby"];
_savedOwners = 0;
_tickTime = diag_tickTime;
_nearby = false;
{
	_vehicle = _x;
	_gangID = _vehicle getVariable ["gangID",0];
	_dbInfo = _vehicle getVariable["dbInfo",[]];
	_side = _vehicle getVariable["side",""];

	if((count _dbInfo > 0) && (_side == "civ") && !(_gangID IsEqualTo 0)) then {
		_plate = _dbInfo select 1;

		_className = typeof _vehicle;
		_position = getPos _vehicle;
		_direction = getDir _vehicle;

		if((_position select 2 > 20) && (speed _vehicle > 5)) exitWith {};//Vehicle is too far off ground and currently moving

		_nearby = false;
		{
			if (side _x isEqualTo civilian) then {
				if (_gangID isEqualTo ((_x getVariable ["gang_data",[0,"",0]]) select 0)) then {
					if (_vehicle distance getPos _x < 150) then {_nearby = true;};
				};
			};
			if (_nearby) exitWith {};
		} forEach allPlayers;
		if !(_nearby) exitWith {};
		_vehicle setVariable ["trunkLocked",true,true];
		_trunkData = _vehicle getVariable["Trunk",[[],0]];
		_trunkData = [_trunkData] call OES_fnc_escapeArray;

		// 使用 vehicleMapper 更新帮派车辆库存和持久化状态
		["updateganginventory", [str _gangID, _plate, _className, _trunkData, str olympus_server, [_position] call OES_fnc_escapeArray, str _direction]] call DB_fnc_vehicleMapper;
		_savedOwners = _savedOwners + 1;
	};
} forEach vehicles;

"------------- Persistent Gang Vehicles Save  -------------" call OES_fnc_diagLog;
format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)] call OES_fnc_diagLog;
format["Total Persistent Vehicles: %1", _savedOwners] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

olympusGangVehiclesSaved = true;