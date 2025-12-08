//	File: fn_getVehicles.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Sends a request to query the database information and returns vehicles.
//  Modified: 迁移到 PostgreSQL Mapper 层

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

_tickTime = diag_tickTime;

// 使用 vehicleMapper 获取车辆列表
if (_gangVehicle) then {
	_queryResult = ["getganglist", [str _gangID, _type]] call DB_fnc_vehicleMapper;
} else {
	_queryResult = ["getlist", [_pid, _side, _type]] call DB_fnc_vehicleMapper;
};

// 确保 _queryResult 是数组
if (isNil "_queryResult") then { _queryResult = []; };
if (!(_queryResult isEqualType [])) then { _queryResult = []; };

// 检查是否为单行结果（扁平数组）并转换为二维数组
// 单行结果: ["2","civ","C_SUV_01_F",...] - 第一个元素是字符串
// 多行结果: [["2","civ","C_SUV_01_F",...], [...]] - 第一个元素是数组
if (count _queryResult > 0 && {!((_queryResult select 0) isEqualType [])}) then {
	_queryResult = [_queryResult];
};

{
	// color & material array [color,material] - 现在从 JSONB 返回 SQF 格式字符串
	_x set [8, [_x select 8, ["", 0]] call DB_fnc_parseJsonb];

	// modification array - 现在从 JSONB 返回 SQF 格式字符串
	_x set [10, [_x select 10, [0,0,0,0,0,0,0,0]] call DB_fnc_parseJsonb];
} forEach _queryResult;


"-------------- Get Garage Vehicles -------------" call OES_fnc_diagLog;
format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)] call OES_fnc_diagLog;
format["Garage Query Result: %1",_queryResult] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

if(_queryResult isEqualType "") exitWith {
	[[]] remoteExec ["OEC_fnc_impoundMenu",(owner _unit),false];
};

[_queryResult,_gangVehicle] remoteExec ["OEC_fnc_impoundMenu",(owner _unit),false];
