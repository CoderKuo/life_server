// File: fn_executeEventAction
// performs the event actions server side
private["_eventMarker","_participants","_eventMarkerLocation"];
params [
	["_player",objNull,[objNull]],
	["_eventType","",[""]],
	["_eventLocation","",[""]],
	["_eventAction","",[""]]
];
if(_eventLocation == "myPosition") then {
	_eventMarkerLocation = (getPos _player);
}else{
	_eventMarker = format["eventMarker_%1_%2",_eventType,_eventLocation];
	_eventMarkerLocation = getMarkerPos(_eventMarker);
};

if(isNull _player || _eventType == "" || _eventLocation == "" || _eventAction == "") exitWith {};
_authorizedUsers = [];
//if(!((getPlayerUID _player) in _authorizedUsers)) exitWith {};
_participants = [];
{
	if(((_x getVariable ["isInEvent",["no"]]) select 0) != "no") then {
		_participants pushBack _x;
	};
}foreach playableUnits;

switch (_eventAction) do {

//--------------- Player management functions
	case "tpAllSelected": {
		{
			if((_x distance _eventMarkerLocation > 50) && (_x distance [8498.75,25101.2,0.00106812] > 500) && !(_x getVariable["restrained",false])) then {
				_x setPos _eventMarkerLocation;
			};
		}foreach _participants;
	};

	case "replenishParticipants": {
		[["eatNDrink"],"OEC_fnc_executeOnOwner",_participants,false] spawn OEC_fnc_MP;
	};

	case "wipeParticipantsGear": {
		[[],"OEC_fnc_stripDownPlayer",_participants,false] spawn OEC_fnc_MP;
	};



//------------------- vehicle management functions
	case "unlockVehicles": {
		{
			if(!isNull _x) then {
				_x allowDamage true;
				_x lock 0;
			};
		}foreach life_server_eventVehicles;
	};

	case "serviceVehicles": {
		{
			if(!isNull _x) then {
				_x allowDamage true;
				_x setDamage 0;
				_x setFuel 1;
			};

			[["refuelAndRearm"],"OEC_fnc_executeOnOwner",(owner _x),false] spawn OEC_fnc_MP;
		}foreach life_server_eventVehicles;
	};

	case "drainVehicles":{
		{
			if(!isNull _x) then {
				_x allowDamage true;
				_x setDamage 0;
				_x setFuel 0;
			};

			[["drainFuel"],"OEC_fnc_executeOnOwner",(owner _x),false] spawn OEC_fnc_MP;
		}foreach life_server_eventVehicles;
	};

//------------------- Cleanup functions
	case "cleanupVehicles":{
		{
			if(!isNull _x) then {
				_x setVelocity [0,0,0];
				deleteVehicle _x;
			};
		}foreach life_server_eventVehicles;
		life_server_eventVehicles = [];
	};

	case "cleanupCrates":{
		{
			if(!isNull _x) then {
				deleteVehicle _x;
			};
		}foreach life_server_eventCrates;
		life_server_eventCrates = [];
	};

	case "cleanupObjects":{
		{
			if(!isNull _x) then {
				deleteVehicle _x;
			};
		}foreach life_server_eventObjects;
		life_server_eventObjects = [];
	};

	case "cleanupEvent": {
		{
			if(!isNull _x) then {
				_x setVelocity [0,0,0];
				deleteVehicle _x;
				sleep 0.05;
			};
		}foreach life_server_eventVehicles;
		life_server_eventVehicles = [];

		{
			if(!isNull _x) then {
				deleteVehicle _x;
				sleep 0.05;
			};
		}foreach life_server_eventCrates;
		life_server_eventCrates = [];

		{
			if(!isNull _x) then {
				deleteVehicle _x;
				sleep 0.05;
			};
		}foreach life_server_eventObjects;
		life_server_eventObjects = [];
	};
};