//	Author: Bryan "Tonic" Boardwine
//	Description: Used in selling the house, sets the owned to 0 and will cleanup with a stored procedure on restart.

private["_house","_houseID","_ownerID","_housePos","_query","_radius","_containers","_player","_pid"];
_house = param [0,ObjNull,[ObjNull]];
_player = param [1,ObjNull,[ObjNull]];
if(isNull _player) exitWith {};
if(isNull _house) exitWith {systemChat ":SERVER:sellHouse: House is null"; [[1,"No ones in the market to buy your house, try again later. (error occurred)"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP; [["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP; [["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;};

_pid = getPlayerUID _player;

//random uiSleep times to prevent stuff

_houseID = _house getVariable["house_id",-1];
_ownerID = (_house getVariable "house_owner") select 0;

uiSleep round(random(5));
uiSleep round(random(5));

if(_houseID == -1) then {
	_housePos = getPosATL _house;

	_query = format["SELECT id FROM houses WHERE pos='%1' AND owned='1' AND pid='%2' AND server='%3'",_housePos,_pid,olympus_server];
	_queryResult = [_query,2] call OES_fnc_asyncCall;

	_houseID = (_queryResult select 0);
};

_query = format["UPDATE houses SET owned='0', pos='[]' WHERE id='%1' AND pid='%2' AND server='%3'",_houseID,_pid,olympus_server];

_house setVariable["house_sold",nil,true];
_house setVariable["house_id",nil,true];
_house setVariable["house_owner",nil,true];
_house setVariable["keyPlayers",nil,true];
_house setVariable["for_sale",nil,true];

_radius = (((boundingBoxReal _house select 0) select 2) - ((boundingBoxReal _house select 1) select 2));

[_query,1] call OES_fnc_asyncCall;

if(isNull _player) exitWith {};
[[_house,2, _pid],"OEC_fnc_houseOwnership",(owner _player),false] spawn OEC_fnc_MP;
