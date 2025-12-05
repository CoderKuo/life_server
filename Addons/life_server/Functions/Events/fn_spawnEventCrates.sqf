//  File: fn_spawnEventCrates
//	Description: Spawns the specified vehicle type, or group of vehicles, or crates, at the requested location.

private["_player","_eventType","_eventLocation","_vehicleCategory","_spawnLocations","_markerLocation","_itemCargo","_backpackCargo","_magazineCargo","_weaponCargo","_playerCount","_vehicleType","_nearVehicles","_vehicle","_selectedSpawn","_vehiclesSpawned","_incr1","_incr2","_index"];
_player = param [0,ObjNull,[ObjNull]];
_eventType = param [1,"",[""]];
_eventLocation = param [2,"",[""]];
_vehicleCategory = param [3,"",[""]];

if(isNull _player || _eventType == "" || _eventLocation == "" || _vehicleCategory == "") exitWith {};
_authorizedUsers = [];
//if(!((getPlayerUID _player) in _authorizedUsers)) exitWith {};

_vehicleCategory = call compile format["%1", _vehicleCategory];

_markerLocation = "";
switch(true) do {
	case (_eventLocation in ["makrynisiLMS"]): {_markerLocation = "mainLMS"};
	default {_markerLocation = "";};
};

_playerCount = 0;
{
	if(((_x getVariable ["isInEvent",["no"]]) select 0) != "no") then {
		_playerCount = _playerCount + 1;
	};
}foreach playableUnits;
if(_playerCount == 0) exitWith {systemChat "0 players";};

_spawnLocations = [];
if(_markerLocation == "") then {
	_spawnLocations pushBack [((position _player) select 0) + 0.75,((position _player) select 1) + 0.75,((position _player) select 2) + 0.1];
} else {
	for [{_i=0}, {_i<24}, {_i=_i+1}] do
	{
		_spawnLocations pushBack (format["eventSpawn_%1_%2_%3",_markerLocation,_eventType,(_i + 1)]);
	};
};

if(count _vehicleCategory == 1) then {
	_vehicleType = _vehicleCategory select 0;
	_itemCargo = [];
	_backpackCargo = [];
	_magazineCargo = [];
	_weaponCargo = [];

	{
		if(_x isEqualType "") then {
			_selectedSpawn = getMarkerPos(_x);
		}else{
			_selectedSpawn = _x;
		};

		_vehicle = createVehicle ["Box_NATO_Wps_F",_selectedSpawn,[],0,"CAN_COLLIDE"];
		waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
		life_server_eventCrates pushBack _vehicle;
		_vehicle allowDamage false;
		_vehicle setPos _selectedSpawn;
		_vehicle setVectorUp (surfaceNormal _selectedSpawn);
		_vehicle setFuel 0;
		_vehicle setVehicleAmmo 0;
		_vehicle enableRopeAttach false;
		[_vehicle] call OEC_fnc_clearVehicleAmmo;
		clearBackpackCargoGlobal _vehicle;
		uiSleep 0.3;

		switch(_vehicleType) do {
			case "raceGear":{
				_itemCargo = [["ItemMap",34],["ItemGPS",34],["NVGoggles",34],["ToolKit",68],["FirstAidKit",136],
				["U_C_Driver_1_black",34],
				["U_C_Driver_1_blue",34],
				["U_C_Driver_1_green",34],
				["U_C_Driver_1_red",34],
				["U_C_Driver_1_white",34],
				["U_C_Driver_1_yellow",34],
				["U_C_Driver_1_orange",34],
				["H_RacingHelmet_1_black_F",34],
				["H_RacingHelmet_1_blue_F",34],
				["H_RacingHelmet_1_green_F",34],
				["H_RacingHelmet_1_red_F",34],
				["H_RacingHelmet_1_white_F",34],
				["H_RacingHelmet_1_yellow_F",34],
				["H_RacingHelmet_1_orange_F",34]];
				_backpackCargo = [["B_Carryall_cbr",34]];
			};

			case "escort":{
				_itemCargo = [["ItemMap",50],["ItemGPS",50]];
				_backpackCargo = [["B_Carryall_cbr",2]];
			};

			case "lmsDefault":{
				switch(round(random(9))) do {
					case 0:{
						_itemCargo = [["FirstAidKit",2],["V_BandollierB_khk",1],["NVGoggles",1]];
						_backpackCargo = [["B_AssaultPack_cbr",2]];
						_magazineCargo = [["30Rnd_556x45_Stanag",1],["16Rnd_9x21_Mag",2]];
						_weaponCargo = [["arifle_TRG21_F",1],["hgun_Rook40_F",2]];
					};

					case 1:{
						_itemCargo = [["NVGoggles",1]];
						_backpackCargo = [["B_Carryall_ocamo",1]];
						_magazineCargo = [["30Rnd_556x45_Stanag",3],["16Rnd_9x21_Mag",1],["HandGrenade",2]];
						_weaponCargo = [["arifle_SDAR_F",1],["arifle_Mk20C_plain_F",1],["hgun_Rook40_F",1]];
					};

					case 2:{
						_itemCargo = [["FirstAidKit",3],["NVGoggles",1]];
						_backpackCargo = [["B_AssaultPack_cbr",2]];
						_magazineCargo = [["16Rnd_9x21_Mag",2],["HandGrenade",1]];
						_weaponCargo = [["hgun_PDW2000_F",1]];
					};

					case 3:{
						_itemCargo = [["V_BandollierB_khk",1],["NVGoggles",1]];
						_magazineCargo = [["Chemlight_blue",2],["16Rnd_9x21_Mag",2]];
						_weaponCargo = [["hgun_PDW2000_F",1]];
					};

					case 4:{
						_itemCargo = [["FirstAidKit",2],["V_TacVest_brn",2],["NVGoggles",1]];
						_backpackCargo = [["B_AssaultPack_cbr",2]];
					};

					case 5:{
						_itemCargo = [["NVGoggles",1]];
						_backpackCargo = [["B_AssaultPack_cbr",1]];
						_magazineCargo = [["30Rnd_556x45_Stanag",4],["16Rnd_9x21_Mag",2],["Chemlight_blue",3]];
						_weaponCargo = [["arifle_SDAR_F",1],["arifle_TRG21_F",1]];
					};

					case 6:{
						_itemCargo = [["NVGoggles",1]];
						_magazineCargo = [["30Rnd_556x45_Stanag",5],["6Rnd_45ACP_Cylinder",4],["30Rnd_556x45_Stanag",5],["16Rnd_9x21_Mag",5]];
					};

					case 7:{
						_itemCargo = [["FirstAidKit",2],["V_TacVest_brn",1],["NVGoggles",1]];
						_magazineCargo = [["6Rnd_45ACP_Cylinder",2],["16Rnd_9x21_Mag",1]];
						_weaponCargo = [["hgun_PDW2000_F",1]];
					};

					case 8:{
						_itemCargo = [["FirstAidKit",2],["U_B_FullGhillie_sard",2],["NVGoggles",1]];
						_magazineCargo = [["6Rnd_45ACP_Cylinder",1]];
						_weaponCargo = [["arifle_TRG21_F",1]];
					};

					case 9:{
						_itemCargo = [["NVGoggles",1]];
						_magazineCargo = [["16Rnd_9x21_Mag",5],["6Rnd_45ACP_Cylinder",5],["30Rnd_556x45_Stanag",8]];
					};
				};
			};
		};

		if(count _itemCargo > 0) then {
			{
				_vehicle addItemCargoGlobal _x;
			}foreach _itemCargo;
		};

		if(count _magazineCargo > 0) then {
			{
				_vehicle addMagazineCargoGlobal _x;
			}foreach _magazineCargo;
		};

		if(count _weaponCargo > 0) then {
			{
				_vehicle addWeaponCargoGlobal _x;
			}foreach _weaponCargo;
		};

		if(count _backpackCargo > 0) then {
			{
				_vehicle addBackpackCargoGlobal _x;
			}foreach _backpackCargo;
		};

	}foreach _spawnLocations;
};