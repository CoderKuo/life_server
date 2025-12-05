//	Description: Client calls this, if their internet is unplugged its never really called and wont reply,
//	if their internet is not unplugged, server responds and updates the variable allowing them to do an action

params [["_unit",objNull,[objNull]]];
if (isNull _unit) exitWith {};

["oev_didServerRespond",true] remoteExec ["OEC_fnc_netSetVar",_unit,false];