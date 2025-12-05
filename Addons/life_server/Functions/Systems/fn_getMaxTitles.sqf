//	File: fn_getMaxTitles.sqf
//	Author: Kurt

//	Description:
//	Get the PIDs of players with max of a certain stat.

//Make the query
private _query = ["CALL selectMax",2,true] call OES_fnc_asyncCall;
private _queryResult = call compile format ["%1",_query];

//Assemble a new array
private _pidList = [];
{
	_pidList pushBack (_x select 0);
} forEach _queryResult;

oev_title_pid = _pidList;
// 0 - PID of most warpoints, 1 - PID of highest bank balance, 2 - PID of most cop kills, 3 - PID of most vigilante arrests, 4 - PID of the fastest time at the gokart pit
publicVariable "oev_title_pid";
