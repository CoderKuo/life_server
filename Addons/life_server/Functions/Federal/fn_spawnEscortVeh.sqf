// File: fn_spawnEscortVeh.sqf
// Author: Jesse "tkcjesse" Schultz

params [
	["_vehicleClass","",[""]],
	["_position",[],[[]]],
	["_direction",0,[0]]
];

if !(isClass (configFile >> "CfgVehicles" >> _vehicleClass)) exitWith {};

{deleteVehicle _x;} forEach nearestObjects[_position,["Car","Air","Ship","Armored","Submarine"],8];

private _vehicle = createVehicle [_vehicleClass,_position,[],0,"NONE"];
waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
_vehicle allowDamage false;
_vehicle setDir _direction;

if (_vehicleClass in ["O_Truck_03_repair_F","O_Truck_03_ammo_F","B_Truck_01_ammo_F"]) then {
	serv_escortDriver = "";
	serv_escortTruck = _vehicle;
	publicVariable "serv_escortTruck";
};

if (_vehicleClass isEqualTo "O_LSV_02_armed_F") then {serv_escortQilin = _vehicle;};

_vehicle spawn{
	sleep 3;
	_this allowDamage true;
};

[_vehicle,"civ"] call OEC_fnc_clearVehicleAmmo;

_vehicle setVariable ["isEscort",true,true];
_vehicle setVariable ["dbinfo","1234",true];
_vehicle setVariable ["side","civ",true];
_vehicle setVariable ["vehicle_info_owners",["01234","Escort Vehicle"],true];
_vehicle setVariable ["defaultModMass",(getMass _vehicle),true];
_vehicle setVariable ["modifications",[0,0,0,0,0,0,0,0],true];
_vehicle setVariable ["insured",0,true];
//_vehicle addEventHandler ["Killed","[_this select 0] spawn OES_fnc_vehicleDead"];
_vehicle enableRopeAttach false;
_vehicle enableVehicleCargo false; //Prevents vehicle from being carried in blackfish :)

if (_vehicleClass in ["O_Truck_03_repair_F","O_Truck_03_ammo_F","B_Truck_01_ammo_F"]) then {
	[_vehicle] spawn{
		params [["_vehicle",objNull,[objNull]]];
		private _driver = "";
		private _vehClass = (typeOf _vehicle);
		private _vehName = switch (_vehClass) do {
			case "O_Truck_03_repair_F": {"Zamak"};
			case "O_Truck_03_ammo_F": {"Tempest"};
			case "B_Truck_01_ammo_F": {"Hemtt"};
			case "O_LSV_02_armed_F": {"Armed Qilin"};
		};

		private _exit = false;
		while {true} do {
			uiSleep 1;
			if (((escort_status select 1) <= serverTime) && !((escort_status select 1) isEqualTo 0)) then {
				[3,"<t color='#ff2222'><t size='2.2'><t align='center'>Escort Failed<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Altis Pharmaceutical Company has remotely activated the vehicles anti-theft features and the vehicle will be destroyed in 20 seconds!",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
				uiSleep 20;
				if (_vehClass isEqualTo "O_Truck_03_ammo_F") then {
					serv_escortQilin setDamage 1;
					deleteMarker format["escortveh_%1", (typeOf serv_escortQilin)];
					deleteMarker format["escortvehoutline_%1",(typeOf serv_escortQilin)];
					serv_escortQilin = objNull;
				};
				_vehicle setDamage 1;
				serv_escortCooldown = (serverTime + 1800);
				escort_status = [false,0];
				publicVariable "escort_status";
				_exit = true;
				uiSleep 5;
				deleteVehicle _vehicle;
				deleteMarker format["escortveh_%1", (typeOf serv_escortTruck)];
				deleteMarker format["escortvehoutline_%1",(typeOf serv_escortTruck)];
				{deleteMarker _x;}forEach ["dropOne","dropTwo","dropThree"];
			};

			if (_exit) exitWith {};

			if (isNull _vehicle || !(alive _vehicle)) then {
				uiSleep 20;

				if !(escort_status select 0) then {
					[1,format ["The %1 involved in the Pharmaceutical Companies theft has been sold, recovered, or destroyed.",_vehName]] remoteExec ["OEC_fnc_broadcast",-2,false];
					_exit = true;
					uiSleep 5;
					deleteVehicle _vehicle;
					deleteMarker format["escortveh_%1", (typeOf serv_escortTruck)];
					deleteMarker format["escortvehoutline_%1",(typeOf serv_escortTruck)];
					{deleteMarker _x;}forEach ["dropOne","dropTwo","dropThree"];
					serv_escortCooldown = (serverTime + 1800);
					serv_escortTruck = objNull;
					escort_status = [false,0];
					publicVariable "escort_status";
				};

				if ((_vehClass isEqualTo "O_Truck_03_ammo_F") && !(_exit)) then {
					uiSleep 10;
					if !(isNull serv_escortQilin) then {
						[3,"<t color='#ff2222'><t size='2.2'><t align='center'>Escort Cleanup<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Altis Pharmaceutical Company has remotely activated the Armed Qilins anti-theft features and the vehicle will be destroyed in 20 seconds!",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
						uiSleep 20;
						serv_escortQilin setDamage 1;
						serv_escortQilin = objNull;
						deleteMarker format["escortveh_%1", (typeOf serv_escortQilin)];
						deleteMarker format["escortvehoutline_%1",(typeOf serv_escortQilin)];
					};
					_exit = true;
					uiSleep 5;
					deleteVehicle _vehicle;
					deleteMarker format["escortveh_%1", (typeOf serv_escortTruck)];
					deleteMarker format["escortvehoutline_%1",(typeOf serv_escortTruck)];
					{deleteMarker _x;}forEach ["dropOne","dropTwo","dropThree"];
					serv_escortTruck = objNull;
					escort_status = [false,0];
					publicVariable "escort_status";
					serv_escortCooldown = (serverTime + 1800);
				};

				if ((_vehClass isEqualTo "O_LSV_02_armed_F") && !(_exit)) then {
					if !(isNull serv_escortQilin) then {
						uiSleep 10;
						[3,"<t color='#ff2222'><t size='2.2'><t align='center'>Escort Cleanup<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Armed Qilin from the Altis Pharmaceutical Company robbery has been seized or destroyed.!",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
					};
					serv_escortQilin = objNull;
					_exit = true;
					uiSleep 5;
					deleteVehicle _vehicle;
					deleteMarker format["escortveh_%1", (typeOf serv_escortQilin)];
					deleteMarker format["escortvehoutline_%1",(typeOf serv_escortQilin)];
					{deleteMarker _x;}forEach ["dropOne","dropTwo","dropThree"];
				};

				if (((_vehClass isEqualTo "B_Truck_01_ammo_F") || (_vehClass isEqualTo "O_Truck_03_repair_F")) && !(_exit)) then {
					_exit = true;
					serv_escortDriver = "";
					serv_escortCooldown = (serverTime + 1800);
					escort_status = [false,0];
					publicVariable "escort_status";
					uiSleep 5;
					deleteVehicle _vehicle;
					deleteMarker format["escortveh_%1", (typeOf serv_escortTruck)];
					deleteMarker format["escortvehoutline_%1",(typeOf serv_escortTruck)];
					{deleteMarker _x;}forEach ["dropOne","dropTwo","dropThree"];
					serv_escortTruck = objNull;
				};

				if (!(_vehClass isEqualTo "O_LSV_02_armed_F") && !(_exit)) then {
					_exit = true;
					serv_escortDriver = "";
					serv_escortCooldown = (serverTime + 1800);
					escort_status = [false,0];
					publicVariable "escort_status";
					uiSleep 5;
					deleteVehicle _vehicle;
					deleteMarker format["escortveh_%1", (typeOf serv_escortTruck)];
					deleteMarker format["escortvehoutline_%1",(typeOf serv_escortTruck)];
					{deleteMarker _x;}forEach ["dropOne","dropTwo","dropThree"];
					serv_escortTruck = objNull;
				};
			};

			if (_exit) exitWith {};

			if (!((getPlayerUID (driver _vehicle)) isEqualTo _driver) && !((getPlayerUID (driver _vehicle)) isEqualTo "")) then {
				_driver = getPlayerUID (driver _vehicle);
				serv_escortDriver = _driver;
			};
		};
	};
};



[_vehicle] spawn{
	params [["_vehicle",objNull,[objNull]]];
	private _classname = typeOf _vehicle;
	private _time = switch (_classname) do {
		case "O_Truck_03_repair_F": {60};
		case "O_Truck_03_ammo_F": {60};
		case "B_Truck_01_ammo_F": {60};
		case "O_LSV_02_armed_F": {120};
	};

	_marker = createMarker [format["escortveh_%1",(typeOf _vehicle)],(getPos _vehicle)];
	_markerOutline = createMarker [format["escortvehoutline_%1",(typeOf _vehicle)],(getPos _vehicle)];

	private _pos = (getPos _vehicle);
	if (random(175) >= 100) then {
		_pos = [((_pos select 0) + random(170)), ((_pos select 1) + random(170))];
	} else {
		_pos = [((_pos select 0) - random(170)), ((_pos select 1) - random(170))];
	};

	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerBrush "FDiagonal";
	_marker setMarkerSize [200, 200];
	_marker setMarkerColor "ColorCIV";
	_marker setMarkerPos [_pos select 0, _pos select 1];

	_markerOutline setMarkerShape "ELLIPSE";
	_markerOutline setMarkerBrush "Border";
	_markerOutline setMarkerSize [200, 200];
	_markerOutline setMarkerColor "ColorCIV";
	_markerOutline setMarkerPos [_pos select 0, _pos select 1];

	private _int = 0;
	while {true} do {
		uiSleep _time;
		if (isNull _vehicle || !(alive _vehicle)) exitWith {
			deleteMarker _marker;
			deleteMarker _markerOutline;
		};
		if !(escort_status select 0) exitWith {};
		if ((escort_status select 1) <= serverTime) exitWith {};

		_pos = getPos _vehicle;
		if (random(175) >= 100) then {
			_pos = [((_pos select 0) + random(170)), ((_pos select 1) + random(170))];
		} else {
			_pos = [((_pos select 0) - random(170)), ((_pos select 1) - random(170))];
		};
		_marker setMarkerPos [_pos select 0, _pos select 1];
		_markerOutline setMarkerPos [_pos select 0, _pos select 1];

		[0,"The Pharmaceutical vehicle locations have been updated."] remoteExec ["OEC_fnc_broadcast",-2,false];
		if (_int > 3) then {
			_time = _time + 15;
		};
		_int = _int + 1;
	};

	if !(isNil _marker) then {deleteMarker _marker;};
	if !(isNil _markerOutline) then {deleteMarker _markerOutline;};
};
