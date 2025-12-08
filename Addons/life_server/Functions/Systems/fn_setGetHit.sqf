//	File: fn_getSetHit.sqf
//	Author: TheCmdrRex
//	Description: Server-side function which either sets hit on player or fetches a hit placed on owner player at login
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_mode",-1,[0]],
	["_target",objNull,[objNull]],
	["_issuer",objNull,[objNull]],
	["_bounty",-1,[0]],
	["_bountyTime",-1,[0]]
];
private ["_queryResult"];

// Yay some checks
if (_mode < 1 || _mode > 3) exitWith {};
if (isNull _target) exitWith {};

// Mode for setting hit onto a player
if (_mode == 1) then {
	if (_bounty < 200000 || _bounty > 50000000) exitWith {};
	if (isNull _issuer) exitWith {};
	if (_bountyTime < 720) exitWith {};
	// 使用 miscMapper 插入赏金
	["hitmaninsert", [getPlayerUID _target, str _bounty, str _bountyTime, getPlayerUID _issuer]] call DB_fnc_miscMapper;

	_target setVariable ["hitmanBounty",_bounty,true];
};

// Mode for retreiving current bounty from server
if (_mode == 2) then {
	// 使用 miscMapper 获取赏金
	private _queryResult = ["hitmanget", [getPlayerUID _target]] call DB_fnc_miscMapper;
	if (isNil "_queryResult") then { _queryResult = []; };
	if ((count _queryResult) isEqualTo 0) exitWith {
		_target setVariable ["hitmanBounty",0,true];
	};

	_target setVariable ["hitmanBounty",(_queryResult select 0),true];
	[_target,(_queryResult select 0),(_queryResult select 1)] remoteExec ["OEC_fnc_handleHit",_target,false];
};

// Mode for removing bounty from DB
if (_mode == 3) then {
	// 使用 miscMapper 停用赏金
	["hitmandeactivate", [getPlayerUID _target]] call DB_fnc_miscMapper;

	_target setVariable ["hitmanBounty",0,true];
};
