//	Author: Bryan "Tonic" Boardwine
//	Description:
//	When a client disconnects this will remove their corpse and
//	clean up their storage boxes in their house.
//	Also used for combat loggers bones

private["_unit","_id","_uid","_name","_sendToJailObject","_restrainedBy","_tazedBy"];
_unit = _this select 0;
_id = _this select 1;
_uid = _this select 2;
_name = _this select 3;

_uid spawn OES_fnc_unlockHouses;

if(!isNull _unit) then {
	_unit removeWeapon (primaryWeapon _unit);
	_unit removeWeapon (handGunWeapon _unit);

	{deleteVehicle _x} forEach nearestObjects [_unit, ["GroundWeaponHolder"], 5];
	{deleteVehicle _x} foreach nearestObjects[_unit,["WeaponHolderSimulated"],5];
};

if !(isNull (_unit getVariable["currMarked",objNull])) then {
	(_unit getVariable["currMarked",objNull]) setVariable["markedForAntiDespawn",nil,true];
};

if((_unit getVariable ["restrained",false]) || (_unit getVariable["downed",false])) then {
	if (!(side _unit isEqualTo civilian) || ((_unit getVariable "adminlvl") > 1)) exitWith {};
	_sendToJailObject = "Land_HumanSkeleton_F" createVehicle (position _unit);
	_sendToJailObject setVariable ["playerid", _uid, true];
	_sendToJailObject setVariable ["playername", _name, true];
	_restrainedBy = _unit getVariable ["restrainedBy",[objNull,0]];
	_tazedBy = _unit getVariable ["tazedBy",[objNull,0]];
	_markName = format ["_USER_DEFINED #lastKnown_%1%2", _unit, time];
	_realName = format["%1's Bones", _unit getVariable["realName",_name]];
	[_markName, _sendToJailObject, _realName, _restrainedBy] spawn{
		waitUntil{uiSleep 2; !((position (_this select 1)) isEqualTo [0,0,0])};
		[_this select 0, (position (_this select 1)), "ICON", "mil_objective",_this select 2,"ColorRed",[0.5,0.5]] remoteExecCall ["OEC_fnc_createMarkerLocal", _this select 3, false];
	};
	//Check if unit is restrained
	if !(isNull (_restrainedBy select 0)) then {
		if (isNull (_restrainedBy select 0)) exitWith{};
		_sendToJailObject setVariable["restrainedBy",[(_restrainedBy select 0),(_restrainedBy select 1)],true];
		_sendToJailObject setVariable["tazedBy",[objNull,0],true];
	} else{
		//Check if the unit is tazed
		if !(isNull (_tazedBy select 0)) then {
			if (isNull (_tazedBy select 0)) exitWith{};
			_sendToJailObject setVariable["tazedBy",[(_tazedBy select 0),(_tazedBy select 1)],true];
			_sendToJailObject setVariable["restrainedBy",[objNull,0],true];
		};
	};
	_sendToJailObject spawn{
		uiSleep 120;
		if(!isNull _this) then {
			deleteVehicle _this;
		};
	};
	_unit setVariable ["hasRequested",0,true];
};

if(!(isNull (_unit getVariable["TransportingPlayer",objNull]))) then {
	if(((_unit getVariable["TransportingPlayer",objNull]) getVariable ["Escorting",false])) then {
		(_unit getVariable["TransportingPlayer",objNull]) setVariable ["Escorting",false,true];
		detach (_unit getVariable["TransportingPlayer",objNull]);
	};
};

if((_unit getVariable ["inHouseInventory", [false, 0]]) select 0) then {
	[format['{"event":"Possible House Dupe", "player":"%1", "target":"%2", "HouseID":"%3", "location":"%4"}',_uid,'null',((_unit getVariable ["inHouseInventory", [false, 0]]) select 1),getPos _unit]] call OES_fnc_logIt;
};

deleteVehicle _unit;
