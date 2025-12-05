// File: fn_checkVehicleLimit

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

_query = format["SELECT COUNT(id) FROM "+dbColumVehicle+" WHERE pid='%1' AND alive='1' AND side='%2'",_pid,_side];

_tickTime = diag_tickTime;
_queryResult = [_query,2,false] call OES_fnc_asyncCall;

if(isNull _unit) exitWith {};
[["oev_garageCount",(_queryResult select 0)],"OEC_fnc_netSetVar",(owner _unit),false] spawn OEC_fnc_MP;