//	File: fn_medicPlaceablesServer.sqf
//	Author: Ozadu
//	Description: Ask server politely, can I plz haz object

params[
	["_unit",objNull,[objNull]],
	["_type","",[""]],
	["_pos",[],[]],
	["_dir",0,[0]]
];
_objectTypes = ["PlasticBarrier_03_orange_F","RoadBarrier_small_F","RoadCone_F","PortableHelipadLight_01_yellow_F"];
if(isNull _unit) exitWith {};
if(side _unit isEqualTo civilian) exitWith {};
if(!(_type in _objectTypes)) exitWith {};
if(isNil "life_server_medicPlaceables") then {life_server_medicPlaceables = []};

_obj = _type createVehicle [0,0,1000];
_obj setPosATL [_pos select 0,_pos select 1,0];
_obj setDir _dir;
_obj setVariable ["medicPlaced",true,true];
_obj setVariable ["placedTime",serverTime,true];
_obj setVariable ["placedBy",getPlayerUID _unit,true];

if(_type == "RoadBarrier_small_F") then {
	uiSleep 1;
	_obj setMass (getMass _obj)*10;
};

life_server_medicPlaceables pushBack _obj;