//  File: fn_updateMember
//	Author: Bryan "Tonic" Boardwine
//	Description: Updates the gang information?

private["_mode","_group","_groupID","_bank","_maxMembers","_members","_query","_owner","_ownerID","_gangID","_gangName","_playerID","_rank","_principal"];
_mode = param [0,0,[0]];
_gangID = param [2,-2,[0]];
_gangName = param [3,"",[""]];

if(_gangName isEqualTo "" || _gangID isEqualTo -2) exitWith {}; //Fail

private _check = (_gangName find "'" != -1);
if (_check) exitWith {};

switch (_mode) do {
	case 0: {
		//gang created or player invited
		_ownerID = param [1,ObjNull,[ObjNull]];
		_rank = param [4,0,[0]];
		_principal = param [5,"",[""]];
		if(_rank > 5) then {_rank = 5;};

		_query = format["SELECT id FROM gangmembers WHERE playerid='%1'",(getPlayerUID _ownerID)];
		_queryResult = [_query,2] call OES_fnc_asyncCall;

		[format['{"event":"Gang Invite", "player":"%1", "target":"%2", "value":"%3", "location":"%4"}',_principal,getPlayerUID _ownerID,'null','null']] call OES_fnc_logIt;

		if !(count _queryResult isEqualTo 0) then {
			_query = format["UPDATE gangmembers SET name='%1', gangname='%2', gangid='%3', rank='%4' WHERE id='%5'",_ownerID getVariable["realname",name _ownerID],_gangName,_gangID,_rank,(_queryResult select 0)];
		} else {
			_query = format["INSERT INTO gangmembers (playerid,name,gangname,gangid,rank) VALUES('%1','%2','%3','%4','%5')",(getPlayerUID _ownerID),_ownerID getVariable["realname",name _ownerID],_gangName,_gangID,_rank];
		};
	};

	case 1: {
		//change gang information of player who is not connected
		_playerID = param [1,"",[""]];
		_rank = param [4,0,[0]];
		if(_rank > 5) then {_rank = 5;};

		if(_rank isEqualTo -1) then {
			_query = format["UPDATE gangmembers SET gangname='', gangid='-1', rank='-1' WHERE playerid='%1'",_playerID];
		} else {
			_query = format["UPDATE gangmembers SET gangname='%1', gangid='%2', rank='%3' WHERE playerid='%4'",_gangName,_gangID,_rank,_playerID];
		};
	};

	case 2: {
		//change gang information of player who is connected
		_ownerID = param [1,ObjNull,[ObjNull]];
		_rank = param [4,0,[0]];
		if(_rank > 5) then {_rank = 5;};

		if(_rank isEqualTo -1) then {
			_query = format["UPDATE gangmembers SET gangname='', gangid='-1', rank='-1' WHERE playerid='%1'",(getPlayerUID _ownerID)];
		} else {
			_query = format["UPDATE gangmembers SET gangname='%1', gangid='%2', rank='%3' WHERE playerid='%4'",_gangName,_gangID,_rank,(getPlayerUID _ownerID)];
		};
		[_rank] remoteExec ["OEC_fnc_gangRanks",_ownerID,false];
	};

	case 3: {
		//players name changed, update it so it appears correctly in gang member list
		_ownerID = param [1,ObjNull,[ObjNull]];
		_query = format["UPDATE gangmembers SET name='%1' WHERE playerid='%2'",_gangName,(getPlayerUID _ownerID)];
	};
};

if(!isNil "_query") then {
	[_query,1] call OES_fnc_asyncCall;
};

//private _queryTwo = format ["SELECT id FROM gangbldgs WHERE gang_id='%1' AND gang_name='%2' AND owned='1' AND server='%3'",_gangID,_gangName,olympus_server];
//private _queryBuilding = [_queryTwo,2] call OES_fnc_asyncCall;
//if (count _queryBuilding isEqualTo 0) exitWith {};

//private _queryThree = format ["SELECT COUNT(*) FROM gangmembers WHERE gangid='%1' AND gangname='%2'",_gangID,_gangName];
//private _countResult = (([_queryThree,2] call OES_fnc_asyncCall) select 0);
//if (_countResult < 8) then {
//	[_gangID,_gangName] spawn OES_fnc_lockGangBldg;
//};
