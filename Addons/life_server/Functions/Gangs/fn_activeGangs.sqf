//	File: fn_activeGangs.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Monitors active gangs and updates the array.

[] spawn{
	private ["_gangID","_newGangs"];

	while {true} do {
		uiSleep 900;
		_newGangs = [];
		{
			if ((side _x) isEqualTo civilian) then {
				if (isNil {_x getVariable "gang_data"}) exitWith {};
				_gangID = ((_x getVariable "gang_data") select 0);
				_newGangs pushBackUnique _gangID;
			};
		} forEach allUnits;
		life_server_online_gangs = _newGangs;
	};
};