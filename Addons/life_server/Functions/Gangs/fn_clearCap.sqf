private["_flag","_deleted","_handle","_dbInfo","_gangID","_uid","_plate","_query","_illegal_vehicles"];
_flag = _this select 0;

_illegal_vehicles = ["O_T_LSV_02_armed_F","I_C_Offroad_02_LMG_F","I_G_Offroad_01_AT_F","B_T_LSV_01_armed_F","I_MRAP_03_F","B_MRAP_01_F","B_G_Offroad_01_armed_F","B_Heli_Transport_03_black_F","O_MRAP_02_F","O_Heli_Transport_04_bench_F","B_Heli_Transport_01_camo_F","C_Plane_Civil_01_racing_F","B_T_VTOL_01_vehicle_F","B_T_VTOL_01_infantry_F"];
{
	_deleted = false;

	if(!(typeOf _x in _illegal_vehicles) && !(_x getVariable["isBlackwater",false]) && ({alive _x} count crew _x == 0)) then {
		if(count (_x getVariable ["Trunk",[]]) != 0) then {
			if(((_x getVariable ["Trunk",[]]) select 1) != 0) exitWith {
				_deleted = true;
			};
		};
		if(_deleted) exitWith {};
		if(count crew _x != 0) then {
			private _handle = [_x] spawn OES_fnc_pulloutDead;
			waitUntil {uiSleep 0.5; scriptDone _handle;};
			_dbInfo = _x getVariable["dbInfo",[]];
			_gangID = _x getVariable ["gangID",0];
			deleteVehicle _x;
			_deleted = true;
		} else {
			_dbInfo = _x getVariable["dbInfo",[]];
			_gangID = _x getVariable ["gangID",0];
			deleteVehicle _x;
			_deleted = true;
		};

		if(_deleted) then {
			waitUntil {isNull _x};
			_deleted = false;
		};

		if(isNull _x) then {
			if(count _dbInfo > 0) then {
				_uid = _dbInfo select 0;
				_plate = _dbInfo select 1;
				if (_uid isEqualTo "" && _plate isEqualTo 0) exitWith {};
				if !(_gangID isEqualTo 0) then {
					_query = format["UPDATE "+dbColumGangVehicle+" SET active='0', persistentServer='0' WHERE gang_id='%1' AND plate='%2'",_gangID,_plate];
				} else {
					_query = format["UPDATE "+dbColumVehicle+" SET active='0', persistentServer='0' WHERE pid='%1' AND plate='%2'",_uid,_plate];
				};
				[_query,1] spawn OES_fnc_asyncCall;
			};
		};
	};
} forEach ((position _flag) nearEntities [["LandVehicle","Air","Ship"], 150]);

_flag setVariable["clearCooldown",(serverTime + 300),true];
