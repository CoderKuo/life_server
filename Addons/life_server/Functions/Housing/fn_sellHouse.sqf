//	Author: Bryan "Tonic" Boardwine
//	Description: Used in selling the house, sets the owned to 0 and will cleanup with a stored procedure on restart.
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_house","_houseID","_ownerID","_housePos","_radius","_containers","_player","_pid"];
_house = param [0,ObjNull,[ObjNull]];
_player = param [1,ObjNull,[ObjNull]];
if(isNull _player) exitWith {};
if(isNull _house) exitWith {systemChat ":SERVER:sellHouse: House is null"; [[1,"No ones in the market to buy your house, try again later. (error occurred)"],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP; [["oev_houseTransaction",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP; [["oev_action_inUse",false],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;};

_pid = getPlayerUID _player;

uiSleep round(random(5));
uiSleep round(random(5));

_houseID = _house getVariable["house_id",-1];
_ownerID = (_house getVariable "house_owner") select 0;

if(_houseID == -1) then {
	_housePos = getPosATL _house;
	// 获取房屋ID
	_queryResult = ["exists", [str _housePos, str olympus_server]] call DB_fnc_houseMapper;
	_houseID = (_queryResult select 0);
};

// 出售房屋
["sell", [str _houseID, _pid, str olympus_server]] call DB_fnc_houseMapper;

_house setVariable["house_sold",nil,true];
_house setVariable["house_id",nil,true];
_house setVariable["house_owner",nil,true];
_house setVariable["keyPlayers",nil,true];
_house setVariable["for_sale",nil,true];

_radius = (((boundingBoxReal _house select 0) select 2) - ((boundingBoxReal _house select 1) select 2));

if(isNull _player) exitWith {};
[[_house,2, _pid],"OEC_fnc_houseOwnership",(owner _player),false] spawn OEC_fnc_MP;
