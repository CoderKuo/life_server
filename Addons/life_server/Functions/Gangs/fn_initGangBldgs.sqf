//	File: fn_initGangBldgs.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Initalizes the gangbldgs

private _query = format ["SELECT COUNT(*) FROM gangbldgs WHERE owned='1' AND server='%1'",olympus_server];
private _count = (([_query,2] call OES_fnc_asyncCall) select 0);

for [{_x=0},{_x<=_count},{_x=_x+10}] do {
	_query = format ["SELECT id, owner, classname, pos, inventory, storage_cap, gang_id, gang_name, crate_count, lastpayment, nextpayment, paystatus, oil, physical_inventory, physical_storage_cap FROM gangbldgs WHERE owned='1' AND server='%1' LIMIT %2,10",olympus_server,_x];
	private _queryResult = [_query,2,true] call OES_fnc_asyncCall;
	if(count _queryResult isEqualTo 0) exitWith {};

	{
		private _queryT = format ["SELECT DATEDIFF(ADDDATE('%1', 31 * %2), NOW())",(_x select 10), (_x select 11)];
		private _queryResultT = (([_queryT,2] call OES_fnc_asyncCall) select 0);
		private _queryTwo = format ["SELECT COUNT(*) FROM gangmembers WHERE gangid='%1' AND gangname='%2'",(_x select 6),(_x select 7)];
		private _countResult = (([_queryTwo,2] call OES_fnc_asyncCall) select 0);
		private _pos = call compile format ["%1",_x select 3];
		private _building = _pos nearestObject "House_F";
		if !(typeOf _building isEqualTo (_x select 2)) exitWith {};

		if !(isNull _building) then {
			if (_building getVariable ["restricted_shed",false]) exitWith {
				format["GANG BLDG ERROR: Shed had the restricted shed variable and wasn't setup! id: %1  bldgGang: %2  bldgOwner: %3",(_x select 0),(_x select 7),(_x select 1)] call OES_fnc_diagLog;
			};
			_building setVariable ["bldg_id",(_x select 0),true];
			_building setVariable ["bldg_owner",(_x select 1),true];
			_building setVariable ["bldg_gangid",(_x select 6),true];
			_building setVariable ["bldg_gangName",(_x select 7),true];
			_building setVariable ["locked",true,true];
			_building setVariable ["inv_locked",true,true];
			_building setVariable ["bldg_payment",[_queryResultT,(_x select 11)],true];
			if ((_x select 12) isEqualTo 1) then {
				_building setVariable ["oilstorage",true,true];
			};

			private _storageCap = 1000;
			private _physicalStorageCap = 1000;
			private _trunk = [(_x select 4)] call OES_fnc_mresToArray;
			private _physicalTrunk = [(_x select 13)] call OES_fnc_mresToArray;
			_storageCap = (_x select 5);
			_physicalStorageCap = (_x select 14);
			if (typeName _trunk isEqualTo "STRING") then {_trunk = call compile format ["%1",_trunk];};
			_building setVariable ["trunk",_trunk,true];
			_building setVariable ["PhysicalTrunk",_physicalTrunk,true];
			_building setVariable ["storageCapacity",_storageCap,true];
			_building setVariable ["physicalStorageCapacity",_physicalStorageCap,true];
			if (_countResult < 8) then {
				_building setVariable ["bldg_locked",true,true];
			};
		};
	} forEach _queryResult;
};