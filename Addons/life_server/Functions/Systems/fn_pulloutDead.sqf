//  File: fn_pulloutDead.sqf
//	Author: Fusah
//	Description: Pulls dead players out of a vehicle.

private _veh = param [0,ObjNull,[ObjNull]];

if (isNull _veh) exitWith {};
if (count crew _veh isEqualTo 0) exitWith {};
if !(({alive _x} count crew _veh) isEqualTo 0) exitWith {};
private _grp = createGroup [CIVILIAN, true];
private _inviPerson = _grp createUnit ["C_man_p_beggar_F",[100,0,0],[],0,"NONE"];
[0,_inviPerson] spawn OES_fnc_adminInvis;
_inviPerson allowDamage false;
_inviPerson setCaptive true;
uiSleep .1;
//_role = _x select 1;
//_cargoslot = _x select 2;
//_turret = _x select 3;
{
	switch (_x select 1) do {
		case "driver": {
			uiSleep 0.5;
			_inviPerson moveInDriver _veh;
		};
		case "Turret": {
			uiSleep 0.5;
			_inviPerson moveInTurret [_veh, _x#3];
		};
		case "commander": {
			uiSleep 0.5;
			_inviPerson moveInCommander _veh;
		};
		case "gunner": {
			uiSleep 0.5;
			_inviPerson moveInGunner _veh;
			};
		case "cargo": {
			uiSleep 0.5;
			_inviPerson moveInCargo [_veh,_x#2];
			};
	};
	uiSleep 0.5;
	moveOut _inviPerson;
	if (isNull _veh || !alive _veh) exitWith {};
	} forEach fullCrew _veh;
uiSleep 1;
deleteVehicle _inviPerson;