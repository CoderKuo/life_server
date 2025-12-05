//  File: fn_spawnEventVehicles
//	Description: Spawns the specified vehicle type, or group of vehicles, or crates, at the requested location.

private["_player","_eventType","_eventLocation","_vehicleCategory","_spawnLocations","_markerLocation","_playerCount","_vehicleType","_nearVehicles","_vehicle","_selectedSpawn","_vehiclesSpawned","_incr1","_incr2","_index"];
_player = param [0,ObjNull,[ObjNull]];
_eventType = param [1,"",[""]];
_eventLocation = param [2,"",[""]];
_vehicleCategory = param [3,"",[""]];

if(isNull _player || _eventType == "" || _eventLocation == "" || _vehicleCategory == "") exitWith {};
_authorizedUsers = [];
//if(!((getPlayerUID _player) in _authorizedUsers)) exitWith {};

_vehicleCategory = call compile format["%1", _vehicleCategory];

switch(true) do {
	case (_eventLocation in ["kavalaToPyrgos","kavalaToSofia","kavalaToAthira"]): {_markerLocation = "kavala"};
	case (_eventLocation in ["pyrgosToKavala","pyrgosToSofia","pyrgosToAthira"]): {_markerLocation = "pyrgos"};
	case (_eventLocation in ["athiraToKavala","athiraToSofia","athiraToPyrgos"]): {_markerLocation = "athira"};
	case (_eventLocation in ["sofiaToKavala","sofiaToAthira","sofiaToPyrgos"]): {_markerLocation = "sofia"};
	case (_eventLocation in ["terminalDragRace"]): {_markerLocation = "terminalDrag"};
	case (_eventLocation in ["salt"]): {_markerLocation = "salt"};
	case (_eventLocation in ["mainEventArea"]): {_markerLocation = "mainEventArea"};
	case (_eventLocation in ["myPosition"]): {_markerLocation = "myPosition"};
	case (_eventLocation in ["mainAirport"]): {_markerLocation = "mainAirport"};
	case (_eventLocation in ["saltAirport"]): {_markerLocation = "saltAirport"};
	default {_markerLocation = "";};
};
if(_markerLocation == "") exitWith {systemChat "invalid marker";};

_playerCount = 0;
{
	if(((_x getVariable ["isInEvent",["no"]]) select 0) != "no") then {
		if (_eventType isEqualTo "tankbattle") then {
			_playerCount = _playerCount + 0.5;
		}else{
			_playerCount = _playerCount + 1;
		};
	};
}foreach playableUnits;

if(_playerCount == 0) exitWith {systemChat "0 players";};
if(_playerCount > 24) then {_playerCount = 24;};
_spawnLocations = [];

if(_markerLocation == "myPosition") then {
	_incr1 = 5;
	_incr2 = 5;
	for [{_i=0}, {_i<24}, {_i=_i+1}] do
	{
		_spawnLocations pushBack [((position _player) select 0) + _incr1,((position _player) select 1) + _incr2,((position _player) select 2) + 0.5];


		if(_incr1 == _incr2) then {
			_incr1 = _incr1 + 10;
		} else {
			_incr2 = _incr2 + 10;
		};
	};
}else{
	for [{_i=0}, {_i<24}, {_i=_i+1}] do
	{
		_spawnLocations pushBack (format["eventSpawn_%1_%2_%3",_markerLocation,_eventType,(_i + 1)]);
	};
};

_vehiclesSpawned = 0;
if(count _vehicleCategory == 1) then {
	_vehicleType = _vehicleCategory select 0;
	{
		if(_vehiclesSpawned >= _playerCount) exitWith {};
		if(_markerLocation == "myPosition") then {
			_selectedSpawn = _x;
		}else{
			_selectedSpawn = getMarkerPos(_x);
		};

		_nearVehicles = nearestObjects[_selectedSpawn,["Car","Air","Ship"],5];
		if(count _nearVehicles == 0) then {
			_vehicle = createVehicle [_vehicleType,_selectedSpawn,[],0,"NONE"];
			waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
			life_server_eventVehicles pushBack _vehicle;
			_vehicle allowDamage false;
			clearWeaponCargoGlobal _vehicle;
			clearMagazineCargoGlobal _vehicle;
			_vehicle setPos _selectedSpawn;
			_vehicle setVectorUp (surfaceNormal _selectedSpawn);
			_vehicle setDir markerDir _x;
			_vehicle lock 2;
			_vehicle setFuel 0;
			//_vehicle setVehicleAmmo 0;
			if (_eventType isEqualTo "escort") then
			{
				_vehicle setVariable["escortEventVehicle",true,true];
			};
			_vehicle setVariable["eventVehicle",true,true];
			_vehiclesSpawned = _vehiclesSpawned + 1;
			uiSleep 0.3;
		};
	}foreach _spawnLocations;
} else {
	_index = 0;
	{
		_vehicleType = _x;

		if(_markerLocation == "myPosition") then {
			_selectedSpawn = (_spawnLocations select _index);
		}else{
			_selectedSpawn = getMarkerPos(_spawnLocations select _index);
		};

		_nearVehicles = nearestObjects[_selectedSpawn,["Car","Air","Ship"],3];
		if(count _nearVehicles == 0) then {
			_vehicle = createVehicle [_vehicleType,_selectedSpawn,[],0,"NONE"];
			waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
			life_server_eventVehicles pushBack _vehicle;
			_vehicle allowDamage false;
			clearWeaponCargoGlobal _vehicle;
			clearMagazineCargoGlobal _vehicle;
			_vehicle setPos _selectedSpawn;
			//_vehicle setVehicleAmmo 0;
			_vehicle setVectorUp (surfaceNormal _selectedSpawn);
			_vehicle setFuel 0;

			for [{_i=0}, {_i<5}, {_i=_i+1}] do
			{
				_vehicle setObjectTextureGlobal [_i,'#(argb,8,8,3)color(0,0,0,1)']
			};

			_vehicle setDir (getDir _player);
			_vehicle lock 2;
			if (_eventType isEqualTo "escort") then
			{
				_vehicle setVariable["escortEventVehicle",true,true];
			};
			_vehicle setVariable["eventVehicle",true,true];
			uiSleep 0.3;
		};
		_index = _index + 1;
	}foreach _vehicleCategory;
};



