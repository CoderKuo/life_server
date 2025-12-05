// File: fn_checkGangVehicleLimit

params [["_unit",objNull,[objNull]]];

if (isNull _unit) exitWith {};
private _gangID = ((_unit getVariable ["gang_data",[0,"",0]]) select 0);

private _query = format["SELECT COUNT(id) FROM gangvehicles WHERE gang_id='%1' AND alive='1'",_gangID];
private _queryResult = [_query,2,false] call OES_fnc_asyncCall;

if (isNull _unit) exitWith {};
["oev_garageCount",(_queryResult select 0)] remoteExecCall ["OEC_fnc_netSetVar",(owner _unit),false];