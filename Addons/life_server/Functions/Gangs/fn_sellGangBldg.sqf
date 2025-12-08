//	File: fn_sellGangBldg.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Sells off a gang building and adjusts the DB
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_building",objNull,[objNull]],
	["_player",objNull,[objNull]]
];
if (isNull _player || isNull _building) exitWith {
	[1,"No ones in the market to buy your gang building, try again later. (error occurred)"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_houseTransaction",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

private _failed = false;
private _buildingID = _building getVariable ["bldg_id",-2];
private _gangID = _building getVariable ["bldg_gangid",-2];
private _gangName = _building getVariable ["bldg_gangName",""];
if (_buildingID isEqualTo -2 || _gangID isEqualTo -2 || _gangName isEqualTo "") then {_failed = true;};
if (_failed) exitWith {
	[1,"No ones in the market to buy your gang building, try again later. (error occurred)"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
	["oev_houseTransaction",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
	["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _player),false];
};

uiSleep round(random(5));
uiSleep round(random(5));

// 使用 Mapper 卖出建筑
["sellbuilding", [str _gangID, _gangName, str olympus_server]] call DB_fnc_gangMapper;

_building setVariable ["bldg_id",nil,true];
_building setVariable ["bldg_gangid",nil,true];
_building setVariable ["bldg_gangName",nil,true];
_building setVariable ["bldg_owner",nil,true];

if (isNull _player) exitWith {};
[_building] remoteExec ["OEC_fnc_gangSellOff",(owner _player),false];
