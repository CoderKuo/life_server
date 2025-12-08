//	File: fn_getGangInfo.sqf
//	Author: Poseidon
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_queryResult2","_queryResult"];
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
		// 使用 Mapper 获取帮派成员
		_queryResult = ["getmembers", [str _gangID]] call DB_fnc_gangMapper;

		// 获取帮派银行
		_queryResult2 = ["getgangbank", [str _gangID]] call DB_fnc_gangMapper;

		[[_queryResult,_queryResult2],"OEC_fnc_populateInfo",(owner _unit),false] spawn OEC_fnc_MP;
	};

	case 1: {

	};
};
