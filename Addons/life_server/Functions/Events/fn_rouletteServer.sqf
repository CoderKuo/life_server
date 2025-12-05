//	File: fn_rouletteServer.sqf
//	Author: Ozadu
//	Description: Server side of the roulette event.

params[
	["_eventMaster",objNull,[objNull]],
	["_spawnDome",false,[false]],
	["_teleportPlayers",false,[false]]
];
_eventPos = [23547.5,17993.7,0.00143886];

/*2nd parameter is passed if dome needs to be spawned*/
if(_spawnDome) exitWith {
	_eventDome = "Land_Dome_Small_F" createVehicle _eventPos;
	_eventDome setVariable ['bis_disabled_Door_1',1,true];
	_eventDome setVariable ['bis_disabled_Door_2',1,true];
	_eventDome setVariable ['bis_disabled_Door_3',1,true];
	waitUntil{!isNull _eventDome};
	life_server_eventObjects pushBack _eventDome;

	_light = "Chemlight_red" createVehicle _eventPos;
	while{!isNull _eventDome} do {
		waitUntil{
			sleep 5;
			isNull _light;
		};
		_light = "Chemlight_red" createVehicle _eventPos;
	};
};

/*3rd parameter is passed if players need to be teleported to the event area*/
if(_teleportPlayers) exitWith {
	_players = playableUnits select {(_x getVariable ["isInEvent",["no"]] select 0) != "no"};
	{
		_x setPos _eventPos;
	} forEach _players;
};

_players = playableUnits select {(_x getVariable ["isInEvent",["no"]] select 0) != "no"};
_participants = _players;
_roundDuration = 10;
_powerRound = floor random (count _players);

/*Main loop for event. Monitors players and removes them when they die.*/
_round = 0;
while{count _players > 1} do {
	[[_eventMaster,_round,_powerRound,count _players],"OEC_fnc_roulette",_players,false] call OEC_fnc_mp;
	_time = time;
	while{time - _time < _roundDuration} do {
		{
			if(! alive _x) then {
				_players = _players - [_x];
			};
			if((_x distance _eventPos) > 1000) then {
				_x setDamage 1;
			};
		} forEach _players;
		sleep .5;
	};
	_round = _round + 1;
};
_winner = name (_players select 0);
sleep 10;
[[2,format["Congratulations to %1 for winning the event! \nThanks to all who participated.",_winner]],"OEC_fnc_broadcast",_participants] call OEC_fnc_mp;