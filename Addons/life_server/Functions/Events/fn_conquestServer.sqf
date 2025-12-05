// File: fn_conquestServer.sqf
// Author: Civak

private ["_fnc_autoStart","_fnc_cleanup","_fnc_checkWin","_fnc_deathPrice","_zones","_markName","_startX","_startY","_endX","_endY","_endIdx","_lineName","_flag","_buildings","_veh","_vehicleClass","_units","_lockedChop"];
params [
	["_mode", "", [""]],
	["_bool", false, [false]],
	["_vars", [], [[],0]],
	["_ID", -1, [-1]]
];

// [ ZoneName, PointPositions, ZonePoly]
_zones = [
	["Ghost Hotel", [ [21980.107,21035.193,0],[23620.52,21078.857,0],[22422.44,20011.785,0] ], [ [23050.629,21847.943,0],[24186.055,21492.576,0],[23838.908,20403.652,0],[22453.787,19368.78,0],[21684.2,19945.623,0],[21397.473,21163.564,0] ]],
	["Nifi", [ [18366.957,15525.622,0],[19409.207,15389.239,0],[18551.406,14661.3,0] ], [ [19545.887,16041.155,0],[20156.535,15469.738,0],[20029.672,14402.67,0],[18232.605,14422.520,0],[17650.369,15792.173,0],[18446.352,16273.845,0] ]],
	["Kavala", [ [6460.088,13773.676,0],[7701.869,14354.458,0],[7524.256,12829.32,0] ], [ [7273.354,15584.284,0],[8528.051,14909.702,0],[8552.593,13074.955,0],[7350.592,12173.107,0],[5680.194,13794.09,0] ]],
	["Syrta", [ [8386.573,18246.102,0],[10329.974,17991.703,0],[9210.08,19282.574,0] ], [ [10872.613,19782.01,0],[11536.093,18478.842,0],[10373.243,17009.912,0],[8504.066,17098.674,0],[7587.297,18417.629,0],[8381.020,19973.844,0] ]],
	["Oreokastro", [ [3778.348,21496.563,0],[4887.847,21929.684,0],[3536.734,19982.57,0] ], [ [5654.07,22528.244,0],[6298.479,21317.852,0],[5289.289,20124.133,0],[3398.640,19368.648,0],[2699.221,20390.408,0],[3296.478,22198.137,0] ]],
	["Warzone", [ [9777.72,9382,0],[12099,10482,0],[11207,8701,0],[8926,7479,0],[11555,7040.68,0] ], [ [9947,10882,0],[12525,10880,0],[14480,6747,0],[13911,5935,0],[8534,5940,0],[7864,6698,0],[7875,7210,0] ]],
	["Panagia", [ [20228,8928,0],[22715,6917,0],[20059,6739,0] ], [ [23762.1,5670.82,0],[19604.5,5718.92,0],[18581.7,8493.94,0],[20160.2,10021.6,0],[23385.7,9444.38,0] ]],
	["Sofia", [ [26001,22571,0],[25400,20316,0],[26762,21200,0] ], [ [25979,23114,0], [27085,22363,0], [27200,20786,0],[25249,19590,0], [23698,21270,0], [24559,22360,0]]]
];

_fnc_deathPrice = {
	if (_vars < 0) exitWith {};
	if (_bool) then {
		oev_conquestServ set [3, (oev_conquestServ select 3) + _vars];
	} else {
		oev_conquestServ set [3, (oev_conquestServ select 3) - _vars];
	};
};

_fnc_checkWin = {
	if (count (oev_conquestData select 2) > 0 && count (oev_conquestData select 3) > 0) then {
		(oev_conquestData select 3) find (oev_conquestData select 7);
	} else {
		-1;
	};
};

_fnc_cleanup = {
	{
		["removeAction", _x, _this select 2] remoteExec ["OEC_fnc_conquestClient", -2, _x];
	} forEach (_this select 1 select 2);
	{
		deleteMarker _x;
	} forEach (_this select 1 select 0) + (_this select 1 select 1);
	uiSleep 300;
	{
		deleteVehicle _x;
	} forEach (_this select 1 select 2);
};

_lcl_cleanMarkers = {
	switch (oev_conquestData select 1 select 0) do {
		case "Ghost Hotel": {"conq_spawn_0" setMarkerType "empty";};
		case "Nifi": {"conq_spawn_1" setMarkerType "empty";};
		case "Kavala": {"conq_spawn_2" setMarkerType "empty";};
		case "Syrta": {"conq_spawn_3" setMarkerType "empty";};
		case "Oreokastro": {"conq_spawn_4" setMarkerType "empty";};
		case "Warzone": {
			"conq_spawn_5_1" setMarkerType "empty";
			"conq_spawn_5_2" setMarkerType "empty";
		};
		case "Panagia": {"conq_spawn_7" setMarkerType "empty";};
		case "Sofia": {"conq_spawn_8" setMarkerType "empty";};
	};
};

_fnc_autoStart = {
	oev_conquestData set [0, true];
	private _newZone = selectRandom _zones;
	//Zone indexes; Zones with an index not specified here will result in random
	if (_vars isEqualType 0 && {_vars in [0,1,2,3,4,5,6,7]}) then {
		_newZone = _zones select _vars;
	};

	[
		["event","Conquest Started"],
		["location",_newZone]
	] call OES_fnc_logIt;

	oev_conquestServ set [3, 10000000];
	oev_conquestData set [1, [_newZone select 0, _newZone select 2]];
	publicVariable "oev_conquestData";

	conquestDeaths = [];
	"oev_conquest_add_homie" addPublicVariableEventHandler {
		_data = _this select 1;
		if (count _data != 3) exitWith {};
		if ({(_x select 0) isEqualTo (_data select 0)} count conquestDeaths == 0) then {
			conquestDeaths pushBack (_data);
		};
	};

	//[6, format ["Capture zones near %1 will be available in 15 minchautes.", _newZone select 0]] remoteExec ["OEC_fnc_broadcast", civilian];

	{
		_markName = format ["conqPoint_%1", _forEachIndex];
		createMarker [_markName, _x];
		_markName setMarkerColor "ColorOrange";
		_markName setMarkerShape "ICON";
		_markName setMarkerType "mil_warning";
		_markName setMarkerText format [" Capture Point %1", ['Alpha','Bravo','Charlie','Delta','Echo'] select _forEachIndex];
		(oev_conquestServ select 0) pushBack _markName;
	} forEach (_newZone select 1);

	{
		_endIdx = if (_forEachIndex + 1 >= count (_newZone select 2)) then [{0}, {_forEachIndex + 1}];
		_startX = _x select 0;
		_startY = _x select 1;
		_endX = ((_newZone select 2) select _endIdx) select 0;
		_endY = ((_newZone select 2) select _endIdx) select 1;

		_lineName = format ["conqLine_%1", _forEachIndex];
		createMarker [_lineName, [(_startX + _endX) / 2, (_startY + _endY) / 2]];
		_lineName setMarkerShape "RECTANGLE";
		_lineName setMarkerSize [50, ((((_endX - _startX) ^ 2 + (_endY - _startY) ^ 2) ^ 0.5) * 0.5) + 25];
		_lineName setMarkerDir ((_endX - _startX) atan2 (_endY - _startY));
		_lineName setMarkerBrush "FDiagonal";
		_lineName setMarkerColor "ColorOrange";
		(oev_conquestServ select 1) pushBack _lineName;
	} forEach (_newZone select 2);

	oev_conquestData set [7, 3000];
	switch (oev_conquestData select 1 select 0) do {
		case "Ghost Hotel": {"conq_spawn_0" setMarkerType "mil_triangle"; "conq_spawn_0" setMarkerSize[1.2,1.2];_lockedChop="chop_shop_2";};
		case "Nifi": {"conq_spawn_1" setMarkerType "mil_triangle"; "conq_spawn_1" setMarkerSize[1.2,1.2];_lockedChop="chop_shop_5";};
		case "Kavala": {"conq_spawn_2" setMarkerType "mil_triangle"; "conq_spawn_2" setMarkerSize[1.2,1.2];_lockedChop="chop_shop_3";};
		case "Syrta": {"conq_spawn_3" setMarkerType "mil_triangle"; "conq_spawn_3" setMarkerSize[1.2,1.2];_lockedChop="chop_shop_1";};
		case "Oreokastro": {"conq_spawn_4" setMarkerType "mil_triangle"; "conq_spawn_4" setMarkerSize[1.2,1.2];_lockedChop="chop_shop_3";};
		case "Warzone": {
			"conq_spawn_5_1" setMarkerType "mil_triangle";
			"conq_spawn_5_1" setMarkerSize[1.2,1.2];
			"conq_spawn_5_2" setMarkerType "mil_triangle";
			"conq_spawn_5_2" setMarkerSize[1.2,1.2];
			_lockedChop="chop_shop_1";
			oev_conquestData set [7, 5000];
		};
		case "Panagia": {"conq_spawn_7" setMarkerType "mil_triangle"; "conq_spawn_7" setMarkerSize[1.2,1.2];_lockedChop="chop_shop_5"};
		case "Sofia": {"conq_spawn_8" setMarkerType "mil_triangle"; "conq_spawn_8" setMarkerSize[1.2,1.2];_lockedChop="chop_shop_2"};
	};
	playableUnits apply {_x setVariable["conquestDeath",false,true]};

	[3] call OES_fnc_changeWeather;

	_exit = false;
	[6, format ["Capture zones near %1 will be available in 10 minutes.", _newZone select 0]] remoteExec ["OEC_fnc_broadcast", civilian];
	for "_i" from 0 to 300 do {
		if (oev_cancelConq) exitWith {
			[6, format ["Conquest at %1 has been canceled!", _newZone select 0]] remoteExec ["OEC_fnc_broadcast", civilian];
			{
				deleteMarker _x;
			} forEach (oev_conquestServ select 0) + (oev_conquestServ select 1);
			[] call _lcl_cleanMarkers;
			oev_cancelConq = false;
			oev_conquestData = [ false, ["", []], [], [], 0, [], [[],[],[]], 3000];
			oev_conquestServ = [ [], [], [], 0 ];
			publicVariable "oev_conquestData";
			_exit = true;
		};
		uiSleep 1;
	};
	if(_exit) exitWith {};
	[6, format ["Capture zones near %1 will be available in 5 minutes.", _newZone select 0]] remoteExec ["OEC_fnc_broadcast", civilian];
	uiSleep 240;
	[6, format ["Capture zones near %1 will be available in 1 minute.", _newZone select 0]] remoteExec ["OEC_fnc_broadcast", civilian];
	uiSleep 60;
	[6, format ["Capture zones near %1 are available for capture!", _newZone select 0]] remoteExec ["OEC_fnc_broadcast", civilian];

	oev_conqChop = _lockedChop;
	publicVariable "oev_conqChop";

	{
		_x setMarkerColor "ColorRed";
	} forEach (oev_conquestServ select 0) + (oev_conquestServ select 1);
	{
		{
			[_x] call OES_fnc_deletedVehStore;
		} forEach (nearestObjects [_x, ["Car","Air","Ship"], 10]);

		_flag = createVehicle ["Flag_White_F", _x, [], 0, "CAN_COLLIDE"];
		_flag setVariable ["owner", [-1], true];
		_flag setVariable ["phonetic", ["Alpha", "Bravo", "Charlie", "Delta", "Echo"] select _forEachIndex, true];
		["addAction", _flag] remoteExec ["OEC_fnc_conquestClient", -2, _flag];
		(oev_conquestServ select 2) pushBack _flag;
	} forEach (_newZone select 1);

	_buildings = (oev_conquestServ select 2 select 0) nearObjects ["House_F",3000];
	{
		if((position _x inPolygon (oev_conquestData select 1 select 1)) && ((count (_x getVariable "house_owner") > 0) || (count (_x getVariable "keyPlayers") > 0)) ) then {
			private _numOfDoors = getNumber(configFile >> "CfgVehicles" >> (typeOf _x) >> "numberOfDoors");
			for "_i" from 1 to _numOfDoors do {
				_x setVariable[format["bis_disabled_Door_%1",_i],0,true];
			};
		};
	} forEach _buildings;

	private _first = [-1, 0, ""];
	private _second = [-1, 0, ""];
	private _third = [-1, 0, ""];
	while {call _fnc_checkWin == -1} do {
		uiSleep 5;
		private _changed = false;
		{
			private _owner = _x getVariable ["owner", [-1]];
			if !(_owner select 0 isEqualTo -1) then {
				if (!((_owner select 2) getVariable["bigGangCD",serverTime] > serverTime) && !({position _x inPolygon (oev_conquestData select 1 select 1)} count units (_owner select 2) > 12)) then {
					private _idx = oev_conquestData select 2 find (_owner select 0);
					if (_idx != -1) then {
						(oev_conquestData select 3) set [_idx, ((oev_conquestData select 3 select _idx) + 5) min (oev_conquestData select 7)];
					} else {
						(oev_conquestData select 2) pushBack (_owner select 0);
						(oev_conquestData select 3) pushBack 5;
						(oev_conquestData select 5) pushBack (_owner select 1);
					};
					_changed = true;
				} else {
					if !((_owner select 2) getVariable["bigGangCD",serverTime] > serverTime) then {
						(_owner select 2) setVariable["bigGangCD",serverTime+300,true];
						[1, "Your group or gang is now on a 5 minute point capture cooldown for fighting Conquest with more than 12 players!"] remoteExec["OEC_fnc_broadcast", (_owner select 2)];
					};
				};
			};
		} forEach (oev_conquestServ select 2);
		// 5 second prize pool update
		if (oev_conquestData select 4 != oev_conquestServ select 3) then {
			oev_conquestData set [4, oev_conquestServ select 3];
			_changed = true;
		};
		if (_changed) then {
			_first = [-1, 0, ""];
			_second = [-1, 0, ""];
			_third = [-1, 0, ""];
			{
				if (_x > (_first select 1)) then {
					if ((oev_conquestData select 2 select _forEachIndex) != (_first select 0)) then {
						_third = _second;
						_second = _first;
					};
					_first = [(oev_conquestData select 2) select _forEachIndex, _x, (oev_conquestData select 5) select _forEachIndex];
				} else {
					if (_x > (_second select 1)) then {
						if ((oev_conquestData select 2 select _forEachIndex) != (_second select 0)) then {
							_third = _second;
						};
						_second = [(oev_conquestData select 2) select _forEachIndex, _x, (oev_conquestData select 5) select _forEachIndex];
					} else {
						if (_x > (_third select 1)) then {
							_third = [(oev_conquestData select 2) select _forEachIndex, _x, (oev_conquestData select 5) select _forEachIndex];
						};
					};
				};
			} forEach (oev_conquestData select 3);
			oev_conquestData set [6, [_first, _second, _third]];
			publicVariable "oev_conquestData";
		};
	};

	private _sortedScores = [];
	private _totalScores = 0;
	{
		_sortedScores pushBack [_x, oev_conquestData select 3 select _forEachIndex];
		_totalScores = _totalScores + (oev_conquestData select 3 select _forEachIndex);
	} forEach (oev_conquestData select 2);
	_sortedScores = [_sortedScores, [], {_x select 1}, "DESCEND"] call BIS_fnc_sortBy;

	[] call _lcl_cleanMarkers;

	[6, format ["征服区被: %1", ([format["SELECT `name` FROM `gangs` WHERE `id`=%1", _sortedScores select 0 select 0], 2] call OES_fnc_asyncCall) select 0]] remoteExec ["OEC_fnc_broadcast", civilian];

	[] spawn{
		uiSleep 300;
		oev_conqChop = "";
		publicVariable "oev_conqChop";
	};

	[format["INSERT INTO `conquests` (`server`,`pot`,`total_points`,`winner_id`) VALUES (%1,%2,%3,%4)", olympus_server, oev_conquestData select 4, _totalScores, _sortedScores select 0 select 0], 2] call OES_fnc_asyncCall;
	private _conqId = ([format["SELECT MAX(`id`) FROM `conquests` WHERE `server`=%1", olympus_server], 2] call OES_fnc_asyncCall) select 0;
	if !(_conqId isEqualType "" || _totalScores < 1) then {
		private _valueStr = "";
		private _award = 0;
	  private _gangIDs = [];
		private _payouts = [];
		{
			_inc = switch (_forEachIndex) do {
				case 0 : {1.10};
				case 1 : {1.05};
				case 2 : {1.03};
				default {1};
			};
			_award = floor((((_x select 1) / _totalScores) * (oev_conquestData select 4)) * _inc);
			_payouts pushBack _award;
			_gangIDs pushBack (_x select 0);
			_valueStr = _valueStr + format ["(%1,%2,%3,%4),", _conqId, _x select 0, _x select 1,_award];
		} forEach _sortedScores;

		[
			["event","Conquest Dominated"],
			["value",_award],
			["gangs",_gangIDs],
			["payouts",_payouts]
		] call OES_fnc_logIt;

		private _gangPlayerCounts = [];
		{
				_gang = _x;
				_gangPlayerCounts set [_forEachIndex,{_x select 1 == _gang} count conquestDeaths];
		} forEach _gangIDs;

		private _pid = "";
		private _gid = -1;
		private _amount = 0;
		private _idx = -1;
		{
			if !(_x select 0 isEqualTo "") then {
				_pid = _x select 0;
		  	_gid = _x select 1;
				_idx = _gangIDs find _gid;
				if(_idx >= 0 && _gid in _gangIDs && (_payouts select _idx) > 0 && _idx < count _gangPlayerCounts) then {
					_amount = (_payouts select _idx) / (_gangPlayerCounts select _idx);
					[format["UPDATE `players` SET `deposit_box`=`deposit_box`+%1 WHERE `playerid`='%2'",_amount,_pid],1] call OES_fnc_asyncCall;
					[
						["event","Conquest Deposit"],
						["value",_amount],
						["player_id",_pid],
						["gang_id",_gid]
					] call OES_fnc_logIt;
					if !(isNull (_x select 2) || owner (_x select 2) isEqualTo 0) then {
						["payout", objNull, _amount] remoteExec["OEC_fnc_conquestClient",(owner (_x select 2))];
					};
				};
			};
		} forEach conquestDeaths;

		_valueStr = _valueStr select [0, count(_valueStr) - 1];
		if (count _valueStr > 0) then {
			[format["INSERT INTO `conquest_gangs` (`conquest_id`,`gang_id`,`points`,`payout`) VALUES %1", _valueStr], 1] spawn OES_fnc_asyncCall;
		};
	};
	[_flag, oev_conquestServ,oev_conquestData] spawn _fnc_cleanup;
	private _conqPolygon = (oev_conquestData select 1 select 1);
	oev_conquestServ = [ [], [], [], 0 ];

	if(_ID != -1) then {
		if !(oev_secondConq) then {
			if((oev_conquestData select 4) >= 15000000) then {
				uiSleep 10;
				[_ID] spawn OES_fnc_conquestVoteServ;
				oev_secondConq = true;
			} else {
				oev_lastConquest = -1;
				publicVariable "oev_lastConquest";
				_query = format["UPDATE conquest_schedule SET cancelled=1 WHERE id=%1 AND server=%2",_ID,olympus_server];
				[_query,1] call OES_fnc_asyncCall;
			};
		} else {
			oev_secondConq = false;
			oev_lastConquest = -1;
			publicVariable "oev_lastConquest";
			_query = format["UPDATE conquest_schedule SET completed=1 WHERE id=%1 AND server=%2",_ID,olympus_server];
			[_query,1] call OES_fnc_asyncCall;
		};
	};

	oev_conquestData = [ false, ["", []], [], [], 0, [], [[],[],[]], 3000];
	publicVariable "oev_conquestData";

	//Atleast gonna warn them
	[6, format ["Vehicles will despawn in 60 seconds! Garages will be active for 5 minutes!"]] remoteExec ["OEC_fnc_broadcast", civilian];
	uiSleep (60);
	{
		if(getPosATL _x inPolygon (_conqPolygon)) then {
			_veh = _x;
			_vehicleClass = getText(configFile >> "CfgVehicles" >> (typeOf _veh) >> "vehicleClass");
			if(_vehicleClass in ["Car","Air","Ship","Armored","Submarine"]) then {
				_units = {(_x distance _veh < 5)} count playableUnits;
				if(count crew _x == 0) then	{
					if (_units == 0) exitWith {[_x] call OES_fnc_deletedVehStore;};
				} else {
					if (_units == 0) then {
						if (({alive _x} count crew _veh) isEqualTo 0) then {
							private _handle = [_veh] spawn OES_fnc_pulloutDead;
							waitUntil {uiSleep 0.5; scriptDone _handle;};
							[_x] call OES_fnc_deletedVehStore;
						};
					};
				};
			};
		};
	} count vehicles;
};

switch (_mode) do {
	case "autoStart": {
		if !(oev_conquestData select 0) then {
			[] call _fnc_autoStart;
		};
	};
	case "deathPrice": {
		if (oev_conquestData select 0 && _vars isEqualType 0) then {
			[] call _fnc_deathPrice;
		};
	};
	case "cancelConquest": {
		oev_cancelConq = true;
		waitUntil {uiSleep 0.1;!(oev_conquestData select 0) && !oev_conquestVote}; // Keep this as a failsafe
		oev_cancelConq = false;
	};
};
