//	File: fn_updateGangBldg.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Modifications: Fusah
//	Description: Upgrades the gang buildings virtual storage limit
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_building",objNull,[objNull]],
	["_player",objNull,[objNull]],
	["_isVirtual",true,[true]]
];
if (isNull _building || !(typeOf _building isEqualTo "Land_i_Shed_Ind_F") || isNull _player) exitWith {
	[1,"An error has occured. Try again later."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

if (_isVirtual) then {
	private _currentInv = _building getVariable ["storageCapacity",-1];
	if (((_currentInv) >= 10000) || (_currentInv isEqualTo -1)) exitWith {
		[1,"Your gang building is at maximum capacity or an error has occured."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
		["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	};

	private _gangID = _building getVariable ["bldg_gangid",-2];
	private _gangName = _building getVariable ["bldg_gangName",""];
	if (_gangID isEqualTo -2 || _gangName isEqualTo "") exitWith {
		[1,"An error has occured. Try again later."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
		["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	};

	private _exit = false;
	private _newInv = switch (_currentInv) do {
		case (1000): {2000};
		case (2000): {3000};
		case (3000): {4000};
		case (4000): {5000};
		case (5000): {6000};
		case (6000): {7000};
		case (7000): {8000};
		case (8000): {9000};
		case (9000): {10000};
		default {_exit = true;};
	};
	if (_exit) exitWith {
		[1,"An error has occured. Try again later."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
		["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	};

	// 使用 Mapper 获取帮派银行余额
	private _queryResult = (["getgangbank", [str _gangID]] call DB_fnc_gangMapper) select 0;

	if (life_donation_house) then {
		if (_queryResult < 1275000) exitWith {
			[[1,"Purchase request denied. Your gang doesnt have the required gang funds to make the purchase!"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
			[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
			_exit = true;
		};
		[2,_gangID,_player,-(1275000)] call OES_fnc_gangBank;
	} else {
		if (_queryResult < 1500000) exitWith {
			[[1,"Purchase request denied. Your gang doesnt have the required gang funds to make the purchase!"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
			[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
			_exit = true;
		};
		[2,_gangID,_player,-(1500000)] call OES_fnc_gangBank;
	};

	if (_exit) exitWith {};

	_building setVariable ["storageCapacity",_newInv,true];

	// 使用 Mapper 更新存储容量
	["updatebuildingstorage", [str _gangID, _gangName, str olympus_server, str _newInv, "virtual"]] call DB_fnc_gangMapper;

	[1,"Your gang building has been renovated!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];

	format["Player %1(%2) upgraded the storage to %3 for the shed owned by %4(%5) on server %6",name _player,getPlayerUID _player,_newInv,_gangName,_gangID,olympus_server] call OES_fnc_diagLog;

	// 记录历史
	["addbankhistory", [name _player, getPlayerUID _player, "5", "1500000", str _gangID]] call DB_fnc_gangMapper;
} else {
	private _currentPhysInv = _building getVariable ["physicalStorageCapacity",-1];
	if ((_currentPhysInv >= 900) || (_currentPhysInv isEqualTo -1)) exitWith {
		[1,"Your gang building is at maximum capacity or an error has occured."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
		["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	};

	private _gangID = _building getVariable ["bldg_gangid",-2];
	private _gangName = _building getVariable ["bldg_gangName",""];
	if (_gangID isEqualTo -2 || _gangName isEqualTo "") exitWith {
		[1,"An error has occured. Try again later."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
		["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	};

	private _exit = false;
	private _newInv = switch (_currentPhysInv) do {
		case (300): {450};
		case (450): {600};
		case (600): {750};
		case (750): {900};
		default {_exit = true;};
	};
	if (_exit) exitWith {
		[1,"An error has occured. Try again later."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
		["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	};

	// 使用 Mapper 获取帮派银行余额
	private _queryResult = (["getgangbank", [str _gangID]] call DB_fnc_gangMapper) select 0;

	if (life_donation_house) then {
		if (_queryResult < 1275000) exitWith {
			[[1,"Purchase request denied. Your gang doesnt have the required gang funds to make the purchase!"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
			[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
			_exit = true;
		};
		[2,_gangID,_player,-(1275000)] call OES_fnc_gangBank;
	} else {
		if (_queryResult < 1500000) exitWith {
			[[1,"Purchase request denied. Your gang doesnt have the required gang funds to make the purchase!"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
			[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
			_exit = true;
		};
		[2,_gangID,_player,-(1500000)] call OES_fnc_gangBank;
	};

	if (_exit) exitWith {};

	_building setVariable ["physicalStorageCapacity",_newInv,true];

	// 使用 Mapper 更新物理存储容量
	["updatebuildingstorage", [str _gangID, _gangName, str olympus_server, str _newInv, "physical"]] call DB_fnc_gangMapper;

	[1,"Your gang building has been renovated!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];

	format["Player %1(%2) upgraded the physical storage to %3 for the shed owned by %4(%5) on server %6",name _player,getPlayerUID _player,_newInv,_gangName,_gangID,olympus_server] call OES_fnc_diagLog;

	// 记录历史
	["addbankhistory", [name _player, getPlayerUID _player, "5", "1500000", str _gangID]] call DB_fnc_gangMapper;
};
