//	Author: Bryan "Tonic" Boardwine
//	Description: Inserts the gang into the database.
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_queryResult","_group","_gangID"];
params [
	["_owner",objNull,[objNull]],
	["_uid","",[""]],
	["_gangName","",[""]]
];
_group = group _owner;

if(isNull _owner || _uid isEqualTo "" || _gangName isEqualTo "") exitWith {}; //Fail

private _check = (_uid find "'" != -1);
if (_check) exitWith {};
private _check = (_gangName find "'" != -1);
if (_check) exitWith {};

_gangName = [_gangName] call OES_fnc_escapeString;

// 使用 Mapper 检查帮派名是否存在
_queryResult = ["gangexists", [_gangName]] call DB_fnc_gangMapper;

//Check to see if the gang name already exists.
if !(count _queryResult isEqualTo 0) exitWith {
	[4,"There is already a gang created with that name please pick another name."] remoteExec ["OEC_fnc_broadcast",(owner _owner),false];
};

//Check to see if a gang with that name already exists but is inactive.
_queryResult = ["gangexistsinactive", [_gangName]] call DB_fnc_gangMapper;

if !(count _queryResult isEqualTo 0) then {
	// 激活已存在的帮派
	["activategang", [str (_queryResult select 0)]] call DB_fnc_gangMapper;
} else {
	// 创建新帮派
	["creategang", [_gangName]] call DB_fnc_gangMapper;
};

_group setVariable["gang_name",_gangName,true];

uiSleep 0.35;
// 获取帮派ID
_queryResult = ["gangexists", [_gangName]] call DB_fnc_gangMapper;
_gangID = (_queryResult select 0);
_group setVariable["gang_id",_gangID,true];

["oev_gang_data",[(_queryResult select 0),_gangName,5]] remoteExec ["OEC_fnc_netSetVar",(owner _owner),false];

// 检查成员记录是否存在
_queryResult = ["getmember", [getPlayerUID _owner]] call DB_fnc_gangMapper;

if !(count _queryResult isEqualTo 0) then {
	// 更新成员信息
	["updatememberfull", [str (_queryResult select 0), _owner getVariable["realname",name _owner], _gangName, str _gangID, "5"]] call DB_fnc_gangMapper;
} else {
	// 添加新成员
	["addmember", [getPlayerUID _owner, _owner getVariable["realname",name _owner], _gangName, str _gangID, "5"]] call DB_fnc_gangMapper;
};

[_group] remoteExec ["OEC_fnc_gangCreated",(owner _owner),false];
