//	Author: TheCmdrRex
//	File: fn_houseForSale.sqf
//	Description: Handles server side of listing houses after client part of listing house

private["_house","_uid","_housePos","_query","_player","_houseID","_queryResult"];
params [
	["_player",objNull,[objNull]],
	["_house",objNull,[objNull]],
	["_mode",-1,[0]]
];

if (isNull _house || isNull _player) exitWith {};

_uid = getPlayerUID _player;
_houseID = _house getVariable ["house_id",-1];
_housePos = getPosATL _house;
//random uiSleep times to prevent players from buying and listing at same time.

uiSleep round(random(4));
uiSleep round(random(4));
uiSleep round(random(4));

_query = format["SELECT pid FROM houses WHERE pos='%1' AND owned='1' AND server='%2'",_housePos,olympus_server];
_queryResult = [_query,2] call OES_fnc_asyncCall;
if ((_queryResult select 0) != _uid) exitWith {
	[1,"How did you get here? You cannot list/unlist someone else's house!"] remoteExecCall ["OEC_fnc_broadcast",(owner _player)];
};

switch (_mode) do {
	// Mode 0 - List house
	case 0: {
		_query = format ["UPDATE houses SET inAH='%3' WHERE id='%1' AND pid='%2' AND server='%4'",_houseID,_uid,((_house getVariable ["for_sale",""]) select 1),olympus_server];
		_queryResult = [_query,1] call OES_fnc_asyncCall;
		[3,"You successfully listed your house for sale!<br/><br/>Players can purchase it from the realtor."] remoteExecCall ["OEC_fnc_broadcast",(owner _player)];
	};

	// Mode 1 = Unlist house
	case 1: {
		_query = format ["UPDATE houses SET inAH='0' WHERE id='%1' AND pid='%2' AND server='%3'",_houseID,_uid,olympus_server];
		_queryResult = [_query,1] call OES_fnc_asyncCall;
		[1,"You have taken your house off of the market"] remoteExecCall ["OEC_fnc_broadcast",(owner _player)];

	};
};
