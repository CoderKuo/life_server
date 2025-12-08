/*
    File: fn_getHouseSaleHistory.sqf
    Author: Server
    Description: 获取玩家的售房历史记录
*/

params [
    ["_player", objNull, [objNull]]
];

if (isNull _player) exitWith {};
if (!isPlayer _player) exitWith {};

private _ownerID = owner _player;
private _pid = getPlayerUID _player;

// 查询售房历史
private _queryResult = ["gethousesalehistory", [_pid]] call DB_fnc_playerMapper;

private _history = [];
if (count _queryResult > 0 && {!isNil {_queryResult select 0}}) then {
    _history = _queryResult select 0;
    if (_history isEqualType "") then {
        _history = parseSimpleArray _history;
    };
    if (isNil "_history") then { _history = []; };
};

// 返回历史记录给客户端
// 格式: [[houseType, price, buyerName, timestamp], ...]
[["oev_houseSaleHistory", _history], "OEC_fnc_netSetVar", _ownerID, false] spawn OEC_fnc_MP;
