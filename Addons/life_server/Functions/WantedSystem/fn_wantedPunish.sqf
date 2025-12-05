//	File: fn_wantedPunish.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Checks to see if the person is wanted, if they are it will punish them.
params [["_uid","",[""]]];

if(_uid isEqualTo "") exitWith {};

if(([_uid,life_wanted_list] call OEC_fnc_index) isEqualTo -1) exitWith {};

private _playerNetID = [_uid] call OES_fnc_getPlayer;
if(_playerNetID != 0) then {
	[0] remoteExec ["OEC_fnc_removeLicenses",_playerNetID,false];
};