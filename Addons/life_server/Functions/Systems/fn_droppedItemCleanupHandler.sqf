//	File: fn_droppedItemCleanupHandler.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description:
//	Handles the array of items being used in the cleanup script

params [
	["_obj",objNull,[objNull]]
];
if (isNull _obj) exitWith {};
if (_obj in serv_weaponholder_cleanup) exitWith {};
private _exit = false;
{
     if ((_x select 0) isEqualTo _obj) exitwith {_exit = true;};
 } forEach serv_weaponholder_cleanup;
if (_exit) exitWith {};

serv_weaponholder_cleanup pushBack [_obj,(serverTime + (900))];

