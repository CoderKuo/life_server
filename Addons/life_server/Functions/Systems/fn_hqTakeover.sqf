//	File: fn_serverTakeoverTerminal.sqf
//	Author: grar21
//  Modified/Edited: Fraali
//	Description: Server-side handling of HQ takeover
//  oev_hqtakeover = Mutliple arrays of [false, 0]; - From Kav to BW - true/false being active, server time of when it ends/ended

params [
	["_unit", objNull,[objNull]],
	["_terminalPos", [0,0,0], [[]]],
	["_terminalDir", 0, [0]],
	["_inHQ", "", [""]],
	["_hqSelect", [false, 0], [[]]],
	["_marker", "", [""]]
];
_takeoverTimer = 900;
_deleteTerm = false;
_spawnDelay = 30;
_markText = "";
_hqNum = -1;
_close = false;
_10min = false;
_5min = false;
_1min = false;
_markName = format ["takeoverMark_%1", _inHQ];
//Spawn this first
_hqTerm = "Land_DataTerminal_01_F" createVehicle [0,0,0]; // Spawn Terminal object
_hqTerm setDir _terminalDir;
_hqTerm setPosATL _terminalPos;
[_hqTerm, "red","orange","green"] call BIS_fnc_DataTerminalColor; //Adds color to the terminal PiP

//Get default variables for HQ the takeover will start in
switch(_inHQ) do {
	case "Kavala": {_marker = "police_hq_1"; _markText = "Kavala APD HQ"; _hqSelect = oev_hqtakeover select 0; _hqNum = 0};
	case "Pyrgos": {_marker = "police_hq_2"; _markText = "Pyrgos APD HQ";_hqSelect = oev_hqtakeover select 1; _hqNum = 1};
	case "Athira": {_marker = "police_hq_3"; _markText = "Athira APD HQ"; _hqSelect = oev_hqtakeover select 2; _hqNum = 2};
	case "Air": {_marker = "markerAir_HQ"; _markText = "APD Air HQ"; _hqSelect = oev_hqtakeover select 3; _hqNum = 3};
	case "Sofia": {_marker = "police_hq_5"; _markText = "Sofia HQ"; _hqSelect = oev_hqtakeover select 4; _hqNum = 4};
	case "Neochori": {_marker = "cop_hq_6"; _markText = "Neochori APD HQ"; _hqSelect = oev_hqtakeover select 5; _hqNum = 5};
	case "Blackwater": {_marker = "cop_hq_7"; _markText = "Blackwater Outpost"; _hqSelect = oev_hqtakeover select 6; _hqNum = 6};
	default {_marker = ""; _markText = ""; _hqSelect = [false,0]; _hqNum = 0};
};
_callArea = { //Call this when needing to update players in the area
	//Check whos in the area to broadcast messages to
	_obj_main = _this select 0;
	_unit = _this select 1;
	_units = units group _unit;
	_units pushback west;
	_inArea = _units;
	{
		if(_x in allPlayers && !(_x in _inArea) && !(side _x isEqualTo WEST)) then {
			_inArea pushback _x;
		};
	}forEach (nearestObjects [_obj_main, ["CAManBase"], 250]);
	_inArea;
};
_units = units group _unit;
_units pushback west;
_inArea = [_hqTerm, _unit] call _callArea;
{_x reveal _hqTerm} forEach (nearestObjects [_hqTerm, ["CAManBase"], 250]);
format ['{"event":"Started HQ Takeover", "player":"%1", "player_id":"%2", "target_hq":"%3", "target_pos":"%4", "servertime":"%5"}',name _unit, getPlayerUID _unit, _inHQ, _terminalPos, round serverTime] call OES_fnc_logIt;
[0, format ["%1分钟后开始接管总部！如果你呆在这个地方，你可能会中枪!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];
[3, format ["<t color='#3792cb'><t size='2.2'><t align='center'>总部警报<br/><t color='#ffffff'><t align='center'><t size='1.2'>%1 HQ takeover starting in 1 minute! You may be shot if you stay in the area!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];

_hqSelect set [0, true]; //Set Takeover active
_hqSelect set [1, round serverTime + _takeoverTimer]; //Set time to default
publicVariable "oev_hqtakeover";

_hqTerm setVehicleVarName (format ["oev_takeoverObj_%1", _inHQ]); //Set obj name to a unique variable according to what HQ its placed at

["addaction", _hqTerm, _hqNum, _inHQ] remoteExec ["OEC_fnc_takeoverTerminal", -2, _hqTerm];

for "_i" from 0 to 59 do {	//Sleep for 1 minute before the takeover starts to let people leave if they want to live.
	uiSleep 1;
	if (!(oev_hqtakeover select _hqNum select 0)) exitWith {_close = true;};
	if (jailwall getVariable ["chargeplaced",false] || fed_bank getVariable ["chargeplaced",false] || (nearestObject [[20898.6,19221.7,0.00143909],"Land_Dome_Big_F"]) getVariable ["chargeplaced",false]) exitWith {_close = true;};
	if (altis_bank getVariable ["chargeplaced",false] || altis_bank_1 getVariable ["chargeplaced",false] || altis_bank_2 getVariable ["chargeplaced",false] && _inHQ isEqualTo "Pyrgos") exitWith {_close = true;};
};

//Start the actual takeover
if !(_close) then {
	_hqSelect set [1, round serverTime + _takeoverTimer]; //Sets the time when the takeover will end
	publicVariable "oev_hqtakeover";
	_inArea = [_hqTerm, _unit] call _callArea;
	[_markName, _terminalPos, "ICON", "mil_warning", "", "ColorOrange", [0.5,0.5], 0] remoteExecCall ["OEC_fnc_createMarkerLocal", WEST, format ["hqTermMark%1", _inHQ]];
	[0, format ["%1 HQ is being taken over, and anyone in the area can be shot!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];
	[3, format ["<t color='#3792cb'><t size='2.2'><t align='center'>总部警报<br/><t color='#ffffff'><t align='center'><t size='1.2'>%1 HQ is being taken over, and anyone in the area can be shot!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];
	_marker setMarkerText format["%1 HQ (Takeover Active!)", _inHQ];
	_marker setMarkerColor "ColorEAST";
	[_hqTerm, 3] call BIS_fnc_DataTerminalAnimate;

	while {oev_hqtakeover select _hqNum select 0} do {
		switch(true) do {
			case ((((_hqSelect select 1) - round serverTime)<= 600) && !(_10min)): {_10min = true;_inArea = [_hqTerm, _unit] call _callArea;[0, format ["10 minutes left on %1 HQ takeover!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];[3, format ["<t color='#3792cb'><t size='2.2'><t align='center'>总部警报<br/><t color='#ffffff'><t align='center'><t size='1.2'>10 minutes left on %1 HQ takeover!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];};
			case ((((_hqSelect select 1) - round serverTime)<= 300) && !(_5min)): {_5min = true;_inArea = [_hqTerm, _unit] call _callArea;[0, format ["5 minutes left on %1 HQ takeover!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];[3, format ["<t color='#3792cb'><t size='2.2'><t align='center'>总部警报<br/><t color='#ffffff'><t align='center'><t size='1.2'>5 minutes left on %1 HQ takeover!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];};
			case ((((_hqSelect select 1) - round serverTime)<= 60) && !(_1min)): {_1min = true;_inArea = [_hqTerm, _unit] call _callArea;[0, format ["1 minutes left on %1 HQ takeover!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];[3, format["<t color='#3792cb'><t size='2.2'><t align='center'>总部警报<br/><t color='#ffffff'><t align='center'><t size='1.2'>1 minute left on %1 HQ takeover!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];};
			default {};
		};
	if ((oev_hqtakeover select _hqNum select 1) <= serverTime) exitWith {};
		if (jailwall getVariable ["chargeplaced",false] || fed_bank getVariable ["chargeplaced",false] || (nearestObject [[20898.6,19221.7,0.00143909],"Land_Dome_Big_F"]) getVariable ["chargeplaced",false]) exitWith {};
		if (altis_bank getVariable ["chargeplaced",false] || altis_bank_1 getVariable ["chargeplaced",false] || altis_bank_2 getVariable ["chargeplaced",false] && _inHQ isEqualTo "Pyrgos") exitWith {};
		sleep 1;
	};
	_inArea = [_hqTerm, _unit] call _callArea;
	[0, format ["The %1 HQ takeover has ended!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];
	[3, format ["<t color='#3792cb'><t size='2.2'><t align='center'>总部警报<br/><t color='#ffffff'><t align='center'><t size='1.2'>The %1 HQ takeover has ended!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];
} else {
	_inArea = [_hqTerm, _unit] call _callArea;
	[0, format ["The %1 HQ takeover has been stopped!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];
	[3, format ["<t color='#3792cb'><t size='2.2'><t align='center'>总部警报<br/><t color='#ffffff'><t align='center'><t size='1.2'>The %1 HQ takeover has been stopped!", _inHQ]] remoteExec ["OEC_fnc_broadcast", _inArea];
};
//End takeover, set time to when it ends, delete terminal, remove marker from JIP queue and delete the marker itself
[format ["%1", _markName]]remoteExecCall["deleteMarkerLocal", WEST];
remoteExec ["", format ["hqTermMark%1", _inHQ]];
_hqSelect set [0, false];
_hqSelect set [1, round serverTime];
publicVariable "oev_hqtakeover";
[_hqTerm, 0] call BIS_fnc_DataTerminalAnimate;
sleep 3.5;
deleteVehicle _hqTerm;
_marker setMarkerText _markText;
_marker setMarkerColor "ColorWEST";
