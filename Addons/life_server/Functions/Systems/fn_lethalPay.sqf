//	File: fn_lethalPay.sqf
//	Author: Kurt
//	Description: Pays the cop for lethaling a suspect

params [
	["_victim",objNull,[objNull]],
	["_cop",objNull,[objNull]]
];

if (isNull _cop) exitWith{};
if (isNull _victim) exitWith{};


//Initializing - Issues with getPlayerUID and non-local players - https://community.bistudio.com/wiki/getPlayerUID
private _copsPaid = false;
private _victimPID = _victim getVariable ["steam64id", getPlayerUID _victim];
private _copPID = _cop getVariable ["steam64id", getPlayerUID _cop];

//Begin to pay the cops
[_victim,_cop,true] spawn OES_fnc_wantedBounty;

while {!(_copsPaid)} do {
	{
		if (_copsPaid) exitWith {};
		if (((_x select 0) isEqualTo _victimPID) && ((_x select 1) isEqualTo _copPID)) then {
			_copsPaid = true;
			[_victimPID] spawn OES_fnc_wantedRemove;
			serv_lethalTracker deleteAt _forEachIndex;
		};
	} forEach serv_lethalTracker; // [[victimPID,copPID],..]
	uiSleep 0.5;
};
