//Grabs the voter data and poops out stats
//[] spawn OES_fnc_voterStats;
//Modified: 迁移到 PostgreSQL Mapper 层

private["_votes","_count","_candidateStats"];

// 使用 miscMapper 获取投票数量
_count = (["countvotes", []] call DB_fnc_miscMapper) select 0;

_candidateVariableNames = [];

for [{_x=0},{_x<=_count},{_x=_x+10}] do {
	// 使用 miscMapper 分页获取投票
	_votes = ["getvotes", [_x]] call DB_fnc_miscMapper;

	diag_log ("DATALOG" + format["%1",_votes]);

	if(count _votes == 0) exitWith {};

	{
		_voterID = call compile str(_x select 1);
		_candidateID = call compile str(_x select 2);

		if(_candidateVariableNames find format["candidate_%1",_candidateID] == -1)then{
			_candidateVariableNames pushBackUnique format["candidate_%1",_candidateID];
			missionNamespace setVariable [(format["candidate_%1",_candidateID]),[0,0,0]];//Total votes, total playtime of all voters comined (use to get avg), voters with less than 10 hours, free slot, free slot
		};

		// 使用 playerMapper 获取玩家统计
		_playTime = ["getstats", [str _voterID]] call DB_fnc_playerMapper;

		diag_log ("TIMELOG" + str(_playTime));

		if(count _playTime > 0) then {
			// 解析统计数据 - 从 JSONB 返回 SQF 格式字符串
			private _new = [_playTime select 0, [0,0,0,0,0,0,0,0]] call DB_fnc_parseJsonb;

			_playTime = _new select 7;

			_candidateStats = missionNamespace getVariable (format["candidate_%1",_candidateID]);

			if(_playTime < 600) then {
				_candidateStats = [(_candidateStats select 0) + 1, (_candidateStats select 1) + _playTime, (_candidateStats select 2) + 1];
			}else{
				_candidateStats = [(_candidateStats select 0) + 1, (_candidateStats select 1) + _playTime, _candidateStats select 2];
			};

			missionNamespace setVariable [(format["candidate_%1",_candidateID]),_candidateStats];
		};

	}forEach _votes;
};

{
	_candidateStats = missionNamespace getVariable _x;
	diag_log format["Candidate ID: %4, Total Votes: %1, Average hours player per voter: %2, Voters with less than 10 hours: %3", _candidateStats select 0, (((_candidateStats select 1) + 1) / ((_candidateStats select 0) + 1)), _candidateStats select 2, _x];
}foreach _candidateVariableNames;
