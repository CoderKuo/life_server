//	Author: Poseidon
//	Description: Checks all vehicles on map, and saves those which have an owner nearby to the database so they can be spawned next restart
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_queryResult","_count","_pos","_house"];
_tickTime = diag_tickTime;

// 使用 houseMapper 获取房屋数量
_count = (["count", [str olympus_server]] call DB_fnc_houseMapper) select 0;

for [{_x=0},{_x<=_count},{_x=_x+10}] do {
	// 使用 houseMapper 获取房屋列表
	_queryResult = ["getall", [_x, str olympus_server]] call DB_fnc_houseMapper;
	if(count _queryResult == 0) exitWith {};

	{
		_pos = call compile format["%1",_x select 2];
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
