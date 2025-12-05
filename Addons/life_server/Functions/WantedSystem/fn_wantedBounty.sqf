//	File: fn_wantedBounty.sqf
//	Author: Bryan "Tonic" Boardwine"
//	Description: Checks if the person is on the bounty list and awards the cop for killing them.

params [
	["_civ",objNull,[objNull]],
	["_cop",objNull,[objNull]],
	["_half",false,[false]],
	["_cLogFlag", false, [false]]
];

if(isNull _civ) exitWith {};
if(isNull _cop && _cLogFlag) exitWith {deleteVehicle _civ;};
if(isNull _cop) exitWith {};

private _id = [(_civ getVariable ["steam64id", getPlayerUID _civ]),life_wanted_list] call OEC_fnc_index;

if !(_cLogFlag) then {
	if !(_id isEqualTo -1) then {
		if(_half) then {
			[((life_wanted_list select _id) select 3) - 1,((life_wanted_list select _id) select 3),_civ] remoteExec ["OEC_fnc_bountyReceive",_cop,false];
			serv_lethalTracker pushBack [_civ getVariable ["steam64id", getPlayerUID _civ], _cop getVariable ["steam64id", getPlayerUID _cop]];
		} else {
			[((life_wanted_list select _id) select 3),((life_wanted_list select _id) select 3),_civ] remoteExec ["OEC_fnc_bountyReceive",_cop,false];
		};
	};
} else {
	private _receivingMoney = false;
	_id = [_civ getVariable ["playerid",0],life_wanted_list] call OEC_fnc_index;
	if(_id isEqualTo -1) exitWith {deleteVehicle _civ;};
	{
		if (((_x select 0) isEqualTo (_cop getVariable ["steam64id", getPlayerUID _cop])) && ((_x select 1) isEqualTo ((life_wanted_list select _id) select 3))) exitWith {
			_receivingMoney = true;
		};
	} forEach serv_bonesBounty;
	if (_receivingMoney) exitWith {};
	serv_bonesBounty pushback [(_cop getVariable ["steam64id", getPlayerUID _cop]), ((life_wanted_list select _id) select 3)];
	if (isNull _civ) exitWith {};
	[((life_wanted_list select _id) select 3),((life_wanted_list select _id) select 3),_civ] remoteExec ["OEC_fnc_bountyReceive",_cop,false];
	deleteVehicle _civ;
	serv_bonesBounty = serv_bonesBounty - [[_cop getVariable ["steam64id", getPlayerUID _cop],((life_wanted_list select _id) select 3)]];
};
