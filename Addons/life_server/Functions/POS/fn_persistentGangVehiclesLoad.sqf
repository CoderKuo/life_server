//	Author: Poseidon
//	Description: Loads all persistent vehicles

private["_query","_queryResult","_new","_vehicleID","_side","_className","_type","_gangID","_plate","_color","_insured","_mods","_position","_direction","_name","_vehicle","_spawnedVehicles","_tickTime","_turbo","_inventory","_gangName","_owners","_string"];

_spawnedVehicles = [];
_tickTime = diag_tickTime;
_query = format["SELECT CONVERT(id, char), side, classname, type, gang_id, alive, active, plate, color, inventory, insured, modifications, persistentPosition, persistentDirection FROM "+dbColumGangVehicle+" WHERE alive='1' AND (active='0' OR active='%1') AND persistentServer='%1' AND side='%2'", olympus_server, "civ"];
_queryResult = [_query,2,true] call OES_fnc_asyncCall;

{
	//color & material array [color,material]
	_string = (_x select 8);
	_new = _string splitString "[,]";
	_new = [_new select 0, call compile (_new select 1)];
	if(_new isEqualType "") then {_new = call compile format["%1", _new];};
	_x set[8,_new];

	//vehicle gear/virtual inventory, not yet fully implemented, but fetch it anyways
	_new = [(_x select 9)] call OES_fnc_mresToArray;
	if(_new isEqualType "") then {_new = call compile format["%1", _new];};
	_x set[9,_new];

	//modification array, will contain values for each modification like armor, turbo, etc, max mods currently is 8
	_new = [(_x select 11)] call OES_fnc_mresToArray;
	if(_new isEqualType "") then {_new = call compile format["%1", _new];};
	_x set[11,_new];

	//format position data
	_new = (_x select 12);
	if(_new isEqualType "") then {_new = call compile format["%1", _new];};
	_x set[12,_new];
} forEach _queryResult;

{
	_vehicleID = _x select 0;
	_side = _x select 1;
	_className = _x select 2;
	_type = _x select 3;
	_gangID = _x select 4;
	_plate = _x select 7;
	_color = _x select 8;
	_inventory = _x select 9;
	_insured = _x select 10;
	_mods = _x select 11;
	_position = _x select 12;
	_position set[2, (_position select 2) + 2];
	_direction = _x select 13;
	_name = [format["SELECT playerid, name FROM gangmembers WHERE gangid='%1' AND rank='5'", _gangID],2] call OES_fnc_asyncCall;
	_gangName = [format["SELECT name FROM gangs WHERE id='%1'", _gangID],2] call OES_fnc_asyncCall;
	if(count _inventory isEqualTo 0) then {
		_inventory = [[],0];
	};

	serv_sv_use pushBack _vehicleID;

	_vehicle = createVehicle [_className,[random(1000),random(1000),random(1000)],[],0,"CAN_COLLIDE"];
	waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
	_vehicle allowDamage false;
	_vehicle lock 2;
	_vehicle setPos _position;
	_vehicle setDir _direction;
	_vehicle setVectorUp (surfaceNormal _position);
	_vehicle setPos _position;
	_vehicle setVelocity [0,0,-0.1];
	
	[] spawn{
		uiSleep 300;
		life_serv_vehicles pushBack _vehicle;
	};
	
	if(_vehicle isKindOf "Air") then {
		_vehicle addEventHandler ["RopeAttach", {
			if !(owner (currentPilot (_this select 0)) isEqualTo owner (_this select 2)) then {
				(_this select 2) setOwner (owner (currentPilot (_this select 0)));
			};
			if (count crew (_this select 2) > 0) then {
				hint "Warning! Slinging vehicles with players in them is unstable and the rope may break!";
				{
					['Warning! Slinging vehicles with players in them is unstable and the rope may break!'] remoteExec['hint',_x];
				} forEach (crew (_this select 2));
				[(_this select 2),(_this select 0),owner (currentPilot (_this select 0))] spawn{
					waitUntil{(count crew (_this select 0) isEqualTo 0) && (owner (currentPilot (_this select 1)) isEqualTo (_this select 2))};
					(_this select 0) setOwner (_this select 2);
				};
			};
		}];
	};

	_query = format["UPDATE "+dbColumGangVehicle+" SET active='%1', persistentServer='%2', persistentPosition='%3', persistentDirection='%4' WHERE gang_id='%5' AND id=%6",olympus_server, 0, [[0,0,0]] call OES_fnc_mresArray, 0,_gangID,_vehicleID];
	[_query,1] spawn OES_fnc_asyncCall;

	_spawnedVehicles pushBack _vehicle;

	_vehicle setVariable ["oev_veh_color",_color,true];
	[_vehicle,_color] remoteExec["OEC_fnc_colorVehicle",0,true];
	_owners = []; // NOTE THAT ON SERVER RESTART, THERE ARE NO OWNERS SET FOR THE GANG VEHICLE. A PERSON BECOMES AN OWNER IF THEY "Get Keys" THEIR GANG'S VEHICLE. MAY CAUSE ISSUES WITH OTHER FUNCTIONS IF NOONE GETS KEYS TO THE VEHICLE.  ALL KNOWN ISSUES ATM ARE FIXED, JUST A HEADS UP IF A SITUATION ARISES, LOOK HERE FIRST.
	_vehicle setVariable ["vehicle_info_owners",_owners,true];
	_vehicle setVariable ["gangID",_gangID,true];
	_vehicle setVariable ["gangName",_gangName,true];
	_vehicle setVariable ["dbInfo",[_name select 0,_plate],true];
	_vehicle setVariable ["defaultModMass",(getMass _vehicle),true];
	_vehicle setVariable ["insured",_insured,true];
	_vehicle setVariable ["trunk",_inventory,true];
	_vehicle setVariable ["side",_side,true];
	_vehicle setVariable ["modifications",_mods,true];
	_vehicle setVariable ["isBlackwater",false,true];
	//_vehicle addEventHandler ["Killed","[_this select 0] spawn OES_fnc_vehicleDead"];
	_vehicle enableRopeAttach false;

	// TODO : Keys for all gang members
	//[(_name select 0) select 0,civilian,_vehicle,1] call OES_fnc_keyManagement;

	_turbo = _mods select 0;
	switch (_turbo) do {
		case 0: {_turbo = 1;};
		case 1: {_turbo = 1.22;};
		case 2: {_turbo = 1.44;};
		case 3: {_turbo = 1.66;};
		case 4: {_turbo = 1.88;};
	};

	if(_turbo > 0) then {
		if(_type == "Air") then {
			_vehicle setMass ((getMass _vehicle)*(_turbo));
		} else {
			_vehicle setMass ((getMass _vehicle)/(_turbo));
		};
	};
	[_vehicle] call OEC_fnc_clearVehicleAmmo;


	if(_side == "civ" && _className == "B_Heli_Light_01_F") then {
		[_vehicle,"civ_littlebird",true] spawn OEC_fnc_vehicleAnimate;
	};

	serv_sv_use = serv_sv_use - [_vehicleID];

	_vehicle spawn {
		sleep 10;
		_this allowDamage true;
	};
} forEach _queryResult;

"------------- Persistent  Gang Vehicles Load  -------------" call OES_fnc_diagLog;
format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)] call OES_fnc_diagLog;
format["Total Persistent Vehicles: %1", count _spawnedVehicles] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

olympusGangVehiclesLoaded = true;
publicVariable "olympusGangVehiclesLoaded";

_spawnedVehicles spawn{
	private["_dbInfo","_side","_vehicle","_className","_gangID","_plate","_player","_query","_foundPlayer","_nearObjects"];
	sleep 900;//Wait 15 minutes
	{
		_vehicle = _x;

		_dbInfo = _vehicle getVariable["dbInfo",[]];
		_side = _vehicle getVariable["side",""];

		if((count _dbInfo > 0) && (_side == "civ")) then {
			if(count (crew  _vehicle) > 0) exitWith {};//Someones driving it
			if(!local _vehicle) exitWith {};//Vehicle is no longer local, someone else got in it

			_plate = _dbInfo select 1;
			_className = typeof _vehicle;
			_gangID = _vehicle getVariable ["gangID",0];
			if(_gangID IsEqualTo 0) exitWith {};
			_nearObjects = position _vehicle nearObjects ["Man",150];
			_foundPlayer = objNull;
			{
				if(!isNull _x) exitWith {};//If player is not null dont delete their car
				if(isPlayer _x) exitWith {};//If isPlayer
				if !((side _x) isEqualTo civilian) exitWith {};
				if !(((_x getVariable "gang_data") select 0) isEqualTo _gangID) exitWith {};
				_foundPlayer = _x;
			} forEach _nearObjects;

			if !(isNull _foundPlayer) then {
				deleteVehicle _vehicle;
				_query = format["UPDATE "+dbColumGangVehicle+" SET active='0' inventory='%4', persistentServer='0' WHERE gang_id='%1' AND plate='%2' AND classname='%3'",_gangID,_plate,_className, [[[],0]] call OES_fnc_mresArray];
				[_query,1] call OES_fnc_asyncCall;
			};
		};
	} forEach _this;
};
