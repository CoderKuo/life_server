//  File: fn_createItem.sqf
//	Author: Kurt

//	Description: Drops an item on the ground.

params [
	["_items",[],[[]]],
    ["_pos",[],[[]]],
    ["_class","",[""]]
];
private["_obj","_int"];
_obj = _class createVehicle [0,random(100),random(100)];
waitUntil {(!isNil "_obj") && (!isNull _obj)};
_obj allowDamage false;
_obj setPosATL _pos;
_obj setVariable["O_droppedItem",_items,true];
serv_yinv_cleanup pushBack [_obj,(serverTime + (900))];

_int = 0;
if ((typeOf _obj) == "Land_RotorCoversBag_01_F") then {
	waitUntil {
		uiSleep 4;
		_int = _int + 1;
		( (((getPos _obj) select 2) < 1) || _int > 4)
	};
	_obj enableSimulationGlobal false;
};
if ((typeOf _obj) isEqualTo "Land_Suitcase_F" || (typeOf _obj) == "Land_RotorCoversBag_01_F") then {
	_obj setVariable ["inUse",ObjNull,true];
};