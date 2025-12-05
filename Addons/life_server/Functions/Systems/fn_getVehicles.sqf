//	File: fn_getVehicles.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Sends a request to query the database information and returns vehicles.

private["_ret","_tickTime","_queryResult"];
params [
	["_pid","",[""]],
	["_side",sideUnknown,[west]],
	["_type","",[""]],
	["_unit",ObjNull,[ObjNull]],
	["_gangVehicle",false,[false]],
	["_gangID",-2,[0]]
];


private _check = (_pid find "'" != -1);
if (_check) exitWith {};
private _check = (_type find "'" != -1);
if (_check) exitWith {};

//Error checks
if((_pid isEqualTo "") || {_side isEqualTo sideUnknown} || {_type isEqualTo ""} || {isNull _unit}) exitWith {
	if(!isNull _unit) then {
		[[]] remoteExec ["OEC_fnc_impoundMenu",(owner _unit),false];
	};
};

_side = switch(_side) do {
	case west:{"cop"};
	case civilian: {"civ"};
	case independent: {"med"};
	default {"Error"};
};

if(_side isEqualTo "Error") exitWith {
	[[]] remoteExec ["OEC_fnc_impoundMenu",(owner _unit),false];
};

private _query = format["SELECT CONVERT(id, char), side, classname, type, pid, alive, active, plate, color, insured, modifications, customName FROM %4 WHERE pid='%1' AND alive='1' AND active='0' AND side='%2' AND type='%3' ORDER BY classname DESC",_pid,_side,_type,dbColumVehicle];

if (_gangVehicle) then {
	_query = format["SELECT CONVERT(id, char), side, classname, type, gang_id, alive, active, plate, color, insured, modifications FROM %3 WHERE gang_id='%1' AND alive='1' AND active='0' AND type='%2' ORDER BY classname DESC",_gangID,_type,dbColumGangVehicle];
};
_tickTime = diag_tickTime;
_queryResult = [_query,2,true] call OES_fnc_asyncCall;
{
	//color & material array [color,material]
	_new = (_x select 8) splitString "[,]";
	_new = [_new select 0, call compile (_new select 1)];

//	_new = [(_x select 8)] call OES_fnc_mresToArray;
	if(_new isEqualType "") then {_new = call compile format["%1", _new];};
	_x set[8,_new];

	//modification array, will contain values for each modification like armor, turbo, etc, max mods currently is 8
	_new = [(_x select 10)] call OES_fnc_mresToArray;
	if(_new isEqualType "") then {_new = call compile format["%1", _new];};
	_x set[10,_new];
} forEach _queryResult;


"-------------- Get Garage Vehicles -------------" call OES_fnc_diagLog;
format["QUERY: %1",_query] call OES_fnc_diagLog;
format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)] call OES_fnc_diagLog;
format["Garage Query Result: %1",_queryResult] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

if(_queryResult isEqualType "") exitWith {
	[[]] remoteExec ["OEC_fnc_impoundMenu",(owner _unit),false];
};

[_queryResult,_gangVehicle] remoteExec ["OEC_fnc_impoundMenu",(owner _unit),false];
