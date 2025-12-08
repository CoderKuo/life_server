// File: fn_checkGangVehicleLimit
// Modified: 迁移到 PostgreSQL Mapper 层

params [["_unit",objNull,[objNull]]];

if (isNull _unit) exitWith {};
private _gangID = ((_unit getVariable ["gang_data",[0,"",0]]) select 0);

// 使用 vehicleMapper 统计帮派车辆数量
private _queryResult = ["countbygang", [str _gangID]] call DB_fnc_vehicleMapper;

if (isNull _unit) exitWith {};
["oev_garageCount",(_queryResult select 0)] remoteExecCall ["OEC_fnc_netSetVar",(owner _unit),false];