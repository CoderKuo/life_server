// File: fn_jipRequestTimer.sqf
// Author: Jesse "tkcjesse" Schultz

params [
	["_container",objNull,[objNull]],
	["_player",objNull,[objNull]]
];

if (isNull _container || isNull _player) exitWith {};

private _detonateTime = _container getvariable ["bombtime",0];
if (_detonateTime isEqualTo 0) exitWith {};
if(_container isEqualTo gallery_siren) exitWith {[round(_detonateTime - time),true] remoteExec ["OEC_fnc_robPainting",_player,false];};


[_container,round(_detonateTime - time)] remoteExec ["OEC_fnc_demoChargeTimer",_player,false];