//	File: fn_insertRequest.sqf
//	Author: Bryan "Tonic" Boardwine
//	Modified: 迁移到 PostgreSQL Mapper 层

//	Description:
//	Does something with inserting... Don't have time for
//	descriptions... Need to write it...

private["_uid","_name","_money","_bank","_queryResult","_alias","_ownerID"];
_uid = param [0,"",[""]];
_name = param [1,"",[""]];
_money = param [2,0,[0]];
_bank = param [3,25000,[0]];
_returnToSender = param [4,ObjNull,[ObjNull]];

//Error checks
if((_uid == "") || (_name == "")) exitWith {systemChat "Bad UID or name";}; //Let the client be 'lost' in 'transaction'
if(isNull _returnToSender) exitWith {systemChat "ReturnToSender is Null!";}; //No one to send this to!

if(getPlayerUID _returnToSender != _uid) exitWith {//spoofed player id?
	if(getPlayerUID _returnToSender != "") then {
		[[name _returnToSender,getPlayerUID _returnToSender,"-- HACK MAYBE -- Player UID provided does not match the server fetched version: Provided version:" + _uid],"OEC_fnc_cookieJar",false,false] spawn OEC_fnc_MP;
		[[name _returnToSender,format["-- HACK MAYBE -- Player UID provided does not match the server fetched version: Provided: %1 -- Server: %2",_uid, (getPlayerUID _returnToSender)]],"OEC_fnc_notifyAdmins",-2,false] spawn OEC_fnc_MP;
		format["-- SpyGlass -- HACKLOG -- Player UID provided does not match the server fetched version: Provided: %1 -- Server: %2",_uid, (getPlayerUID _returnToSender)] call OES_fnc_diagLog;
	};
};

_ownerID = owner _returnToSender;

// 使用 playerMapper 检查玩家是否存在
_tickTime = diag_tickTime;
_queryResult = ["exists", [_uid]] call DB_fnc_playerMapper;

"------------- Insert Query Request -------------" call OES_fnc_diagLog;
format["Method: exists | UID: %1",_uid] call OES_fnc_diagLog;
format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)] call OES_fnc_diagLog;
format["Insert Query Result: %1",_queryResult] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

//Double check to make sure the client isn't in the database...
if(_queryResult isEqualType "") exitWith {[[],"OEC_fnc_dataQuery",(owner _returnToSender),false] spawn OEC_fnc_MP;}; //There was an entry!
if(!isNil "_queryResult" && {count _queryResult != 0}) exitWith {[[],"OEC_fnc_dataQuery",(owner _returnToSender),false] spawn OEC_fnc_MP;};

//Clense and prepare some information.
_name = [_name] call OES_fnc_escapeString; //Clense the name of bad chars.
_name = _name splitString " " joinString " "; //Remove any extra white space, one space is fine
_alias = [[_name]] call OES_fnc_escapeArray;
_money = [_money] call OES_fnc_numberToString;
_bank = [_bank] call OES_fnc_numberToString;

"------------- INSERT NEW PLAYER -------------" call OES_fnc_diagLog;
format["INSERT: playerid=%1, name=%2, cash=%3, bank=%4, alias=%5", _uid, _name, _money, _bank, _alias] call OES_fnc_diagLog;
"----------------------------------------------" call OES_fnc_diagLog;

// 使用 playerMapper 插入新玩家
["insert", [_uid, _name, _money, _bank, _alias]] call DB_fnc_playerMapper;

// 等待一小段时间确保 INSERT 执行完成
uiSleep 0.1;

[[],"OEC_fnc_dataQuery",(owner _returnToSender),false] spawn OEC_fnc_MP;
