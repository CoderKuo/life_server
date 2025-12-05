// File: fn_adminCreateComp.sqf
// Author: Jesse "tkcjesse" Schultz
// Description: Spawns the admin compensation crate on admin island

params [
	["_admin",objNull,[objNull]],
	["_pid","",[""]]
];

if (isNull _admin || _pid isEqualTo "") exitWith {};

private _crate = createVehicle ["IG_supplyCrate_F",[random(1000),random(1000),random(1000)],[],0,"CAN_COLLIDE"];
waitUntil {!isNil "_crate" && {!isNull _crate}};
_crate allowDamage false;
_crate attachTo [_admin,[0,1.2,1.1]];
_crate enableSimulationGlobal false;
_crate enableRopeAttach false;

clearWeaponCargoGlobal _crate;
clearItemCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearBackpackCargoGlobal _crate;
uiSleep 0.25;
clearWeaponCargoGlobal _crate;
clearItemCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearBackpackCargoGlobal _crate;
uiSleep 0.25;
clearWeaponCargo _crate;
clearItemCargo _crate;
clearMagazineCargo _crate;
clearBackpackCargo _crate;

_crate setVariable ["owner",[(getPlayerUID _admin),_pid],true];
_crate setVariable ["trunk",[[],0],true];

if !(isNull _admin) then {
	[_crate] remoteExec ["OEC_fnc_compActions",_admin,false];
};

format ["-ISLAND- Admin %1 (%2) has spawned a compensation crate for PID: %3",name _admin,getPlayerUID _admin,_pid] call OES_fnc_diagLog;

[_crate] spawn{
	params [["_crate",objNull,[objNull]]];
	uiSleep (20 * 60);
	if (isNull _crate) exitWith {};
	format ["-ISLAND- Crate for PID: %1 has deleted. Virtual: %2  Physical: %3 - %4 - %5 - %6",((_crate getVariable ["owner",["",""]]) select 0),((_crate getVariable ["trunk",[]]) select 0),getWeaponCargo _crate,getItemCargo _crate,getMagazineCargo _crate,getBackpackCargo _crate] call OES_fnc_diagLog;
	deleteVehicle _crate;
};