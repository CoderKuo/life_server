//File: fn_vigiGetSetArrests.sqf
//Author: Jesse "tkcjesse" Schultz
//Modified: Kurt, Horizon
//Modified: 迁移到 PostgreSQL Mapper 层
params [
	["_mode",-1,[0]],
	["_player",objNull,[objNull]]
];

if (isNull _player) exitWith {};
if (_mode isEqualTo -1) exitWith {};
private ["_uid"];

_uid = getPlayerUID _player;

switch (_mode) do {

	//Fetch arrests on init
	case 0: {
		// 使用 playerMapper 获取警惕者逮捕数
		private _arrests = (["getvigiarrests", [_uid]] call DB_fnc_playerMapper) select 0;

		format ["-VIGI- %1 has %2 arrests",_uid,_arrests] spawn OES_fnc_diagLog;
		["oev_vigiarrests",_arrests] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		_player setVariable ["vigilanteArrests",_arrests,true];

		// 使用 playerMapper 获取存储的警惕者逮捕数
		private _arrests_stored = (["getvigiarrestsstored", [_uid]] call DB_fnc_playerMapper) select 0;

		["oev_vigiarrests_stored",_arrests_stored] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		_player setVariable ["vigilanteArrestsStored",_arrests_stored,true];
	};

	//Add an arrest
	case 1: {
		// 使用 playerMapper 增加警惕者逮捕数
		["incrementvigiarrests", [_uid]] spawn DB_fnc_playerMapper;
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
		// 使用 playerMapper 设置警惕者逮捕数
		["setvigiarrests", [_uid, _newArrestCount]] call DB_fnc_playerMapper;
	};

	//Wipe
	case 3: {
		_player setVariable ["vigilanteArrests",0,true];
		["oev_vigiarrests",0] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		// 使用 playerMapper 设置警惕者逮捕数为 0
		["setvigiarrests", [_uid, 0]] call DB_fnc_playerMapper;
	};

	//Store
	case 4: {
		private _arrests = _player getVariable ["vigilanteArrests",0];
		_player setVariable ["vigilanteArrestsStored",_arrests,true];
		["oev_vigiarrests_stored",_arrests] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		// 使用 playerMapper 存储警惕者逮捕数
		["storevigiarrests", [_arrests, _uid]] call DB_fnc_playerMapper;
		format ["-VIGI- %1 (%2) stored %3 arrests",_uid, name player, _arrests] spawn OES_fnc_diagLog;

		//clear current
		_player setVariable ["vigilanteArrests",0,true];
		["oev_vigiarrests",0] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
	};

	//Redeem stored
	case 5: {
		//add stored to active
		private _storedArrests = _player getVariable ["vigilanteArrestsStored",0];
		_player setVariable ["vigilanteArrests",_storedArrests,true];
		["oev_vigiarrests",_storedArrests] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		_player setVariable ["vigilanteArrestsStored",0,true];
		["oev_vigiarrests_stored",0] remoteExec ["OEC_fnc_netSetVar",(owner _player)];
		// 使用 playerMapper 兑换存储的警惕者逮捕数
		["redeemvigiarrests", [_storedArrests, _uid]] call DB_fnc_playerMapper;
		format ["-VIGI- %1 (%2) claimed %3 arrests",_uid, name player, _storedArrests] spawn OES_fnc_diagLog;
	};

	default {};
};
