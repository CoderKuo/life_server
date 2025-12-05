//#include "\ZBKServer\script_macros.hpp"
 
 
 
 
 
 
 
private["_unit","_target","_terminate","_users"]; 
_unit = [_this,0,objNull,[objNull]] call BIS_fnc_param; 
_target = [_this,1,objNull,[objNull]] call BIS_fnc_param; 
_terminate = [_this,2,false,[false]] call BIS_fnc_param; 
_cleanupOnly = [_this,3,false,[false]] call BIS_fnc_param; 
 
if (!_cleanupOnly) then 
{ 
 
if (_terminate) then 
{ 
{ 
if (_unit in (_x select 1)) then 
{ 
waitUntil {!isNull _unit};
waitUntil {isPlayer _unit};
_users = _x select 1; 
_users = _users - [_unit]; 
(_x select 0) radioChannelRemove [_unit]; 
oev_phone_channel = -1; 
owner _unit publicVariableClient "oev_phone_channel"; 
oev_phone_status = 0; owner _unit publicVariableClient "oev_phone_status"; 
mc_phone_groups set [_forEachIndex, [(_x select 0), _users]]; 
}; 
} forEach mc_phone_groups; 
} 
 
 
else 
{ 
if (isNull _target) exitWith {}; 
if (isNull _unit) exitWith{};
if (!isPlayer _target) exitWith {}; 
if (!isPlayer _unit) exitWith{};
oev_phone_status = 3; 
owner _unit publicVariableClient "oev_phone_status"; 
_index = -1; 
_available = -1; 
{ 
if (_unit in (_x select 1)) exitWith { _index = _forEachIndex }; 
if (_index < 0 && count (_x select 1) == 0) then { _available = _forEachIndex }; 
} forEach mc_phone_groups; 
if (_index < 0 && _available < 0) exitWith { _msg = "电话线路已满,无法为您创建新的频道!"; [2,_msg] remoteExec ["OEC_fnc_broadcast",_unit];[2,_msg] remoteExec ["OEC_fnc_broadcast",_target];}; 
if (_index < 0) then { _index = _available; }; 
_units = (mc_phone_groups select _index) select 1; 
oev_phone_channel = (mc_phone_groups select _index) select 0; 
if (!(_unit in _units)) then { _units pushBack _unit; (owner _unit) publicVariableClient "oev_phone_channel"; }; 
if (!(_target in _units)) then { _units pushBack _target; (owner _target) publicVariableClient "oev_phone_channel"; }; 
mc_phone_groups set [_index, [(mc_phone_groups select _index) select 0, _units]]; 
((mc_phone_groups select _index) select 0) radioChannelAdd [_unit]; 
((mc_phone_groups select _index) select 0) radioChannelAdd [_target]; 
}; 
}; 
 
 
{ 
_count = 0; 
{ if (!isNull _x) then { _count = _count + 1; } } forEach (_x select 1); 
if (_count < 2) then 
{ 
_chan = _x select 0; 
{ 
_chan radioChannelRemove [_x]; 
if ((!isNull _x)&&(isPlayer _x)) then
{
	oev_phone_status = 0;
	owner _x publicVariableClient "oev_phone_status"; 
	oev_phone_channel = -1; 
	owner _x publicVariableClient "oev_phone_channel"; 
};
} forEach (_x select 1); 
mc_phone_groups set [_forEachIndex, [(_x select 0), []]]; 
}; 
} forEach mc_phone_groups;