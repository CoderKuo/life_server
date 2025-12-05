//	File: fn_spawnDopamineCrate.sqf
//	Author: Ozadu
//	Description: Creates a crate object, puts it on the nearest hospital and tells all the clients to add dopamine action to it.

params[
	["_unit",objNull,[objNull]],
	["_targetPos",[],[[]]],
	["_isNeo",false,[false]]
];
if(isNull _unit) exitWith {};

private ["_hs","_crate","_crateType","_spawnedTime","_pickedUp","_smoke","_cratePos","_marker"];

if !(_isNeo) then {
	_hs = nearestObjects[_targetPos,["Land_Hospital_side2_F"],175];
	if(count _hs isEqualTo 0) exitWith {};
	_hs = _hs select 0;
	_crateType = "Land_Cargo10_yellow_F";
	_crate = _crateType createVehicle [0,0,0];
	_crate setPosATL (_hs modelToWorld [12.6616,-3.1123,10.6315]);
} else {
	_crateType = "Land_Cargo10_yellow_F";
	_crate = _crateType createVehicle [0,0,0];
	_crate setPosATL [11130.9,13045.5,0.00149345];
};

_crate setVariable ["dopamineCrate",true,true];
_crate setVariable ["owner",getPlayerUID _unit,true];
_crate setMass 5000;

[_crate,"addAction"] remoteExecCall ["OEC_fnc_dopamineCrateAction",-2,_crate];
[_crate,"task",_unit] remoteExec ["OEC_fnc_dopamineCrateAction",_unit,false];

_spawnedTime = time;
_pickedUp = false;

//Monitor who is picking up the crate
[_crate] spawn {
	params[
		["_dopeCrate",objNull,[objNull]]
	];
	while{!(isNull _dopeCrate)} do {
		if !(isNull ropeAttachedTo _dopeCrate) then {
			if !(isNull (driver (ropeAttachedTo _dopeCrate))) then {
				if ((side (driver (ropeAttachedTo _dopeCrate))) isEqualTo civilian) then {
					private _ropes = ropes (ropeAttachedTo _dopeCrate);
					{ropeDestroy _x;} forEach _ropes;
					[1,"Only medics and cops can sling dopamine crates!"] remoteExec ["OEC_fnc_broadcast",(owner (driver (ropeAttachedTo _dopeCrate))),false];
				};
			};
		};
		uiSleep 1;
	};
};
_jipID = str round random 999;
while{!(isNull _crate)} do {
	if(!_pickedUp && (time - _spawnedTime) > (5*60)) exitWith {deleteVehicle _crate};
	if(!_pickedUp && !(isNull ropeAttachedTo _crate)) then {_pickedUp = true};
	if(_pickedUp && isNull ropeAttachedTo _crate && speed _crate <= 1) exitWith {
		_smoke = "SmokeShellYellow" createVehicle [0,0,0];
		_cratePos = getPos _crate;
		_smoke setPos [_cratePos select 0,_cratePos select 1, (_cratePos select 2)+3];
		[_crate,"mark"] remoteExec ["OEC_fnc_dopamineCrateAction",-2,_jipID];
	};
	uiSleep 5;
};

uiSleep (60 * 60);
remoteExec ["",_jipID];
deleteVehicle _crate;
