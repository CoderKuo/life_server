//	Author: Bryan "Tonic" Boardwine
//	Description: Updates the gang information?
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_mode","_group","_groupID","_bank"];
_mode = param [0,0,[0]];
_group = param [1,grpNull,[grpNull]];

if(isNull _group) exitWith {}; //FAIL

_groupID = _group getVariable["gang_id",-1];
if(_groupID == -1) exitWith {};

switch (_mode) do {
	case 0: {
		_bank = [(_group getVariable ["gang_bank",0])] call OES_fnc_numberToString;
		// 使用 Mapper 更新帮派银行
		["updategangbank", [str _groupID, str _bank]] call DB_fnc_gangMapper;
	};

	case 1: {
		_bank = [(_group getVariable ["gang_bank",0])] call OES_fnc_numberToString;
		// 使用 Mapper 更新帮派银行
		["updategangbank", [str _groupID, str _bank]] call DB_fnc_gangMapper;
	};
};
