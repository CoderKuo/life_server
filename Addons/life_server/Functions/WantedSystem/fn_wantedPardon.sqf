//	File: fn_wantedPardon.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Unwants / pardons a person from the wanted list.

params [["_uid","",[""]]];
if (_uid isEqualTo "") exitWith {};

private _playerNetID = [_uid] call OES_fnc_getPlayer;
if !(_playerNetID isEqualTo 0) then {
	[999,_uid] remoteExec ["OEC_fnc_updateWanted",_playerNetID,false];
};

private _index = [_uid,life_wanted_list] call OEC_fnc_index;
if !(_index isEqualTo -1) then {
	life_wanted_list set [_index,-1];
	life_wanted_list deleteAt (life_wanted_list find -1);
};