//	File: fn_addGangBldg.sqf
//	Author: Jesse "tkcjesse" Schultz
// 	Modifications: Fusah
//	Description: Adds a gang house to the database
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_player",objNull,[objNull]],
	["_building",objNull,[objNull]],
	["_classname","",[""]],
	["_gangId",-2,[0]],
	["_gangName","",[""]]
];
if (isNull _building || isNull _player || _classname isEqualTo "" || _gangId isEqualTo -2 || _gangName isEqualTo "") exitWith {};
if !(typeOf _building isEqualTo "Land_i_Shed_Ind_F") exitWith {};
if (isNull _player) exitWith {};

private _check = (_gangName find "'" != -1);
if (_check) exitWith {};

private _uid = getPlayerUID _player;
private _buildingPos = getPosATL _building;

if (isNull _player) exitWith {};

// 使用 Mapper 检查帮派是否已有建筑
private _queryResult = ["getbuildingid", [str _gangId, _gangName, str olympus_server]] call DB_fnc_gangMapper;

if (count _queryResult != 0) exitWith {
	[1,"购买失败,你的帮派已经拥有了一个帮派建筑!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_houseTransaction",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

// 检查位置是否已被占用
_queryResult = ["buildingexists", [str _buildingPos, str olympus_server]] call DB_fnc_gangMapper;

if (count _queryResult != 0) exitWith {
	[1,"购买失败,这里已经被人购买了."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_houseTransaction",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

// 统计帮派成员数量
_queryResult = (["countmembers", [str _gangId, _gangName]] call DB_fnc_gangMapper) select 0;

// 检查管理员权限 (adminlvl 是从数据库加载并同步到玩家对象的)
private _isAdmin = (_player getVariable ["adminlvl", 0]) > 0;

if (_queryResult < 8 && !_isAdmin) exitWith {
	[1,"购买失败,你的帮派必须拥有8个以上成员!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_houseTransaction",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

// 获取帮派银行余额
_queryResult = (["getgangbank", [str _gangId]] call DB_fnc_gangMapper) select 0;

_exit = false;
if (life_donation_house) then {
	if (_queryResult < 17000000) exitWith {
		[[1,"你的帮派资金账户没有足够的钱!"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
		[["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
		[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
		_exit = true;
	};
	[2,_gangId,_player,-(17000000)] call OES_fnc_gangBank;
	} else {
	if (_queryResult < 20000000) exitWith {
		[[1,"你的帮派资金账户没有足够的钱!"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
		[["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
		[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
		_exit = true;
	};
	[2,_gangId,_player,-(20000000)] call OES_fnc_gangBank;
};

if (_exit) exitWith {};

// 使用 Mapper 创建建筑
["createbuilding", [_uid, _classname, str _buildingPos, str _gangId, _gangName, str olympus_server]] call DB_fnc_gangMapper;

// 记录历史
["addbankhistory", [name _player, getPlayerUID _player, "3", "20000000", str _gangId]] call DB_fnc_gangMapper;

uiSleep 0.5;

// 获取新建筑ID
_queryResult = ["getbuildingbypos", [str olympus_server, _uid, str _buildingPos]] call DB_fnc_gangMapper;
_building setVariable ["bldg_id",(_queryResult select 0),true];

if (isNull _player) exitWith {};

_building setVariable ["bldg_owner",(getPlayerUID _player),true];
_building setVariable ["bldg_gangName",_gangName,true];
_building setVariable ["bldg_gangid",_gangId,true];
_building setVariable ["storageCapacity",1000,true];
_building setVariable ["physicalStorageCapacity",300,true];
_building setVariable ["locked",true,true];
_building setVariable ["inv_locked",true,true];
_building setVariable ["trunk",[[],0],true];
_building setVariable ["bldg_payment",[31,0],true];
_building setVariable ["Trunk",[[],0]];
_building setVariable ["PhysicalTrunk",[[],0]];

[_building,_classname] remoteExec ["OEC_fnc_gangBldgOwnership",(owner _player),false];
