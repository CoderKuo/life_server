// File: fn_sellEscort.sqf
// Author: Jesse "tkcjesse" Schultz

params [
	["_player",objNull,[objNull]],
	["_type",0,[0]]
];

if (isNull _player) exitWith {};
if !(alive _player) exitWith {};
if ((getPos _player) distance [8475,25130,0] <= 500) exitWith {}; //Make 100% the player is not alive (spawn island)
private _uid = getPlayerUID _player;
if !(_uid isEqualTo serv_escortDriver) exitWith {[1,"You must be the last person to occupy the drivers seat of the vehicle before claiming!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if (_player getVariable ["restrained", false]) exitWith {[1,"You can't sell the escort vehicle while restrained!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if (_player getVariable ["downed",false]) exitWith {[1,"You can't sell the escort vehicle while tased!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if ((escort_status select 1) <= serverTime) exitWith {[1,"The window to return the escort vehicle has ended!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if (isNull serv_escortTruck) exitWith {[1,"The escort vehicle has disappeared?"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if (((getPos serv_escortTruck) distance (getPos _player)) > 12) exitWith {[1,"The escort vehicle must be closer to the NPC."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};

private _value = 0;
private _multi = 1;
private _base = switch (typeOf serv_escortTruck) do {
	case "O_Truck_03_ammo_F": {1500000};
	case "B_Truck_01_ammo_F": {500000};
	case "O_Truck_03_repair_F": {1000000};
};

if (_type isEqualTo 1) then {
	_multi = 0.85;
} else {
	if (_type isEqualTo 3) then {
		_multi = 1.5;
	};
};

_value = (_base * _multi * 1.15);

uiSleep random(5);
uiSleep random(5);
uiSleep random(5);

if (isNull _player) exitWith {};
if !(alive _player) exitWith {};
if ((getPos _player) distance [8475,25130,0] <= 500) exitWith {}; //Make 100% the player is not alive (spawn island)
if (isNull serv_escortTruck) exitWith {[1,"The escort vehicle has disappeared..."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if (_player getVariable ["restrained", false]) exitWith {[1,"You can't sell while restrained!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if (_player getVariable ["downed",false]) exitWith {[1,"You can't sell while tased!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
if !(_uid isEqualTo serv_escortDriver) exitWith {[1,"You must be the last person to occupy the drivers seat of the vehicle before claiming!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];};
deleteVehicle serv_escortTruck;
deleteMarker format["escortveh_%1", (typeOf serv_escortTruck)];
deleteMarker format["escortvehoutline_%1",(typeOf serv_escortTruck)];
deleteMarker format["escortveh_%1", (typeOf serv_escortQilin)];
deleteMarker format["escortvehoutline_%1",(typeOf serv_escortQilin)];
{deleteMarker _x;}forEach ["dropOne","dropTwo","dropThree"];

if ((getPlayerUID _player) in serv_escortPIDS) then {
	private _count = count serv_escortPIDS;
	_value = round(_value / _count);
	{
		if (((getPlayerUID _x) in serv_escortPIDS)) then {
			[2,_value,name _player] remoteExec ["OEC_fnc_payPlayer",_x,false];
		};
	} forEach allPlayers;
} else {
	[2,_value,name _player] remoteExec ["OEC_fnc_payPlayer",_player,false];
};
[
	["event","Sold Pharmaceutical"],
	["player",name _player],
	["player_id",getPlayerUID _player],
	["value",_value],
	["location",getPosATL _player]
] call OES_fnc_logIt;
[3,"<t color='#ff2222'><t size='2.2'><t align='center'>Escort Completed<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Altis Pharmaceutical truck has been sold!",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];

serv_escortCooldown = (serverTime + 1800);
escort_status = [false,0];
publicVariable "escort_status";
