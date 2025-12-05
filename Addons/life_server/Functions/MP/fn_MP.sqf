//	Author: Karel Moricky
//	Modified by Poseidon to utilize remoteExec engine command for better performance.
//	Further modified by djwolf to take advantage of the param engine command, rather than using the BIS_fnc_param fuction

//	Description:
//	Send function for remote execution (and executes locally if conditions are met)
//	Parameter(s):
//		0: ANY - function params
//		1: STRING - function name
//		2 (Optional):
//			BOOL - true to execute on every client, false to execute it on server only
//			OBJECT - the function will be executed only where unit is local [default: everyone]
//			GROUP - the function will be executed only on client who is member of the group
//			SIDE - the function will be executed on all players of the given side
//			NUMBER - the function will be executed only on client with the given ID
//			ARRAY - array of previous data types
//		3 (Optional): BOOL - true for persistent call (will be called now and for every JIP client) [default: false]
//
//	Returns:
//	ARRAY - sent packet DESCRIPTIONEND

//Target of -2 runs everywhere except the server, which is optimal for things like texturing players or updating a vehicle skin.
with missionnamespace do
{
	private ["_params","_functionName","_target","_isPersistent","_isCall","_ownerID","_mpPacket","_defaults","_same"];

	_params = param [0,[],[[]]];
	_functionName =	param [1,"",[""]];
	_target = param [2,true,[objnull,false,0,[],sideUnknown,grpnull,""]];
	_isPersistent =	param [3,false,[false,""]];
	_isCall = param [4,false,[false]];

	//remoteExec doesn't support bool param, retype to number is needed
	if (_target isEqualType true) then
	{
		_target = [2,0] select _target;
	};

	if (_isCall) then
	{
		_params remoteExecCall [_functionName,_target,false];
	}
	else
	{
		_params remoteExec [_functionName,_target,false];
	}
};