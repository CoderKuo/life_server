//	File: fn_clean1up.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description:
//	Server-side cleanup script on vehicles.
//	Sort of a lame way but whatever.


//alive vehicle cleanup
[] spawn{
private["_veh","_handle","_dbInfo","_gangID","_uid","_plate","_query","_ill","_toDelete","_dist"];
_ill = ["I_G_Offroad_01_AT_F","B_T_LSV_01_armed_F","O_T_LSV_02_armed_F","B_Heli_Transport_03_black_F","B_Heli_Transport_01_camo_F","B_Heli_Transport_01_F","C_Plane_Civil_01_racing_F","I_C_Offroad_02_LMG_F","B_G_Offroad_01_armed_F","I_G_Offroad_01_armed_F","B_T_VTOL_01_vehicle_F","B_T_VTOL_01_infantry_F","O_Heli_Transport_04_bench_F"];
	while{true} do {
		uiSleep 300; // 5 minutes each loop, one to check and one to yeet the vehicle, making despawn 10 minutes total
		_toDelete = [];
		{
			if(isNull _x) exitWith {
				_toDelete pushBack _forEachIndex;
			};
			_veh = _x;
			if !(typeOf _veh in _ill) then { _dist = 10; } else {_dist = 150;};
			if(_veh getVariable["unused",false] && !(_veh getVariable["markedForAntiDespawn",false])) then {
				if(({alive _x} count crew _veh) isEqualTo 0 && ({isPlayer _x} count ((getPos _veh) nearEntities["CAManBase",_dist])) isEqualTo 0) then {
					_dbInfo = _veh getVariable["dbInfo",[]];
					_gangID = _veh getVariable ["gangID",0];
					if !(count crew _veh isEqualTo 0) then {
						_handle = [_veh] spawn OES_fnc_pulloutDead;
						waitUntil {uiSleep 0.5; scriptDone _handle;};
					};
					deleteVehicle _veh;
					waitUntil {isNull _veh};
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
					_toDelete pushBack _forEachIndex;
					uiSleep 0.5;
				};
			} else {
				if(!((_veh getVariable["baited",false]) && (_veh getVariable["markedForAntiDespawn",false])) && {({alive _x} count crew _veh) isEqualTo 0} && {((_veh getVariable["Trunk",[[],0]]) select 1) isEqualTo 0}) then {
						_veh setVariable["unused",true,true];
				};
			};
		} forEach life_serv_vehicles;
		_toDelete sort false;
		{
			life_serv_vehicles deleteAt _x;
			uiSleep 0.1;
		} forEach _toDelete;
	};
};

[] spawn{
	while{true} do {
		uiSleep 120;
		{
			if !(_x isKindOf "Man") then {
				[_x] spawn OES_fnc_vehicleDead;
				uiSleep 0.5;
			};
		} forEach allDead;
	};
};

//Group cleanup
[] spawn{
	while {true} do {
		uiSleep (3 * 60);
		{
			if(count units _x == 0 && local _x) then {
				deleteGroup _x;
			};
		} foreach allGroups;
	};
};

// Cleanup dropped Y-inv
[] spawn{
	waitUntil {uiSleep 1; !serv_timeFucked};
	if ((count serv_yinv_cleanup) > 0) then {
		{
			_x set [1,serverTime + 900];

		} forEach serv_yinv_cleanup;
	};
	while {true} do	{
		uiSleep (15);

		{
			if ((_x select 1) <= serverTime) then {
			   deleteVehicle (_x select 0);
			   serv_yinv_cleanup deleteAt _forEachIndex;
			};
			uiSleep (0.5);
		} forEach serv_yinv_cleanup;
	};
};

// Cleanup robbed physcial items
[] spawn{
	waitUntil {uiSleep 1; !serv_timeFucked};
	if ((count serv_weaponholder_cleanup) > 0) then {
		{
			_x set [1,serverTime + 900];

		} forEach serv_weaponholder_cleanup;
	};
	while {true} do	{
		uiSleep (15);

		{
			if ((_x select 1) <= serverTime) then {
			   deleteVehicle (_x select 0);
			   serv_weaponholder_cleanup deleteAt _forEachIndex;
			};
			uiSleep (0.5);
		} forEach serv_weaponholder_cleanup;
	};
};

// Cleanup non-players that are dead?
[] spawn{
	private["_activeIDarr"];
	while {true} do {
		_activeIDarr = [];
		uiSleep (7.5 * 60); //10 minute cool-down before next cycle.

		{
			if(isPlayer _x) then {
				_activeIDarr pushBack getPlayerUID _x;
			};
		} forEach playableUnits;

		{
			if((getPlayerUID _x == "") && (!alive _x) && !(_x getVariable ["steam64ID","0"] in _activeIDarr)) then {
				deleteVehicle _x
			};
		} forEach allDeadMen;
	};
};

// Cleanup medic placeables
[] spawn{
	while {true} do {
		uiSleep (10 * 60);
		if(!(isNil "life_server_medicPlaceables")) then {
			{
				_placeTime = _x getVariable "placedTime";
				_placedBy = _x getVariable "placedBy";
				_unit = playableUnits select {getPlayerUID _x == _placedBy};
				if((count _unit) > 0) then {
					if(((_unit select 0) distance _x) > 1000) then {
						deleteVehicle _x;
						life_server_medicPlaceables deleteAt _forEachIndex;
					};
				}else{
					deleteVehicle _x;
					life_server_medicPlaceables deleteAt _forEachIndex;
				};
			} forEach life_server_medicPlaceables;
		};
	};
};
