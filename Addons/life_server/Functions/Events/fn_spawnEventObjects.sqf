//  File: fn_spawnEventObjects
//	Description: Spawns the specified vehicle type, or group of vehicles, or crates, at the requested location.

private["_player","_eventType","_eventLocation","_objectsData","_object","_baseObject"];
_player = param [0,ObjNull,[ObjNull]];
_eventType = param [1,"",[""]];
_eventLocation = param [2,"",[""]];

if(isNull _player || _eventType == "" || _eventLocation == "") exitWith {};
_objectsData = [_eventLocation] call OES_fnc_getEventObjects;
if(count _objectsData == 0) exitWith {};

{
	_object = createVehicle [_x select 0, _x select 1, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _object};
	life_server_eventObjects pushBack _object;
	_object enableSimulation false;
	_object allowDamage false;
	_object setDir (_x select 2);
	_object setVectorUp (_x select 3);
	sleep 0.05;
	if(typeof _x == "VR_Billboard_01_F") then {_baseObject = _x};
}foreach (_objectsData select 1);

if(isNil "_baseObject") exitWith {};
if(isNull _baseObject) exitWith {};
_dir = getDir _baseObject;
_pos = getPosASL _baseObject;
_height = (_objectsData select 0);
_gap = 14;

for "_i" from 3 to 45 do {
	_spawnPos = _baseObject ModelToWorld [0,(_i * 1.95),_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setVectorUp[0,0,1];
	_veh setDir (_dir + 90);
	sleep 0.05;
};

for "_i" from 1 to 45 do {
	_spawnPos = _baseObject ModelToWorld [-1.85,(_i * 1.95),_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setVectorUp[0,0,1];
	_veh setDir (_dir + 90);
	_veh setPosASL [((getPosASL _veh) select 0),((getPosASL _veh) select 1),((getPosASL _veh) select 2) + 3.45];
	_veh setVectorDirAndUp [((vectorDir _veh) vectorAdd [0,0,1.5]),((vectorUp _veh) vectorAdd [0,0,0])];
	sleep 0.05;
};

for "_i" from 3 to 45 do {
	_spawnPos = _baseObject ModelToWorld [0 - _gap,(_i * 1.95),_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setVectorUp[0,0,1];
	_veh setDir (_dir - 90);
	sleep 0.05;
};

for "_i" from 1 to 45 do {
	_spawnPos = _baseObject ModelToWorld [1.85 - _gap,(_i * 1.95),_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setVectorUp[0,0,1];
	_veh setDir (_dir - 90);
	_veh setPosASL [((getPosASL _veh) select 0),((getPosASL _veh) select 1),((getPosASL _veh) select 2) + 3.45];
	_veh setVectorDirAndUp [((vectorDir _veh) vectorAdd [0,0,1.5]),((vectorUp _veh) vectorAdd [0,0,0])];
	sleep 0.05;
};

for "_i" from -4 to (round(_gap/2) + 4) do {
	_spawnPos = _baseObject ModelToWorld [-(_i * 1.95),0.9,_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setDir _dir;
	_veh setVectorUp[0,0,1];
	sleep 0.05;
};

for "_i" from -4 to (round(_gap/2) + 4) do {
	_spawnPos = _baseObject ModelToWorld [-(_i * 1.95), 2.75,_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setDir _dir;
	_veh setVectorUp[0,0,1];
	_veh setPosASL [((getPosASL _veh) select 0),((getPosASL _veh) select 1),((getPosASL _veh) select 2) + 3.45];
	_veh setVectorDirAndUp [((vectorDir _veh) vectorAdd [0,0,-1.5]),((vectorUp _veh) vectorAdd [0,0,0])];
	sleep 0.05;
};


for "_i" from 1 to 6 do {
	_spawnPos = _baseObject ModelToWorld [8,(_i * 1.95),_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setVectorUp[0,0,1];
	_veh setDir (_dir + 90);
	sleep 0.05;
};

for "_i" from 1 to 6 do {
	_spawnPos = _baseObject ModelToWorld [-1.85 + 8,(_i * 1.95),_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setVectorUp[0,0,1];
	_veh setDir (_dir + 90);
	_veh setPosASL [((getPosASL _veh) select 0),((getPosASL _veh) select 1),((getPosASL _veh) select 2) + 3.45];
	_veh setVectorDirAndUp [((vectorDir _veh) vectorAdd [0,0,1.5]),((vectorUp _veh) vectorAdd [0,0,0])];
	sleep 0.05;
};

for "_i" from 1 to 6 do {
	_spawnPos = _baseObject ModelToWorld [0 - (_gap + 8),(_i * 1.95),_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setVectorUp[0,0,1];
	_veh setDir (_dir - 90);
	sleep 0.05;
};

for "_i" from 1 to 6 do {
	_spawnPos = _baseObject ModelToWorld [1.85 - (_gap + 8),(_i * 1.95),_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setVectorUp[0,0,1];
	_veh setDir (_dir - 90);
	_veh setPosASL [((getPosASL _veh) select 0),((getPosASL _veh) select 1),((getPosASL _veh) select 2) + 3.45];
	_veh setVectorDirAndUp [((vectorDir _veh) vectorAdd [0,0,1.5]),((vectorUp _veh) vectorAdd [0,0,0])];
	sleep 0.05;
};

for "_i" from 0 to 3 do {
	_spawnPos = _baseObject ModelToWorld [1 + (_i * 1.95), 12.9,_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setDir _dir;
	_veh setVectorUp[0,0,1];
	sleep 0.05;
};

for "_i" from 0 to 3 do {
	_spawnPos = _baseObject ModelToWorld [1 + (_i * 1.95), 11.05,_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setDir _dir;
	_veh setVectorUp[0,0,1];
	_veh setPosASL [((getPosASL _veh) select 0),((getPosASL _veh) select 1),((getPosASL _veh) select 2) + 3.45];
	_veh setVectorDirAndUp [((vectorDir _veh) vectorAdd [0,0,1.5]),((vectorUp _veh) vectorAdd [0,0,0])];
	sleep 0.05;
};

for "_i" from 0 to 3 do {
	_spawnPos = _baseObject ModelToWorld [-1 - (_gap) + (_i * -1.95), 12.9,_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setDir _dir;
	_veh setVectorUp[0,0,1];
	sleep 0.05;
};

for "_i" from 0 to 3 do {
	_spawnPos = _baseObject ModelToWorld [-1 - (_gap) + (_i * -1.95), 11.05,_height];
	_veh = createVehicle ["VR_Billboard_01_F", _spawnPos, [], 0, "CAN_COLLIDE"];
	waitUntil{!isNull _veh};
	life_server_eventObjects pushBack _veh;
	_veh enableSimulation false;
	_veh allowDamage false;
	_veh setDir _dir;
	_veh setVectorUp[0,0,1];
	_veh setPosASL [((getPosASL _veh) select 0),((getPosASL _veh) select 1),((getPosASL _veh) select 2) + 3.45];
	_veh setVectorDirAndUp [((vectorDir _veh) vectorAdd [0,0,1.5]),((vectorUp _veh) vectorAdd [0,0,0])];
	sleep 0.05;
};

for "_i" from 1 to 6 do {
	_spawnPos = _baseObject ModelToWorld [-(_gap/2),(14 * _i),5];
	_light = "#lightpoint" createVehicle _spawnPos;
	waitUntil{!isNull _light};
	life_server_eventObjects pushBack _light;
	_light setLightBrightness 3;
	_light setLightAmbient[0, 0, 1.0];
	_light setLightColor[0, 0, 1.0];
};

_baseObject hideObject true;