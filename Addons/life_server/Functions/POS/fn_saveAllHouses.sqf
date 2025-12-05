//	Author: Poseidon
//	Description: Checks all vehicles on map, and saves those which have an owner nearby to the database so they can be spawned next restart

private["_queryResult","_query","_count","_pos","_house"];
_tickTime = diag_tickTime;

_count = ([format["SELECT COUNT(*) FROM houses WHERE owned='1' AND server='%1'",olympus_server],2] call OES_fnc_asyncCall) select 0;

for [{_x=0},{_x<=_count},{_x=_x+10}] do {
	_query = format["SELECT houses.id, houses.pos FROM houses WHERE houses.owned='1' AND server='%2' LIMIT %1,10",_x, olympus_server];
	_queryResult = [_query,2,true] call OES_fnc_asyncCall;
	if(count _queryResult == 0) exitWith {};

	{
		_pos = call compile format["%1",_x select 1];
		_house = _pos nearestObject "House_F";

		if(!isNull _house) then {
			_house setVariable["house_id",_x select 0];
			_house setVariable["trunkLocked",true,true];
			[_house, true] call OES_fnc_updateHouseTrunk;
		};
	} foreach _queryResult;
};

"------------- Mass House Sync -------------" call OES_fnc_diagLog;
format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)] call OES_fnc_diagLog;
format["Total houses saved: %1", _count] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

//diag_log "------------- Mass House Sync -------------";
//diag_log format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)];
//diag_log format["Total houses saved: %1", _count];
//diag_log "------------------------------------------------";
