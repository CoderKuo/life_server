// File: updateHouseDeed.sqf
// Author: Tech
// Desciption: Updates the timestamp on houses by updating the expires_on sql column.
params [
  ["_houseID",-1,[0]],
  ["_daysToAdd",-1,[0]]
];
if(_houseID isEqualTo -1 || _daysToAdd isEqualTo -1) exitWith {};

//private _query = format["UPDATE houses SET last_active = NOW() WHERE id='%1' AND server='%2'",_houseID,olympus_server];
private _query = format["UPDATE houses SET expires_on = DATE_ADD(expires_on, INTERVAL %1 DAY) WHERE id='%2' AND SERVER='%3'",_daysToAdd,_houseID,olympus_server];
[_query,1] call OES_fnc_asyncCall;
