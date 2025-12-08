//  File: fn_updateMember
//	Author: Bryan "Tonic" Boardwine
//	Description: Updates the gang information?
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_mode","_group","_groupID","_bank","_maxMembers","_members","_owner","_ownerID","_gangID","_gangName","_playerID","_rank","_principal"];
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

		// 使用 Mapper 检查成员是否存在
		_queryResult = ["getmember", [getPlayerUID _ownerID]] call DB_fnc_gangMapper;

		[format['{"event":"Gang Invite", "player":"%1", "target":"%2", "value":"%3", "location":"%4"}',_principal,getPlayerUID _ownerID,'null','null']] call OES_fnc_logIt;

		if !(count _queryResult isEqualTo 0) then {
			// 更新成员信息
			["updatememberfull", [str (_queryResult select 0), _ownerID getVariable["realname",name _ownerID], _gangName, str _gangID, str _rank]] call DB_fnc_gangMapper;
		} else {
			// 添加新成员
			["addmember", [getPlayerUID _ownerID, _ownerID getVariable["realname",name _ownerID], _gangName, str _gangID, str _rank]] call DB_fnc_gangMapper;
		};
	};

	case 1: {
		//change gang information of player who is not connected
		_playerID = param [1,"",[""]];
		_rank = param [4,0,[0]];
		if(_rank > 5) then {_rank = 5;};

		if(_rank isEqualTo -1) then {
			// 移除成员
			["removemember", [_playerID]] call DB_fnc_gangMapper;
		} else {
			// 更新成员
			["updatemember", [_playerID, _gangName, str _gangID, str _rank]] call DB_fnc_gangMapper;
		};
	};

	case 2: {
		//change gang information of player who is connected
		_ownerID = param [1,ObjNull,[ObjNull]];
		_rank = param [4,0,[0]];
		if(_rank > 5) then {_rank = 5;};

		if(_rank isEqualTo -1) then {
			// 移除成员
			["removemember", [getPlayerUID _ownerID]] call DB_fnc_gangMapper;
		} else {
			// 更新成员
			["updatemember", [getPlayerUID _ownerID, _gangName, str _gangID, str _rank]] call DB_fnc_gangMapper;
		};
		[_rank] remoteExec ["OEC_fnc_gangRanks",_ownerID,false];
	};

	case 3: {
		//players name changed, update it so it appears correctly in gang member list
		_ownerID = param [1,ObjNull,[ObjNull]];
		// 更新成员名字
		["updatemembername", [getPlayerUID _ownerID, _gangName]] call DB_fnc_gangMapper;
	};
};
