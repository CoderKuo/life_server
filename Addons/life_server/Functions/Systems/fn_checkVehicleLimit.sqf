// File: fn_checkVehicleLimit
// Modified: 迁移到 PostgreSQL Mapper 层

private["_pid","_side","_type","_unit","_ret","_tickTime","_queryResult"];
_pid = param [0,"",[""]];
_side = param [1,sideUnknown,[west]];
_unit = param [2,ObjNull,[ObjNull]];

//Error checks
if(_pid == "" || _side == sideUnknown || isNull _unit) exitWith {};

private _check = (_pid find "'" != -1);
if (_check) exitWith {};

_side = switch(_side) do {
	case west:{"cop"};
	case civilian: {"civ"};
	case independent: {"med"};
	default {"Error"};
};

_tickTime = diag_tickTime;
// 使用 vehicleMapper 统计车辆数量
_queryResult = ["countbyplayer", [_pid, _side]] call DB_fnc_vehicleMapper;

// 确保 _queryResult 是有效数组
if (isNil "_queryResult") then { _queryResult = [0]; };
if (!(_queryResult isEqualType []) || {count _queryResult == 0}) then { _queryResult = [0]; };

if(isNull _unit) exitWith {};
[["oev_garageCount",(_queryResult select 0)],"OEC_fnc_netSetVar",(owner _unit),false] spawn OEC_fnc_MP;