//Grabs the voter data and poops out stats
//[] spawn OES_fnc_voterStats;

private["_votes","_query","_count","_candidateStats"];
_count = (["SELECT COUNT(*) FROM votes",2] call OES_fnc_asyncCall) select 0;

_candidateVariableNames = [];

for [{_x=0},{_x<=_count},{_x=_x+10}] do {
	_query = format["SELECT votes.voteID, votes.voterID, votes.candidateID FROM votes LIMIT %1,10",_x];
	_votes = [_query,2,true] call OES_fnc_asyncCall;

	diag_log ("DATALOG" + format["%1",_votes]);

	if(count _votes == 0) exitWith {};



	{
		_voterID = call compile str(_x select 1);
		_candidateID = call compile str(_x select 2);

		if(_candidateVariableNames find format["candidate_%1",_candidateID] == -1)then{
			_candidateVariableNames pushBackUnique format["candidate_%1",_candidateID];
			missionNamespace setVariable [(format["candidate_%1",_candidateID]),[0,0,0]];//Total votes, total playtime of all voters comined (use to get avg), voters with less than 10 hours, free slot, free slot
		};

		//Grab playtime
		_playTimeQuery = format["SELECT player_stats FROM players WHERE playerid='%1'",_voterID];
		_playTime = [_playTimeQuery,2] call OES_fnc_asyncCall;

		diag_log ("TIMELOG" + str(_playTime));

		if(count _playTime > 0) then {
			_new = [(_playTime select 0)] call OES_fnc_mresToArray;
			if(_new isEqualType "") then {_new = call compile format["%1", _new];};

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