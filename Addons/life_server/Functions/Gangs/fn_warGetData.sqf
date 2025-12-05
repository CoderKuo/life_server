//  File: fn_warGetData.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Gets Kills and Deaths for gang wars
params [
	["_mode",0,[0]],
	["_unit",objNull,[objNull]],
	["_gangID",0,[0]],
	["_gangIDTwo",0,[0]]
];
if (isNull _unit || _gangID isEqualTo 0 || _gangIDTwo isEqualTo 0) exitWith {};

switch (_mode) do {
	case 0: {
		_query = format ["SELECT init_gangid, ikills, ideaths, acpt_gangid, akills, adeaths, DATEDIFF(now(),date) FROM gangwars WHERE active='1' AND (init_gangid='%1' OR acpt_gangid='%1') AND (init_gangid='%2' OR acpt_gangid='%2')",_gangID,_gangIDTwo];
		_queryResult = [_query,2,true] call OES_fnc_asyncCall;
		if ((count _queryResult) isEqualTo 0) exitWith {};

		["life_gang_warReady",true] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
		["life_gang_warData",(_queryResult select 0)] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
	};
	case 1: {};
};