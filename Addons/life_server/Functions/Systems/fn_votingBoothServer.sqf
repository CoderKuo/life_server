//	File: fn_vote.sqf
//	Author: Ozadu
//	Description: Handles adding votes to the DB. Caches votes so DB isnt spammed.
//  Modified: 迁移到 PostgreSQL Mapper 层
params [
	["_player",objNull,[objNull]],
	["_mode","",[""]],
	["_candidateId","",[""]]
];

if (isNull _player) exitWith {};
if (_mode isEqualTo "") exitWith {};
if (isNil "life_votes") then {life_votes = []};
private _pid = getPlayerUID _player;
if (_pid isEqualTo "") exitWith {};

switch (_mode) do {

	case "vote": {
		if (_candidateId isEqualTo "") exitWith{};

		private _votes = 0;
		private _candidates = [];
		private _count = 0;

		{
			if ((_x select 0) isEqualTo _pid) then {_count = _count + 1; _candidates pushBack (_x select 1);};
			if (_count isEqualTo 2) exitWith {};
		} forEach life_votes;

		if (_count isEqualTo 2) exitWith {};
		if (_candidateId in _candidates) exitWith {};

		// 使用 miscMapper 获取投票
		private _queryResult = ["voteget", [_pid]] call DB_fnc_miscMapper;

		if (count _queryResult >= 2) exitWith {}; //already had 2 votes
		if (count (_queryResult select {_x select 2 == _candidateId}) > 0) exitWith {}; //already voted for that person

		/*If we got to this point it's a valid vote. Insert.*/
		// 使用 miscMapper 插入投票
		["voteinsert", [_pid, _candidateId]] call DB_fnc_miscMapper;
		life_votes pushBack [_pid,_candidateId];
	};

	case "data": {
		private _votes = [];
		{
			if ((_x select 0) isEqualTo _pid) then {_votes pushBack [_pid,(_x select 1)]};
		} forEach life_votes;

		if (count _votes > 0) exitWith {[["data",_votes],"OEC_fnc_votingBooth",_player] call OEC_fnc_MP};

		// 使用 miscMapper 获取投票
		private _queryResult = ["voteget", [_pid]] call DB_fnc_miscMapper;

		{
			if (!(_x in life_votes)) then {
				life_votes pushBack _x;
			};
		} forEach _queryResult;

		[["data",_queryResult],"OEC_fnc_votingBooth",_player] call OEC_fnc_MP;
	};
};
