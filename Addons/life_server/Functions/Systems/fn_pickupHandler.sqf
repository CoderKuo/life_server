//  File: fn_pickupHandler.sqf
//	Author: Bryan "Tonic" Boardwine
// 	Modified by: Kurt

//	Description: Called on picking an item up from a brief

params [
	["_player",ObjNull,[ObjNull]],
	["_obj",ObjNull,[ObjNull]]
];
uiSleep 0.5;
_obj setVariable ["inUse",_player,true];
