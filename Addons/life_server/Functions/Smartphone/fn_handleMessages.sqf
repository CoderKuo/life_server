//	File: fn_handleMessages.sqf
//	Author: Silex
params [
	["_target",objNull,[objNull]],
	["_msg","",[""]],
	["_player",objNull,[objNull]],
	["_type",-2,[0]]
];

// log and exit if sender is spoofed or sender DNE
private _sender = [remoteExecutedOwner] call OES_fnc_owner2Player;
if (_sender isEqualTo objNull || _sender != _player) exitWith {
	// [3,_sender,["Spoofed Message Sender"]] call OES_fnc_handleDisc;
};

//log and exit if sender is not the required admin level
if((_type in [4,5,6,7,8,11]) && (_player getVariable["playerAdminLevel",0]) < 1) exitWith {
	// [3,_sender,["Message Sender Not Admin"]] call OES_fnc_handleDisc;
};

switch(_type) do {
	//normal message
	case 0: {
		if(isNULL _target)  exitWith {};
		private _to = call compile format["%1", _target];
		[_msg,name _player,0,_player] remoteExec ["OEC_fnc_clientMessage",_to,false];
		private _query = format["INSERT INTO messages (fromID, toID, message, fromName, toName) VALUES('%1', '%2', '""%3""', '%4', '%5')",(getPlayerUID _player),(getPlayerUID _target),[_msg] call OES_fnc_mresString,(name _player),(name _target)];
		format ["Text Message Query: %1",_query] call OES_fnc_diagLog;
		[_query,1] call OES_fnc_asyncCall;
	};
	//message to cops
	case 1: {
		[_msg,name _player,1,_player] remoteExec ["OEC_fnc_clientMessage",west,false];
	};
	//to admins
	case 2: {
		[_msg,name _player,2,_player] remoteExec ["OEC_fnc_clientMessage",-2,false];
	};
	//ems request
	case 3:	{
		if (side _player isEqualTo west) exitWith {[_msg,name _player,5,_player,true] remoteExec ["OEC_fnc_clientMessage",independent,false];};
		[_msg,name _player,5,_player] remoteExec ["OEC_fnc_clientMessage",independent,false];
	};
	//adminToPerson
	case 4:	{
		private _to = call compile format["%1", _target];
		if(isNull _to) exitWith {};

		[_msg,name _player,3] remoteExec ["OEC_fnc_clientMessage",_to,false];
	};
	//adminMsgAll
	case 5:	{
		[_msg,name _player,4] remoteExec ["OEC_fnc_clientMessage",-2,false];
	};

	//adminMsgAll
	case 6:	{
		[_msg,name _player,6,_player] remoteExec ["OEC_fnc_clientMessage",-2,false];
	};

	//eventMessage
	case 7:	{
		[_msg,name _player,7,_player] remoteExec ["OEC_fnc_clientMessage",-2,false];
	};

	//eventMessage
	case 8:	{
		[_msg,name _player,8,_player] remoteExec ["OEC_fnc_clientMessage",-2,false];
	};

	// Panic Button
	case 9:	{
		[_msg,name _player,9,_player] remoteExec ["OEC_fnc_clientMessage",-2,false];
	};

	case 10: {
		private _to = call compile format["%1", _target];
		[_msg,name _player,10] remoteExec ["OEC_fnc_clientMessage",_to,false];
	};

	//adminMsgCivs
	case 11:	{
		[_msg,name _player,11,_player] remoteExec ["OEC_fnc_clientMessage",civilian,false];
	};
};
