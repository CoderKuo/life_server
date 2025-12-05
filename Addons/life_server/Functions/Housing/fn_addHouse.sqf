//	Author: Bryan "Tonic" Boardwine
//	File: fn_addHouse.sqf
//	Description: Handles second part of house buying after purchase approved

private["_house","_uid","_housePos","_query","_player","_houseID"];
_player = param [0,ObjNull,[ObjNull]];
_house = param [1,ObjNull,[ObjNull]];
_price = param [2,-1,[0]];
if(isNull _house || isNull _player) exitWith {};

//random uiSleep times to prevent 2 players from buying same house if they click buy at same time

_uid = getPlayerUID _player;
_housePos = getPosATL _house;
_houseID = _house getVariable ["house_id",-1];

uiSleep round(random(4));
uiSleep round(random(4));
uiSleep round(random(4));

_query = format["SELECT id FROM houses WHERE pos='%1' AND owned='1' AND server='%2'",_housePos,olympus_server];

_queryResult = [_query,2] call OES_fnc_asyncCall;
//Check to see if someone currently owns a house at this position

if(isNull _player) exitWith {};
if(count _queryResult != 0 && ((_house getVariable ["for_sale",""]) isEqualTo "")) exitWith {
	[[1,"Purchase request denied. Someone already owns this house."],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
	[[_house,3, _uid],"OEC_fnc_houseOwnership",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};
if (_price == -1 && !((_house getVariable ["for_sale",""]) isEqualTo "")) exitWith {
	[[1,"Purchase request denied. Price was invalid."],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};
if !((_house getVariable ["for_sale",""]) isEqualTo "") then {
	_query = format["SELECT inAH FROM houses WHERE id='%1' AND owned='1' AND server='%2'",_queryResult,olympus_server];
	_queryResult = [_query,2] call OES_fnc_asyncCall;
};
if (!((_house getVariable ["for_sale",""]) isEqualTo "") && {_price != (_queryResult select 0)}) exitWith {
	[[1,"Purchase request denied. Price did not match with DB. Please contact a Staff Member"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
	[[_house,5, _uid,_price],"OEC_fnc_houseOwnership",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
	[["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};


if !((_house getVariable ["for_sale",""]) isEqualTo "") then {
	if (_houseID == -1) then {
		_query = format["SELECT id FROM houses WHERE pos='%1' AND owned='1' AND pid='%2' AND server='%3'",_housePos,((_house getVariable ["for_sale",""]) select 0),olympus_server];
		_queryResult = [_query,2] call OES_fnc_asyncCall;
		_houseID = (_queryResult select 0);
	};
	_playerKeys = [];
	_playerKeys = [_playerKeys] call OES_fnc_mresArray;
	_query = format ["UPDATE houses SET pid='%2', player_keys='%4', inAH='0' WHERE id='%1' AND pid='%3' AND server='%5'",_houseID,_uid,((_house getVariable ["for_sale",""]) select 0),_playerKeys,olympus_server];
	private _query2 = format ["UPDATE players SET realtor_cash = realtor_cash + '%1' WHERE playerid='%2'",_price,((_house getVariable ["for_sale",""]) select 0)];
	private _query2Result = [_query2,1] call OES_fnc_asyncCall;
} else {
	_query = format["INSERT INTO houses (pid, pos, inventory, owned, physical_inventory, server, expires_on) VALUES('%1', '%2', '""[[],0]""', '1', '""[[],0]""', '%3', DATE_ADD(TIMESTAMP(CURRENT_DATE()), INTERVAL 45 DAY))",_uid,_housePos, olympus_server];
};
_queryResult = [_query,1] call OES_fnc_asyncCall;
uiSleep 4;
_query = format["SELECT id FROM houses WHERE pos='%1' AND pid='%2' AND owned='1' AND server='%3'",_housePos,_uid,olympus_server];
_queryResult = [_query,2] call OES_fnc_asyncCall;
_house setVariable["house_id",(_queryResult select 0),true];
_house setVariable["keyPlayers",[],true];
_house setVariable["house_expire",45,true];

if(isNull _player) exitWith {};
if !((_house getVariable ["for_sale",""]) isEqualTo "") then {
	[[_house,4,_uid,_price],"OEC_fnc_houseOwnership",(owner _player),false] spawn OEC_fnc_MP;
} else {
	[[_house,1,_uid],"OEC_fnc_houseOwnership",(owner _player),false] spawn OEC_fnc_MP;
};
