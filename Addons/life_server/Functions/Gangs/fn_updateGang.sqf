//	Author: Bryan "Tonic" Boardwine
//	Description: Updates the gang information?

private["_mode","_group","_groupID","_bank","_query","_owner"];
_mode = param [0,0,[0]];
_group = param [1,grpNull,[grpNull]];

if(isNull _group) exitWith {}; //FAIL

_groupID = _group getVariable["gang_id",-1];
if(_groupID == -1) exitWith {};

switch (_mode) do {
	case 0: {
		_bank = [(_group getVariable ["gang_bank",0])] call OES_fnc_numberSafe;

		_query = format["UPDATE gangs SET bank='%1' WHERE id='%2'",_bank,_groupID];
	};

	case 1: {
		_query = format["UPDATE gangs SET bank='%1' WHERE id='%2'",([(_group getVariable ["gang_bank",0])] call OES_fnc_numberSafe),_groupID];
	};
};

if(!isNil "_query") then {
	[_query,1] call OES_fnc_asyncCall;
};
