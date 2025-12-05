//	Author: Bryan "Tonic" Boardwine
//	File: fn_removeGang
params [
	["_onlineMembers",[],[[]]],
	["_groupID",0,[0]]
];

if(count _onlineMembers isEqualTo 0 || _groupID isEqualTo 0) exitWith {};

[format["UPDATE gangs SET active='0' WHERE id='%1'",_groupID],1] call OES_fnc_asyncCall;

[format["UPDATE gangmembers SET gangname='', gangid='-1', rank='-1' WHERE gangid='%1'",_groupID],1] call OES_fnc_asyncCall;

_result = [format["SELECT id FROM gangs WHERE active='1' AND id='%1'",_groupID],2] call OES_fnc_asyncCall;

[_groupID] remoteExec ["OEC_fnc_gang1Disbanded",_onlineMembers,false];
