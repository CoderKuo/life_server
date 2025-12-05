//	File: fn_handleTerror.sqf
//	Author: Kurt
//	Description: Does what it do.
params [
	["_device",objNull,[objNull]],
	["_player",objNull,[objNull]]
];
//Initialize vars
private _timeUntilStart = 60 * 5;
private _messageDelay = 60 * 3;
private _totalTerrorDuration = 60 * 15;
private _timeBetweenTerror = 45 * 60; // 45 minutes
private _cityName = "";
private _playerName = name _player;
private _pid = getPlayerUID _player;
//Play some dank sounds
private _fnc_playTerrorSound = {
	params [
		["_cityName","",[""]],
		["_device",objNull,[objNull]]
	];
	private _kavalaPoly = [[3870.55,13969.3,0.00107193],[4322.84,13610.1,0.00115585],[3946.07,12581.5,0.00129509],[3099.49,13101.9,0.00149536]];
	private _athiraPoly = [[13995.9,19019.9,0.00149345],[14459.4,18705.9,0.0014534],[14064.8,18359.5,0.00141907],[13599,18647.9,0.0014267]];
	private _sofiaPoly = [[16787.4,12997.3,0.00143051],[17308.5,12688.9,0.00141716],[16674.1,12092.1,0.00141716],[16219.1,12524.9,0.00141716]];
	private _pyrgosPoly = [[25723.4,21559.8,0.00144005],[25967.7,21377.4,0.00150681],[25601.7,21043.8,0.00141525],[25354.1,21260.6,0.0015316],[25427.1,21523.3,0.00155449]];
	private _neochoriPoly = [[12717.5,14684.8,0.00139427],[12163.2,14382,0.00147343],[12323.5,13923.1,0.00147796],[12982.3,14155.3,0.00147796]];
	if (isNull(_device)) exitWith {};
	switch(_cityName) do {
		case "Kavala": {
			{
				if (((getPos _x) inPolygon _kavalaPoly) || (((getPos _x) distance (getPos _device)) < 30)) then {
					{playSound "radiotower";} remoteExec ["BIS_fnc_spawn",owner _x];
				};
			} forEach playableUnits;
		};
		case "Neochori": {
			{
				if (((getPos _x) inPolygon _neochoriPoly) || (((getPos _x) distance (getPos _device)) < 30)) then {
					{playSound "radiotower";} remoteExec ["BIS_fnc_spawn",owner _x];
				};
			} forEach playableUnits;
		};
		case "Athira": {
			{
				if (((getPos _x) inPolygon _athiraPoly) || (((getPos _x) distance (getPos _device)) < 30)) then {
					{playSound "radiotower";} remoteExec ["BIS_fnc_spawn",owner _x];
				};
			} forEach playableUnits;
		};
		case "Pyrgos": {
			{
				if (((getPos _x) inPolygon _pyrgosPoly) || (((getPos _x) distance (getPos _device)) < 30)) then {
					{playSound "radiotower";} remoteExec ["BIS_fnc_spawn",owner _x];
				};
			} forEach playableUnits;
		};
		case "Sofia": {
			{
				if (((getPos _x) inPolygon _sofiaPoly) || (((getPos _x) distance (getPos _device)) < 30)) then {
					{playSound "radiotower";} remoteExec ["BIS_fnc_spawn",owner _x];
				};
			} forEach playableUnits;
		};
		default {};
	};
};
//Checks
if (isNull _device || isNull _player) exitWith {};
if (serv_timeFucked) exitWith {};
if (life_terrorStatus select 0) exitWith {};
if ((serverTime < (life_terrorStatus select 2)) && !((life_terrorStatus select 2) isEqualTo 0)) exitWith {};

// Automated charge
[getPlayerUID _player, _player getvariable ["realname",name _player], "40", _player] spawn OES_fnc_wantedAdd;

private _zoneMarker = "";
private _textMarker = "";

//Check which system
private _exit = false;
switch(_device) do {
	case kavalaterror: {
		_cityName = "Kavala";
	};
	case neochoriterror: {
		_cityName = "Neochori";
	};
	case athiraterror: {
		_cityName = "Athira";
	};
	case pyrgosterror: {
		_cityName = "Pyrgos";
	};
	case sofiaterror: {
		_cityName = "Sofia";
	};
	default {
		_exit = true;
	};
};

if(_exit) exitWith {};
uiSleep ceil(random(5));

// Public variable the terror status
if(life_terrorStatus select 0) exitWith {};
life_terrorStatus = [true,_cityName,serverTime + _timeBetweenTerror];
publicVariable "life_terrorStatus";

// Let everyone know
[3,format ["<t color='#ffff00'><t size='2.2'><t align='center'>Radio Broadcast</t></t></t><br/><br/>Terror in %1 will begin in %3 minute(s) by:<br/><br/><t size='1.5'>%2<",_cityName, _playerName, round(_timeUntilStart / 60)],false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
[_cityName, _device] call _fnc_playTerrorSound;

uiSleep _timeUntilStart;

[format['{"event":"Terror Started", "player":"%1", "target":"%2", "value":"%3", "location":"%4"}',_pid,'null','null',_cityName]] remoteExecCall ["OES_fnc_logIt", 2];

[3,format ["<t color='#ffff00'><t size='2.2'><t align='center'>Terror Started</t></t></t><br/><br/>Terror is now active in %1 by:<br/><br/><t size='1.5'>%2<",_cityName, _playerName],false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
[_cityName, _device] call _fnc_playTerrorSound;
//Check which system
private _exit = false;
switch(_device) do {
	case kavalaterror: {
		_zoneMarker = createMarker ["kavalaterrorzone",[3603.594,12958.642]];
		_zoneMarker setMarkerShape "ELLIPSE";
		_zoneMarker setMarkerBrush "Border";
		_zoneMarker setMarkerColor "ColorRed";
		_zoneMarker setMarkerSize [750,750];

		_textMarker = createMarker ["kavalaterrortext",[3603.594,12958.642]];
		_textMarker setMarkerShape "ICON";
		_textMarker setMarkerType "mil_triangle";
		_textMarker setMarkerColor "ColorRed";
		_textMarker setMarkerText "Terror Active";
	};
	case neochoriterror: {
		_zoneMarker = createMarker ["neochoriterrorzone",[12529.904,14314.679]];
		_zoneMarker setMarkerShape "ELLIPSE";
		_zoneMarker setMarkerBrush "Border";
		_zoneMarker setMarkerColor "ColorRed";
		_zoneMarker setMarkerSize [500,500];

		_textMarker = createMarker ["neochoriterrortext",[12529.904,14314.679]];
		_textMarker setMarkerShape "ICON";
		_textMarker setMarkerType "mil_triangle";
		_textMarker setMarkerColor "ColorRed";
		_textMarker setMarkerText "Terror Active";
	};
	case athiraterror: {
		_zoneMarker = createMarker ["athiraterrorzone",[14007.396,18721.16]];
		_zoneMarker setMarkerShape "ELLIPSE";
		_zoneMarker setMarkerBrush "Border";
		_zoneMarker setMarkerColor "ColorRed";
		_zoneMarker setMarkerSize [500,500];

		_textMarker = createMarker ["athiraterrortext",[14007.396,18721.16]];
		_textMarker setMarkerShape "ICON";
		_textMarker setMarkerType "mil_triangle";
		_textMarker setMarkerColor "ColorRed";
		_textMarker setMarkerText "Terror Active";
	};
	case pyrgosterror: {
		_zoneMarker = createMarker ["pyrgosterrorzone",[17026.393,12702.806]];
		_zoneMarker setMarkerShape "ELLIPSE";
		_zoneMarker setMarkerBrush "Border";
		_zoneMarker setMarkerColor "ColorRed";
		_zoneMarker setMarkerSize [750,750];

		_textMarker = createMarker ["pyrgosterrortext",[17026.393,12702.806]];
		_textMarker setMarkerShape "ICON";
		_textMarker setMarkerType "mil_triangle";
		_textMarker setMarkerColor "ColorRed";
		_textMarker setMarkerText "Terror Active";
	};
	case sofiaterror: {
		_zoneMarker = createMarker ["sofiaterrorzone",[25717.867,21255.94]];
		_zoneMarker setMarkerShape "ELLIPSE";
		_zoneMarker setMarkerBrush "Border";
		_zoneMarker setMarkerColor "ColorRed";
		_zoneMarker setMarkerSize [550,550];

		_textMarker = createMarker ["sofiaterrortext",[25717.867,21255.94]];
		_textMarker setMarkerShape "ICON";
		_textMarker setMarkerType "mil_triangle";
		_textMarker setMarkerColor "ColorRed";
		_textMarker setMarkerText "Terror Active";
	};
	default {
		_exit = true;
	};
};

private _counter = 1;
while {_counter <= ((_totalTerrorDuration / _messageDelay) - 1)} do {
	uiSleep _messageDelay;
	[3,format ["<t color='#ffff00'><t size='2.2'><t align='center'>Terror Notification</t></t></t><br/><br/>Terror is active in %1 by %2.  Time remaining until terror is over:<br/><br/><t size='1.5'>%3</t>",_cityName, _playerName,[(_totalTerrorDuration - (_messageDelay * _counter)),"MM:SS"] call BIS_fnc_secondsToString],false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
	_counter = _counter + 1;
};

//Let everyone know they good
[3,format ["<t color='#00ff00'><t size='2.2'><t align='center'>Terror Ended</t></t></t><br/><br/>Terror in %1 is now over! You may now safely roam the streets.<",_cityName],false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
//Log
[format['{"event":"Terror Ended", "player":"%1", "target":"%2", "value":"%3", "location":"%4"}',_pid,'null','null',_cityName]] remoteExecCall ["OES_fnc_logIt", 2];

[_cityName, _device] call _fnc_playTerrorSound;

deleteMarker _zoneMarker;
deleteMarker _textMarker;

// Refresh the terror status
life_terrorStatus set [0,false];
life_terrorStatus set [1,""];
life_terrorStatus set [2,"",serverTime + _timeBetweenTerror];
publicVariable "life_terrorStatus";