//	File: fn_addGangBldg.sqf
//	Author: Jesse "tkcjesse" Schultz
// 	Modifications: Fusah
//	Description: Adds a gang house to the database

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

uiSleep round(random(5));
uiSleep round(random(5));
uiSleep round(random(5));

if (isNull _player) exitWith {};

private _query = format ["SELECT id FROM gangbldgs WHERE gang_id='%1' AND gang_name='%2' AND owned='1' AND server='%3'",_gangId,_gangName,olympus_server];
private _queryResult = [_query,2] call OES_fnc_asyncCall;

if (count _queryResult != 0) exitWith {
	[1,"购买失败,你的帮派已经拥有了一个帮派建筑!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_houseTransaction",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

_query = format ["SELECT id FROM gangbldgs WHERE pos='%1' AND server='%2' AND owned='1'",_buildingPos,olympus_server];
_queryResult = [_query,2] call OES_fnc_asyncCall;

if (count _queryResult != 0) exitWith {
	[1,"购买失败,这里已经被人购买了."] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_houseTransaction",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

_query = format["SELECT COUNT(*) FROM gangmembers WHERE gangid='%1' AND gangname='%2'",_gangId,_gangName];
_queryResult = (([_query,2] call OES_fnc_asyncCall) select 0);

if (_queryResult < 8) exitWith {
	[1,"购买失败,你的帮派必须拥有8个以上成员!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_houseTransaction",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

_query = format["SELECT bank FROM gangs WHERE id='%1'",_gangId];
_queryResult = (([_query,2] call OES_fnc_asyncCall) select 0);

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

_query = format ["INSERT INTO gangbldgs (owner, classname, pos, inventory, owned, gang_id, gang_name, server, crate_count, lastpayment, nextpayment, physical_inventory) VALUES('%1', '%2', '%3', '""[[],0]""', '1', '%4', '%5', '%6', '2', NOW(), DATE_ADD(NOW(),INTERVAL 31 DAY), '""[[],0]""')",_uid,_classname,_buildingPos,_gangId,_gangName,olympus_server];
_queryResult = [_query,1] call OES_fnc_asyncCall;

private _logHistory = format ["INSERT INTO gangbankhistory (name,playerid,type,amount,gangid) VALUES('%1','%2','3','%3','%4')",name _player,getPlayerUID _player,20000000,_gangId];
[_logHistory,1] call OES_fnc_asyncCall;

uiSleep round(random(5));

_query = format ["SELECT id FROM gangbldgs WHERE server='%1' AND owner='%2' AND owned='1' AND pos='%3'",olympus_server,_uid,_buildingPos];
_queryResult = [_query,2] call OES_fnc_asyncCall;
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
