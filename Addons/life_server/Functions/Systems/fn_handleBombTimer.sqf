//	File: fn_handleBombTimer.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Handles bomb timers set on fed/bw

private ["_time"];

params [
	["_vault",objNull,[objNull]],
	["_playerID","NA",[""]]
];
if (isNull _vault) exitWith {};
if (_vault getVariable ["chargeplaced",false]) exitWith {};

_vault setVariable ["chargeplaced",true,true];
[[_vault,"fedAlarm"],"OEC_fnc_say3D",-2,false] spawn OEC_fnc_MP;

switch (typeOf _vault) do {
	case "Land_CargoBox_V1_F": {
		[[1,"联邦储备局的保险箱里装了炸药！你有20分钟的时间解除指控."],"OEC_fnc_broadcast",west,false] spawn OEC_fnc_MP;
		[_vault] remoteExec ["OEC_fnc_demoChargeTimer",[west, independent], false];
		[1] call OES_fnc_handleComplexMarker;
		[format['{"event":"Planted Bomb", "type":"Fed", "player_id":"%3", "position":%1, "cops_online":%2}',position _vault, west countSide playableUnits, _playerID]] call OES_fnc_logIt;
		_time = time + (60 * 20);
	};

	case "CargoNet_01_box_F": {
		[[1,"阿尔蒂斯银行保险库里装了炸药！你有15分钟的时间解除炸弹."],"OEC_fnc_broadcast",west,false] spawn OEC_fnc_MP;
		[_vault] remoteExec ["OEC_fnc_demoChargeTimer",[west, independent], false];
		[12, _vault] call OES_fnc_handleComplexMarker;
		[format['{"event":"Planted Bomb", "type":"Bank", "player_id":"%3", "position":%1, "cops_online":%2}',position _vault, west countSide playableUnits, _playerID]] call OES_fnc_logIt;
		_time = time + (60 * 15);
	};

	case "Land_Dome_Big_F": {
		[[1,"黑水镇的设施已经装上了炸药！你有20分钟的时间解除指控."],"OEC_fnc_broadcast",west,false] spawn OEC_fnc_MP;
		[_vault] remoteExec ["OEC_fnc_demoChargeTimer",[west, independent], false];
		[8] call OES_fnc_handleComplexMarker;
		_vault setVariable ["robtime",(time + (60 * 20)),true];
		[format['{"event":"Planted Bomb", "type":"Blackwater", "player_id":"%3", "position":%1, "cops_online":%2}',position _vault, west countSide playableUnits, _playerID]] call OES_fnc_logIt;
		_time = time + (60 * 20);
	};

	case "Land_Mil_WallBig_4m_battered_F": {
		[[1,"监狱墙上装了炸药！你有15分钟的时间解除指控."],"OEC_fnc_broadcast",west,false] spawn OEC_fnc_MP;
		[_vault] remoteExec ["OEC_fnc_demoChargeTimer",[west, independent], false];
		[5] call OES_fnc_handleComplexMarker;
		[format['{"event":"Planted Bomb", "type":"Jail", "player_id":"%3", "position":%1, "cops_online":%2}',position _vault, west countSide playableUnits, _playerID]] call OES_fnc_logIt;
		_time = time + (60 * 15);
	};
};

_vault setVariable ["bombtime",_time];

waitUntil {uiSleep .5; (round(_time - time) < 1) || !(_vault getVariable ["chargeplaced",false])};
uiSleep 1;

if !(_vault getVariable ["chargeplaced",false]) exitWith {
	_vault setVariable ["bombtime",0];
	switch (typeOf _vault) do {
		case "Land_CargoBox_V1_F": {
			[[1,"APD阻止了美联储的抢劫！"],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			[format['{"event":"Defused Bomb", "type":"Fed", "player_id":"%3", "position":%1, "cops_online":%2}',position _vault, west countSide playableUnits,""]] call OES_fnc_logIt;
			oev_allFederalCooldown = (time + 900);
			publicVariable "oev_allFederalCooldown";
		};

		case "CargoNet_01_box_F": {
			[[1,"APD阻止了银行抢劫！"],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			[13, _vault] call OES_fnc_handleComplexMarker;
			[format['{"event":"Defused Bomb", "type":"Bank", "player_id":"%3", "position":%1, "cops_online":%2}',position _vault, west countSide playableUnits,""]] call OES_fnc_logIt;
		};

		case "Land_Dome_Big_F": {
			[[1,"APD已经阻止了黑水工厂的抢劫!"],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			[9] call OES_fnc_handleComplexMarker;
			_vault setVariable ["robtime",time,true];
			[format['{"event":"Defused Bomb", "type":"Blackwater", "player_id":"%3", "position":%1, "cops_online":%2}',position _vault, west countSide playableUnits,""]] call OES_fnc_logIt;
			oev_allFederalCooldown = (time + 900);
			publicVariable "oev_allFederalCooldown";
		};

		case "Land_Mil_WallBig_4m_battered_F": {
			[[1,"越狱已经停止了!"],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			[4] call OES_fnc_handleComplexMarker;
			[format['{"event":"Defused Bomb", "type":"Jail", "player_id":"%3", "position":%1, "cops_online":%2}',position _vault, west countSide playableUnits,""]] call OES_fnc_logIt;
			oev_allFederalCooldown = (time + 900);
			publicVariable "oev_allFederalCooldown";
		};
	};
};
if !(typeOf _vault isEqualTo "CargoNet_01_box_F") then {
	"GrenadeHand_stone" createVehicle [getPosATL _vault select 0, getPosATL _vault select 1, (getPosATL _vault select 2)+0.5];
	"GrenadeHand_stone" createVehicle [getPosATL _vault select 0, getPosATL _vault select 1, (getPosATL _vault select 2)+0.5];
	"GrenadeHand_stone" createVehicle [getPosATL _vault select 0, getPosATL _vault select 1, (getPosATL _vault select 2)+0.5];
};
_vault setVariable ["chargeplaced",false,true];
_vault setVariable ["safe_open",true,true];
_vault setVariable ["bombtime",0];

if (typeOf _vault isEqualTo "Land_Dome_Big_F") then {
	_blackwaterDome = nearestObject [[20898.6,19221.7,0.00143909],"Land_Dome_Big_F"];
	for "_i" from 1 to 3 do {_blackwaterDome setVariable[format["bis_disabled_Door_%1",_i],0,true]; _blackwaterDome animate [format["Door_%1_rot",_i],1];};
	[] spawn OES_fnc_spawnBlackwaterLoot;
	_blackwaterDome setVariable ["bwcooldown",true,true];
	oev_allFederalCooldown = (time + 900);
	publicVariable "oev_allFederalCooldown";
};

if (typeOf _vault isEqualTo "Land_Mil_WallBig_4m_battered_F") then {
	[0,jailwall] call OES_fnc_adminInvis;
	[1,jailwall_destroyed] call OES_fnc_adminInvis;
	[format['{"event":"Detonated Bomb", "type":"Jail", "position":%1, "cops_online":%2, "spawned":"null"}',position _vault, west countSide playableUnits]] call OES_fnc_logIt;
	oev_allFederalCooldown = (time + 900);
	publicVariable "oev_allFederalCooldown";
};

if (typeOf _vault isEqualTo "Land_CargoBox_V1_F") then {
	_onlineCops = {side _x isEqualTo west} count playableUnits;
	_stackExtra = (switch (true) do {
		case (_onlineCops >= 25): {75};
		case (_onlineCops >= 20): {50};
		case (_onlineCops >= 15): {25};
		default {0};
	});
	private _numGoldBars = ceil(400 - random(200 - _stackExtra));
	_vault setVariable ["safe",_numGoldBars,true];
	[[format['{"event":"Federal Reserve Gold generated", "value":"%1""}',_numGoldBars]],"OES_fnc_logIt",false,false] call OEC_fnc_MP;
	[format['{"event":"Detonated Bomb", "type":"Fed", "position":%1, "cops_online":%2, "spawned":{"gold": %3}}',position _vault, west countSide playableUnits, _numGoldBars]] call OES_fnc_logIt;
	oev_allFederalCooldown = (time + 900);
	publicVariable "oev_allFederalCooldown";
	_fedDome = nearestObject [[16019.5,16952.9,0],"Land_Dome_Big_F"];
	_fedDome setVariable[format["bis_disabled_Door_%1",2],0,true];
	_fedDome setVariable[format["bis_disabled_Door_%1",3],0,true];
};

if (typeOf _vault isEqualTo "CargoNet_01_box_F") then {
	_moneyBags = 65 + (5 * oev_bankDeaths);
	[format['{"event":"Detonated Bomb", "type":"Bank", "position":%1, "cops_online":%2, "spawned":{"moneybags": %3}}',position _vault, west countSide playableUnits, _moneyBags]] call OES_fnc_logIt;
	_vault setVariable ["safe",_moneyBags,true];
	_vault setVariable ["bankCooldown",(serverTime + 600),true];
	uiSleep 2400;
	if(_vault getVariable["safe_open",false]) then {
		_vault setVariable ["safe_open",false,true];
		_vault setVariable ["safe",0,true];
		[13, _vault] call OES_fnc_handleComplexMarker;
	};
};
