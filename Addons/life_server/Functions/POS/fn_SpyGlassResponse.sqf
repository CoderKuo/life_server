//	Author: Poseidon
//	Description: The client responds to the server if they're caught without spyglass running, so that on the 2nd time caught they get banned

private["_cheater","_cheaterID"];
_cheater = [_this,0,objNull,[objNull]] call BIS_fnc_param;

if(isNull _cheater) exitWith {};
if(!isPlayer _cheater) exitWith {};
_cheaterID = owner _cheater;

if(OS_playersCaught find _cheater != -1) then {
	"" serverCommand format["#exec ban %1", _cheaterID];//Second detection, ban em
} else {
	OS_playersCaught pushBack _cheater;//First detection, add em to the list
};