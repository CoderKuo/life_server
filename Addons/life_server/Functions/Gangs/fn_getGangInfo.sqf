//	File: fn_getGangInfo.sqf
//	Author: Poseidon

private["_query2","_query","_queryResult2","_queryResult"];
params [
	["_mode",0,[0]],
	["_gangID",-1,[0]],
	["_unit",objNull,[objNull]]
];

//Error checks
if(_gangID isEqualTo -1 || isNull _unit) exitWith {
	if(!isNull _unit) then {
		[[]] remoteExec ["OEC_fnc_populateInfo",(owner _unit),false];
	};
};

switch (_mode) do {
	case 0: {
		_query = format["SELECT playerid, name, rank FROM gangmembers WHERE gangid='%1' ORDER BY rank DESC",_gangID];
		_queryResult = [_query,2,true] call OES_fnc_asyncCall;

		_query2 = format["SELECT bank FROM gangs WHERE id='%1'",_gangID];
		_queryResult2 = [_query2,2] call OES_fnc_asyncCall;

		[[_queryResult,_queryResult2],"OEC_fnc_populateInfo",(owner _unit),false] spawn OEC_fnc_MP;
	};

	case 1: {

	};
};
