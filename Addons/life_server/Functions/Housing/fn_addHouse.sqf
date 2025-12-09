//	Author: Bryan "Tonic" Boardwine
//	File: fn_addHouse.sqf
//	Description: Handles second part of house buying after purchase approved
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_house","_uid","_housePos","_query","_player","_houseID"];
_player = param [0,ObjNull,[ObjNull]];
_house = param [1,ObjNull,[ObjNull]];
_price = param [2,-1,[0]];
if(isNull _house || isNull _player) exitWith {};

_uid = getPlayerUID _player;
_housePos = getPosATL _house;
_houseID = _house getVariable ["house_id",-1];

// 检查房屋是否已被拥有
_queryResult = ["exists", [str _housePos, str olympus_server]] call DB_fnc_houseMapper;

if(isNull _player) exitWith {};
if(count _queryResult != 0 && ((_house getVariable ["for_sale",""]) isEqualTo "")) exitWith {
	[[1,"Purchase request denied. Someone already owns this house."],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
	[[_house,3, _uid],"OEC_fnc_houseOwnership",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};
if (_price == -1 && !((_house getVariable ["for_sale",""]) isEqualTo "")) exitWith {
	[[1,"Purchase request denied. Price was invalid."],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};
if !((_house getVariable ["for_sale",""]) isEqualTo "") then {
	// 检查拍卖状态 - 使用房屋ID而不是查询结果数组
	private _houseIdForAuction = if (_houseID != -1) then { _houseID } else { _queryResult select 0 };
	_queryResult = ["isinauction", [str _houseIdForAuction, str olympus_server]] call DB_fnc_houseMapper;
};
if (!((_house getVariable ["for_sale",""]) isEqualTo "") && {_price != (_queryResult select 0)}) exitWith {
	[[1,"Purchase request denied. Price did not match with DB. Please contact a Staff Member"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
	[[_house,5, _uid,_price],"OEC_fnc_houseOwnership",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};


if !((_house getVariable ["for_sale",""]) isEqualTo "") then {
	if (_houseID == -1) then {
		_queryResult = ["exists", [str _housePos, str olympus_server]] call DB_fnc_houseMapper;
		_houseID = (_queryResult select 0);
	};
	_playerKeys = [];
	_playerKeys = [_playerKeys] call OES_fnc_escapeArray;

	// 获取卖家信息
	private _sellerUID = (_house getVariable ["for_sale",""]) select 0;
	private _buyerName = name _player;
	private _houseType = typeOf _house;
	private _houseDisplayName = getText(configFile >> "CfgVehicles" >> _houseType >> "displayName");

	// 更新房屋所有者
	["updateowner", [str _houseID, _sellerUID, _uid, _playerKeys, str olympus_server]] call DB_fnc_houseMapper;
	// 更新房产经纪人现金
	["updaterealtorcash", [_sellerUID, _price, "add"]] call DB_fnc_playerMapper;
	// 记录售房历史
	["addhousesalehistory", [_sellerUID, _houseDisplayName, _price, _buyerName]] call DB_fnc_playerMapper;
} else {
	// 插入新房屋
	["insert", [_uid, str _housePos, str olympus_server]] call DB_fnc_houseMapper;
};

uiSleep 0.5;
// 获取新房屋ID
_queryResult = ["exists", [str _housePos, str olympus_server]] call DB_fnc_houseMapper;
_house setVariable["house_id",(_queryResult select 0),true];
_house setVariable["keyPlayers",[],true];
_house setVariable["house_expire",45,true];

if(isNull _player) exitWith {};
if !((_house getVariable ["for_sale",""]) isEqualTo "") then {
	[[_house,4,_uid,_price],"OEC_fnc_houseOwnership",(owner _player),false] spawn OEC_fnc_MP;
} else {
	[[_house,1,_uid],"OEC_fnc_houseOwnership",(owner _player),false] spawn OEC_fnc_MP;
};
