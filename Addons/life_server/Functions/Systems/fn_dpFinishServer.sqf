/*
 * fn_dpFinishServer.sqf
 * 服务端快递任务完成验证
 * 防止客户端篡改奖励金额
 *
 * 调用方式: [_startPos, _endPos] remoteExec ["OES_fnc_dpFinishServer", 2];
 */

params [
    ["_startPos", [], [[]]],
    ["_endPos", [], [[]]]
];

// 获取调用者
private _ownerID = remoteExecutedOwner;
private _player = [_ownerID] call OES_fnc_getPlayerByOwner;

if (isNull _player) exitWith {
    diag_log format ["[dpFinishServer] ERROR: Cannot find player for owner %1", _ownerID];
};

private _uid = getPlayerUID _player;
private _playerName = name _player;

// 验证玩家状态
if (!alive _player) exitWith {
    ["dp_error", "你已死亡，无法完成快递任务"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
};

// 验证位置参数
if (count _startPos < 2 || count _endPos < 2) exitWith {
    format ["[dpFinishServer] ERROR: Invalid positions from %1. Start: %2, End: %3", _playerName, _startPos, _endPos] call OES_fnc_diagLog;
    ["dp_error", "无效的快递位置数据"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
};

// 服务端计算距离和奖励
private _distance = round(_startPos distance _endPos);
private _reward = round(2.4 * _distance);

// 防止异常奖励 (距离太短或太长)
if (_distance < 100) exitWith {
    format ["[dpFinishServer] WARNING: Suspicious short distance %1m from %2", _distance, _playerName] call OES_fnc_diagLog;
    ["dp_error", "快递距离异常，无法完成"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
};

if (_distance > 50000) exitWith {
    format ["[dpFinishServer] WARNING: Suspicious long distance %1m from %2", _distance, _playerName] call OES_fnc_diagLog;
    ["dp_error", "快递距离异常，无法完成"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
};

// 从数据库获取当前银行余额
private _dbResult = ["getbank", [_uid]] call DB_fnc_playerMapper;
private _currentBank = if (count _dbResult > 0) then {
    private _val = _dbResult select 0;
    if (_val isEqualType 0) then { _val } else { parseNumber _val }
} else { 0 };

// 计算新余额
private _newBank = _currentBank + _reward;

// 更新数据库 - 使用安全数字函数
private _newBankStr = ["format", _newBank] call OES_fnc_safeNumber;
["updatebank", [_uid, _newBankStr]] call DB_fnc_playerMapper;

// 记录日志
format ["[dpFinishServer] Player %1 (%2) completed delivery. Distance: %3m, Reward: $%4, NewBank: $%5",
    _playerName, _uid, _distance, _reward, _newBank] call OES_fnc_diagLog;

// 记录到高级日志
[_player, "delivery_finish", format ["Distance: %1m, Reward: $%2", _distance, _reward], 0, 1] call OES_fnc_AdvancedLog;

// 发送结果给客户端
["dp_finish_success", _reward, _newBank, _distance] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
