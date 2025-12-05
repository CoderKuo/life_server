//	File: fn_vehicleManager.sqf
//	Author: Poseidon
//	Description: Disables or enables simulation on vehicles/units when necessary to potentially increase server performance

/*
[] spawn{
	private ["_units"];
	uiSleep 180;
	while {true} do {
	_units = [15101.8,16846.1,0.00143814] nearEntities [["Man"],20000];

	{
		if(simulationEnabled _x) then {
			_x enableSimulation false;
		};
	}forEach _units;
	uiSleep 300;
	};
};


[] spawn{
	private ["_vehicles"];
	uiSleep 180;
	while {true} do {
		_vehicles = [15101.8,16846.1,0.00143814] nearEntities [["LandVehicle"],20000];

		{
			if(!(_x in life_server_monitored_vehicles)) then {
				life_server_monitored_vehicles pushBack _x;
			};
		}forEach _vehicles;

		{
			if(_x in _vehicles) then {
				if(count crew _x != 0) then {
					if(!(simulationEnabled _x)) then {
						_x enableSimulation true;
					};
				} else {
					if(!(simulationEnabled _x)) then {
						_x enableSimulation false;
					};
				};
			} else {
				life_server_monitored_vehicles = life_server_monitored_vehicles - [_x];
			};
		}forEach life_server_monitored_vehicles;

		uiSleep 1;
	};
};
*/

[] spawn{
	private["_count"];
	while{true} do {
		sleep 300;
		{
			if(typeof _x == "#lightpoint" || typeof _x == "#dynamicsound") then {
				if(local _x) then {
					deleteVehicle _x;
				}else{
					_x enableSimulation false;
				};
			};
		}foreach (allMissionObjects "");
		//format["Light and Sound cleanup -- Deleted %1 objects.",_count] call OES_fnc_diagLog;
	};
};