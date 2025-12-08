//	Author: Poseidon
//	Description: Loads all persistent vehicles
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_queryResult","_new","_vehicleID","_side","_className","_type","_gangID","_plate","_color","_insured","_mods","_position","_direction","_name","_vehicle","_spawnedVehicles","_tickTime","_turbo","_inventory","_gangName","_owners","_string"];

_spawnedVehicles = [];
_tickTime = diag_tickTime;

// 使用 vehicleMapper 获取持久化帮派车辆
_queryResult = ["getgangpersistent", [str olympus_server, "civ"]] call DB_fnc_vehicleMapper;
if (isNil "_queryResult" || {!(_queryResult isEqualType [])} || {count _queryResult == 0}) then {
	_queryResult = [];
	"[persistentGangVehiclesLoad] 没有持久化帮派车辆数据" call OES_fnc_diagLog;
};

{
	if (isNil "_x" || {!(_x isEqualType [])} || {count _x < 14}) then { continue; };

	// 解析 JSONB 数据
	_x set [8, [_x select 8, ["", 0]] call DB_fnc_parseJsonb];
	_x set [9, [_x select 9, [[], 0]] call DB_fnc_parseJsonb];
	_x set [11, [_x select 11, [0,0,0,0,0,0,0,0]] call DB_fnc_parseJsonb];
	_x set [12, [_x select 12, [0, 0, 0]] call DB_fnc_parseJsonb];
} forEach _queryResult;

{
	if (isNil "_x" || {!(_x isEqualType [])} || {count _x < 14}) then { continue; };
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
	// 使用 gangMapper 获取帮派领导者和名称
	_name = ["getgangleader", [str _gangID]] call DB_fnc_gangMapper;
	if (isNil "_name" || {count _name == 0}) then { _name = [["", "Unknown"]]; };
	_gangName = ["getgangname", [str _gangID]] call DB_fnc_gangMapper;
	if (isNil "_gangName" || {count _gangName == 0}) then { _gangName = "Unknown"; } else { _gangName = _gangName select 0; };
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

	// 使用 vehicleMapper 更新帮派车辆持久化状态
	["updategangpersistent", [str _gangID, _vehicleID, str olympus_server, "0", [[0,0,0]] call OES_fnc_escapeArray, "0"]] call DB_fnc_vehicleMapper;

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
				// 使用 vehicleMapper 更新帮派车辆库存和持久化状态
				["updateganginventory", [str _gangID, _plate, _className, [[[],0]] call OES_fnc_escapeArray, "0", [[0,0,0]] call OES_fnc_escapeArray, "0"]] call DB_fnc_vehicleMapper;
			};
		};
	} forEach _this;
};
