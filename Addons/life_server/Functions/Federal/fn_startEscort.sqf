// File: fn_startEscort.sqf
// Author: Jesse "tkcjesse" Schultz

params [
	["_player",objNull,[objNull]],
	["_type",-1,[0]]
];
private ["_exit","_bwBldg","_time","_classname","_words","_marker"];

if (isNull _player || _type isEqualTo -1) exitWith {};
if (serv_timeFucked) exitWith {[1,"You cannot perform this action within the first 5 minutes of server start!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
private _copCount = [west,2] call OEC_fnc_playerCount;
if ((_type isEqualTo 1) && (_copCount < 3)) exitWith {[1,"There are not enough cops on!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if ((_type isEqualTo 2) && (_copCount < 5)) exitWith {[1,"There are not enough cops on!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if ((_type isEqualTo 3) && (_copCount < 7)) exitWith {[1,"There are not enough cops on!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if (escort_status select 0) exitWith {[1,"There is currently an escort mission in place!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if (serverTime < serv_escortCooldown) exitWith {[1,"The Pharmaceutical Company is on high alert after a recent robbery. Try again later."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};

_exit = false;
_bwBldg = nearestObject [[20898.6,19221.7,0.00143909],"Land_Dome_Big_F"];
if (_bwBldg getVariable ["chargeplaced",false]) then {_exit = true;};
if (fed_bank getVariable ["chargeplaced",false]) then {_exit = true;};
if (altis_bank getVariable ["chargeplaced",false]) then {_exit = true;};
if (altis_bank_1 getVariable ["chargeplaced",false]) then {_exit = true;};
if (altis_bank_2 getVariable ["chargeplaced",false]) then {_exit = true;};
if (_exit) exitWith {[1,"There is already a Federal Reserve, Blackwater, or Bank Robbery taking place!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};

_time =  90;
_classname = "";
_words = "";
serv_escortGroup = [];
serv_escortPIDS = [];

switch (_type) do {
	case 1: {
		_classname = "B_Truck_01_ammo_F";
		_time = time + 90;
		_words = "valuable";
	};
	case 2: {
		_classname = "O_Truck_03_repair_F";
		_time = time + 120;
		_words = "moderately valuable";
	};
	case 3: {
		_classname = "O_Truck_03_ammo_F";
		_time = time + 150;
		_words = "extremely valuable";
	};
};

[3,format ["<t color='#ff2222'><t size='2.2'><t align='center'>Escort Activated<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Altis Pharmaceutical Company is being robbed of a vehicle containing %1 goods! You can attempt to hijack the vehicle and sell it at one of the three drop off locations marked around the map. The further the drop off the more money you get!",_words],false,[]] remoteExec ["OEC_fnc_broadcast",civilian,false];

[3,format ["<t color='#ff2222'><t size='2.2'><t align='center'>Escort Activated<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Altis Pharmaceutical Company is being robbed of a vehicle containing %1 goods! Stop the vehicle as soon as possible to get the highest payout!",_words],false,[]] remoteExec ["OEC_fnc_broadcast",west,false];

[
	["event","Started Pharmaceutical"],
	["player",name _player],
	["player_id",getPlayerUID _player],
	["position",getPosATL _player]
] call OES_fnc_logIt;

escort_status = [true,0];
publicVariable "escort_status";
serv_escortGroup = group _player;

{
	serv_escortPIDS pushBackUnique (getPlayerUID _x);
} forEach (units serv_escortGroup);

[_time,0] remoteExec ["OEC_fnc_escortTimer",west,false];
[_time,0] remoteExec ["OEC_fnc_escortTimer",group _player,false];

waitUntil {uiSleep 0.5; (round(_time - time) < 1) || !(escort_status select 0)};
uiSleep 1;

if !(escort_status select 0) exitWith {
	[1,"The APD have stopped the Pharmaceutical robbery!"] remoteExec ["OEC_fnc_broadcast",-2,false];
};

escort_status = [true,(servertime + 2700)];
publicVariable "escort_status";

{
	_marker = createMarker [(_x select 0),(_x select 1)];
	_marker setMarkerType "mil_pickup";
	_marker setMarkerColor "ColorCIV";
	_marker setMarkerText (_x select 2);
} forEach [["dropOne",[16623.605,18990.5],"Drop Off (85%)"],["dropTwo",[20968.9,16990.143],"Drop Off (100%)"],["dropThree",[21993.125,21085.07],"Drop Off (150%)"]];

[2700,1] remoteExec ["OEC_fnc_escortTimer",west,false];
[2700,1] remoteExec ["OEC_fnc_escortTimer",group _player,false];

if (_classname isEqualTo "O_Truck_03_ammo_F") then {
	["O_LSV_02_armed_F",[15358.9,16121,0],162] spawn OES_fnc_spawnEscortVeh;
};

[_classname,[15331.4,16098.8,0],73] spawn OES_fnc_spawnEscortVeh;

[1,"The Pharmaceutical Company has been broken into and the truck is now in possession by rebels!"] remoteExec ["OEC_fnc_broadcast",-2,false];
