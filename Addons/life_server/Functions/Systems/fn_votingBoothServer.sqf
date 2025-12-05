//	File: fn_vote.sqf
//	Author: Ozadu
//	Description: Handles adding votes to the DB. Caches votes so DB isnt spammed.
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

		private _query = format["SELECT voterID, candidateID FROM votes WHERE voterID='%1'",_pid];
		private _queryResult = [_query,2,true] call OES_fnc_asyncCall;

		if (count _queryResult >= 2) exitWith {}; //already had 2 votes
		if (count (_queryResult select {_x select 2 == _candidateId}) > 0) exitWith {}; //already voted for that person

		/*If we got to this point it's a valid vote. Insert.*/
		_query = format["INSERT into votes (voterID,candidateID) VALUES ('%1','%2')",_pid,_candidateId];
		[_query,1] call OES_fnc_asyncCall;
		life_votes pushBack [_pid,_candidateId];
	};

	case "data": {
		private _votes = [];
		{
			if ((_x select 0) isEqualTo _pid) then {_votes pushBack [_pid,(_x select 1)]};
		} forEach life_votes;

		if (count _votes > 0) exitWith {[["data",_votes],"OEC_fnc_votingBooth",_player] call OEC_fnc_MP};

		private _query = format["SELECT voterID, candidateID FROM votes WHERE voterID='%1'",_pid];
		private _queryResult = [_query,2,true] call OES_fnc_asyncCall;

		{
			if (!(_x in life_votes)) then {
				life_votes pushBack _x;
			};
		} forEach _queryResult;

		[["data",_queryResult],"OEC_fnc_votingBooth",_player] call OEC_fnc_MP;
	};
};