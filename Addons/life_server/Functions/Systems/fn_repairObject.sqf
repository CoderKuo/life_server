//	Description: Repairs an object after x amount of seconds, waits for ppl to be greater than x meters from object
//	Used primarily for gathering shit

private["_time","_object","_distance"];
_object = param [0,ObjNull,[ObjNull]];
_time = param [1,30,[0]];
_distance = 5;
_unbreakableModels = ["cliff_surfacemine_f.p3d"];

if(isNull _object) exitWith {};
if(((getModelInfo _object) select 0) in _unbreakableModels) then {
	_object hideObjectGlobal true;
}else{
	lifeServer_repairObjects pushBack _object;
	_object setDamage 1;
	sleep 1.5;
	_object hideObjectGlobal true;
};

sleep (_time + random(15));
if(isNull _object) exitWith {};

waitUntil{sleep 3; ((_object nearEntities ["Man", _distance]) isEqualTo [])};

if(((getModelInfo _object) select 0) in _unbreakableModels) then {
	_object hideObjectGlobal false;
}else{
	lifeServer_repairObjects = lifeServer_repairObjects - [_object];
	_object setDamage 0;
	_object hideObjectGlobal false;
};