//	Author: TheCmdrRex
//	File: fn_houseForSale.sqf
//	Description: Handles server side of listing houses after client part of listing house
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_house","_uid","_housePos","_player","_houseID","_queryResult"];
params [
	["_player",objNull,[objNull]],
	["_house",objNull,[objNull]],
	["_mode",-1,[0]]
];

if (isNull _house || isNull _player) exitWith {};

_uid = getPlayerUID _player;
_houseID = _house getVariable ["house_id",-1];
_housePos = getPosATL _house;

uiSleep round(random(4));
uiSleep round(random(4));
uiSleep round(random(4));

// 获取房屋所有者
_queryResult = ["getowner", [str _housePos, str olympus_server]] call DB_fnc_houseMapper;
if ((_queryResult select 0) != _uid) exitWith {
	[1,"How did you get here? You cannot list/unlist someone else's house!"] remoteExecCall ["OEC_fnc_broadcast",(owner _player)];
};

switch (_mode) do {
	// Mode 0 - List house
	case 0: {
		["updateauction", [str _houseID, _uid, str (((_house getVariable ["for_sale",""]) select 1)), str olympus_server]] call DB_fnc_houseMapper;
		[3,"You successfully listed your house for sale!<br/><br/>Players can purchase it from the realtor."] remoteExecCall ["OEC_fnc_broadcast",(owner _player)];
	};

	// Mode 1 = Unlist house
	case 1: {
		["removeauction", [str _houseID, _uid, str olympus_server]] call DB_fnc_houseMapper;
		[1,"You have taken your house off of the market"] remoteExecCall ["OEC_fnc_broadcast",(owner _player)];

	};
};
