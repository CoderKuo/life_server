//File: fn_vigiGetSetArrests.sqf
//Author: Jesse "tkcjesse" Schultz
//Modified: Kurt, Horizon
params [
	["_mode",-1,[0]],
	["_player",objNull,[objNull]]
];

if (isNull _player) exitWith {};
if (_mode isEqualTo -1) exitWith {};
private ["_uid","_query"];

_uid = getPlayerUID _player;

switch (_mode) do {

	//Fetch arrests on init
	case 0: {
		_query = format["SELECT vigiarrests FROM players WHERE playerid='%1'",_uid];
		private _arrests = (([_query,2] call OES_fnc_asyncCall) select 0);

		format ["-VIGI- %1 has %2 arrests",_uid,_arrests] spawn OES_fnc_diagLog;
		["oev_vigiarrests",_arrests] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		_player setVariable ["vigilanteArrests",_arrests,true];

		_query = format["SELECT vigiarrests_stored FROM players WHERE playerid='%1'",_uid];
		private _arrests_stored = (([_query,2] call OES_fnc_asyncCall) select 0);

		["oev_vigiarrests_stored",_arrests_stored] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		_player setVariable ["vigilanteArrestsStored",_arrests_stored,true];
	};

	//Add an arrest
	case 1: {
		_query = format["UPDATE players SET vigiarrests = vigiarrests + 1 WHERE playerid='%1'",_uid];
		[_query,1] spawn OES_fnc_asyncCall;
		private _arrestCount = _player getVariable ["vigilanteArrests",0];
		_arrestCount = _arrestCount + 1;
		["oev_vigiarrests",_arrestCount] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		_player setVariable ["vigilanteArrests",_arrestCount,true];
	};

	//Down a tier
	case 2: {
		private _arrests = _player getVariable ["vigilanteArrests",0];
		private _newArrestCount = (switch (true) do {
			case (_arrests >= 200): {100};
			case (_arrests >= 100): {50};
			case (_arrests >= 50): {25};
			default {0};
		});
		["oev_vigiarrests",_newArrestCount] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		_player setVariable ["vigilanteArrests",_newArrestCount,true];
		_query = format["UPDATE players SET vigiarrests = %2 WHERE playerid='%1'",_uid,_newArrestCount];
		[_query,1] call OES_fnc_asyncCall;
	};

	//Wipe
	case 3: {
		_player setVariable ["vigilanteArrests",0,true];
		["oev_vigiarrests",0] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		_query = format["UPDATE players SET vigiarrests = 0 WHERE playerid='%1'",_uid];
		[_query,1] call OES_fnc_asyncCall;
	};

	//Store
	case 4: {
		private _arrests = _player getVariable ["vigilanteArrests",0];
		_player setVariable ["vigilanteArrestsStored",_arrests,true];
		["oev_vigiarrests_stored",_arrests] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		_query = format["UPDATE players SET vigiarrests_stored = %1 WHERE playerid='%2'",_arrests,_uid];
		[_query,1] call OES_fnc_asyncCall;
		format ["-VIGI- %1 (%2) stored %3 arrests",_uid, name player, _arrests] spawn OES_fnc_diagLog;

		//clear current
		_player setVariable ["vigilanteArrests",0,true];
		["oev_vigiarrests",0] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		_query = format["UPDATE players SET vigiarrests = 0 WHERE playerid='%1'",_uid];
		[_query,1] call OES_fnc_asyncCall;
	};

	//Redeem stored
	case 5: {

			//add stored to active
			private _storedArrests = _player getVariable ["vigilanteArrestsStored",0];
			_player setVariable ["vigilanteArrests",_storedArrests,true];
			["oev_vigiarrests",_storedArrests] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
			_player setVariable ["vigilanteArrestsStored",0,true];
			["oev_vigiarrests_stored",0] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
			_query = format["UPDATE players SET vigiarrests=%1, vigiarrests_stored=0 WHERE playerid='%2'",_storedArrests,_uid];
			[_query,1] call OES_fnc_asyncCall;
			format ["-VIGI- %1 (%2) claimed %3 arrests",_uid, name player, _storedArrests] spawn OES_fnc_diagLog;

	};

	default {};
};
