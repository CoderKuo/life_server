//	Description: Called when someone action keys the skeleton object dropped from combat loggers, the combat logger is then sent to jail on next connection
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_pid","_query","_queryResult","_id","_newCoordinates","_wantedStats","_arrested","_restrainStatus","_tazeStatus"];
params [
	["_object",objNull,[objNull]],
	["_sender",objNull,[objNull]]
];
if(isNull _object) exitWith {};
_pid = _object getVariable "playerid";
if(isNil "_pid") exitWith {};

//Distributes money to the appropriate party.
//Get the unit restrain and taze status
_restrainStatus = _object getVariable ["restrainedBy",[objNull,0]];
_tazeStatus = _object getVariable ["tazedBy",[objNull,0]];
//Check if the unit was restrained
if !(isNull (_restrainStatus select 0)) then {
	[_object,_restrainStatus select 0,false,true] call OES_fnc_wantedBounty;
} else {
	//Check if the unit was tazed
	if !(isNull (_tazeStatus select 0)) then {
		[_object,_tazeStatus select 0,false,true] call OES_fnc_wantedBounty;
	};
};
if (isNull (_restrainStatus select 0) && isNull (_tazeStatus select 0) && ((_restrainStatus select 1) isEqualTo 0) && ((_tazeStatus select 1) isEqualTo 0)) then {
	deleteVehicle _object;
};

// 使用 playerMapper 获取监狱数据
_queryResult = ["getjaildata", [_pid]] call DB_fnc_playerMapper;
if(count _queryResult < 3) exitWith {};

_id = (_queryResult select 0);

// 解析 arrested 数据 - 从 JSONB 返回 SQF 格式字符串
_arrested = [_queryResult select 1, [0, 0, 0]] call DB_fnc_parseJsonb;

// 解析 wanted 数据 - 从 JSONB 返回 SQF 格式字符串
_wantedStats = [_queryResult select 2, []] call DB_fnc_parseJsonb;

_newCoordinates = [20893.3,19227.5,2];

if((_arrested select 0) != 0) exitWith {};

//If the player is a vigi and the target had over a 75k bounty give them an arrest
if (!(isNull (_restrainStatus select 0)) && (_restrainStatus select 1) IsEqualTo 1 && (_wantedStats select 0) >= 75000) then {
	[[1,(_restrainStatus select 0)],"OES_fnc_vigiGetSetArrests",false,false] spawn OEC_fnc_MP;
} else {
	if (!(isNull (_tazeStatus select 0)) && (_tazeStatus select 1) IsEqualTo 1 && (_wantedStats select 0) >= 75000) then {
		[[1,(_tazeStatus select 0)],"OES_fnc_vigiGetSetArrests",false,false] spawn OEC_fnc_MP;
	};
};

if(count _wantedStats > 0) then {
	if(_wantedStats select 0 < 1333333) then {
		if(_arrested select 2 > 0) then {
			_arrested = [1, ((_arrested select 1) + ((_wantedStats select 0) * 0.0048)), ((_arrested select 2) + _wantedStats select 0)];
		} else {
			_arrested = [1, (_wantedStats select 0) * 0.0048, (_wantedStats select 0)];
		};
	} else {
		_arrested = [1, (1333333) * 0.0048, 1333333];
	};
} else {
	_arrested = [1, (1333333) * 0.0048, 1333333];
};
_wantedStats = [[]] call OES_fnc_escapeArray;
_arrested = [_arrested] call OES_fnc_escapeArray;
_newCoordinates = [_newCoordinates] call OES_fnc_escapeArray;

// 使用 playerMapper 更新监狱数据
["updatejaildata", [_arrested, _wantedStats, _newCoordinates, _pid, _id]] call DB_fnc_playerMapper;
