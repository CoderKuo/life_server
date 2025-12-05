//  File: fn_initHouses.sqf
//	Author: Bryan "Tonic" Boardwine

private["_queryResult","_query","_count","_keyPlayers","_storageCapacity","_trunk","_physicalTrunk","_physicalStorageCapacity"];
_count = ([format["SELECT COUNT(*) FROM houses WHERE owned='1' AND server='%1'",olympus_server],2] call OES_fnc_asyncCall) select 0;

for [{_x=0},{_x<=_count},{_x=_x+10}] do {
	_query = format["SELECT houses.id, houses.pid, houses.pos, players.name, houses.player_keys, houses.inventory, houses.storageCapacity, houses.inAH, houses.oil, houses.physical_inventory, houses.physicalStorageCapacity, DATEDIFF(houses.expires_on, TIMESTAMP(CURRENT_DATE())) FROM houses INNER JOIN players ON houses.pid=players.playerid WHERE houses.owned='1' AND server='%2' LIMIT %1,10",_x,olympus_server];
	_queryResult = [_query,2,true] call OES_fnc_asyncCall;
	if(count _queryResult == 0) exitWith {};

	{
		_pos = call compile format["%1",_x select 2];
		_house = _pos nearestObject "House_F";

		if(!isNull _house) then {
			_house allowDamage false;

			_house setVariable["house_owner",[_x select 1,_x select 3],true];
			_house setVariable["house_id",_x select 0,true];
			_house setVariable["locked",true,true];
			_house setVariable["house_expire",(_x select 11),true];
			//_house setVariable["for_sale","",true];
			if ((_x select 7) isEqualTo 0) then {
				_house setVariable["for_sale","",true];
			} else {
				_house setVariable["for_sale",[_x select 1,_x select 7],true];
			};
			//if ((_x select 7) isEqualTo 0) then {
			//	_house setVariable ["inAH",false,true];
			//} else {
			//	_house setVariable ["inAH",true,true];
			//};

			_keyPlayers = [_x select 4] call OES_fnc_mresToArray;
			if(_keyPlayers isEqualType "") then {_keyPlayers = call compile _keyPlayers;};

			_house setVariable["keyPlayers",_keyPlayers,true];

			_storageCapacity = 100;
			_physicalStorageCapacity = 100;

			_trunk = [_x select 5] call OES_fnc_mresToArray;
			_physicalTrunk = [_x select 9] call OES_fnc_mresToArray;
			_storageCapacity = _x select 6;
			_physicalStorageCapacity = _x select 10;
			if(_trunk isEqualType "") then {_trunk = call compile format["%1", _trunk];};
			if(_physicalTrunk isEqualType "") then {_physicalTrunk = call compile format["%1", _physicalTrunk];};
			_house setVariable["Trunk",_trunk,true];
			_house setVariable["PhysicalTrunk",_physicalTrunk,true];

			_house setVariable["storageCapacity",_storageCapacity,true];
			_house setVariable["physicalStorageCapacity",_physicalStorageCapacity,true];

			if ((_x select 8) isEqualTo 1) then {
				_house setVariable ["oilstorage",true,true];
			};

			if ((_x select 11) <= 5) then {
				format ["-HOUSEEXPIRE- House id %1 owned by %2 will expire in %3 days.",(_x select 0),(_x select 1),(_x select 11)] call A3LOG_fnc_log;
			};
		};
	} forEach _queryResult;
};
