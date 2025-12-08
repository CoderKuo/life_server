/*
    File: fn_gangRename.sqf
    Author: Server
    Description: 处理帮派改名请求
*/

params [
    ["_gangID", -1, [0, ""]],
    ["_newName", "", [""]],
    ["_unit", objNull, [objNull]]
];

// 改名费用 (从帮派资金扣除)
private _renameCost = 50000;

diag_log format ["[GangRename] Started - gangID: %1, newName: %2, unit: %3", _gangID, _newName, _unit];

if (isNull _unit) exitWith {
    diag_log "[GangRename] Error: Unit is null";
};

private _ownerID = owner _unit;

if (_gangID isEqualTo -1 || _gangID isEqualTo "") exitWith {
    diag_log "[GangRename] Error: Invalid gang ID";
    [1, "帮派ID无效"] remoteExec ["OEC_fnc_broadcast", _ownerID];
    ["oev_gangRename_success", false] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
};

if (_newName isEqualTo "") exitWith {
    diag_log "[GangRename] Error: Empty name";
    [1, "帮派名称不能为空"] remoteExec ["OEC_fnc_broadcast", _ownerID];
    ["oev_gangRename_success", false] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
};

// 转换 gangID 为字符串
private _gangIDStr = if (_gangID isEqualType 0) then { str _gangID } else { _gangID };
diag_log format ["[GangRename] gangIDStr: %1", _gangIDStr];

// 检查玩家权限 (必须是帮主或副帮主)
private _playerGang = ["getplayergang", [getPlayerUID _unit]] call DB_fnc_gangMapper;
diag_log format ["[GangRename] playerGang result: %1", _playerGang];

if (count _playerGang == 0) exitWith {
    diag_log "[GangRename] Error: Player not in any gang";
    [1, "您不在任何帮派中"] remoteExec ["OEC_fnc_broadcast", _ownerID];
    ["oev_gangRename_success", false] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
};

private _playerGangID = str (_playerGang select 0);
private _playerRank = _playerGang select 2;
diag_log format ["[GangRename] playerGangID: %1, playerRank: %2", _playerGangID, _playerRank];

if (_playerGangID != _gangIDStr) exitWith {
    diag_log format ["[GangRename] Error: Player gang %1 != requested gang %2", _playerGangID, _gangIDStr];
    [1, "您不属于该帮派"] remoteExec ["OEC_fnc_broadcast", _ownerID];
    ["oev_gangRename_success", false] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
};

if (_playerRank < 4) exitWith {
    diag_log format ["[GangRename] Error: Insufficient rank %1", _playerRank];
    [1, "只有帮主或副帮主才能修改帮派名称"] remoteExec ["OEC_fnc_broadcast", _ownerID];
    ["oev_gangRename_success", false] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
};

// 检查新名称是否已被使用
private _existingGang = ["gangexists", [_newName]] call DB_fnc_gangMapper;
diag_log format ["[GangRename] existingGang check: %1", _existingGang];
if (count _existingGang > 0 && {(_existingGang select 0) != ""}) exitWith {
    diag_log format ["[GangRename] Error: Name already exists: %1", _newName];
    [1, format ["帮派名称 '%1' 已被使用", _newName]] remoteExec ["OEC_fnc_broadcast", _ownerID];
    ["oev_gangRename_success", false] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
};

// 检查帮派资金是否足够
private _gangBank = ["getgangbank", [_gangIDStr]] call DB_fnc_gangMapper;
diag_log format ["[GangRename] gangBank result: %1", _gangBank];
private _currentFunds = if (count _gangBank > 0) then { _gangBank select 0 } else { 0 };
diag_log format ["[GangRename] currentFunds: %1, renameCost: %2", _currentFunds, _renameCost];

if (_currentFunds < _renameCost) exitWith {
    diag_log format ["[GangRename] Error: Insufficient funds %1 < %2", _currentFunds, _renameCost];
    [1, format ["帮派资金不足! 修改名称需要 $%1，当前资金: $%2", [_renameCost] call OES_fnc_numberToString, [_currentFunds] call OES_fnc_numberToString]] remoteExec ["OEC_fnc_broadcast", _ownerID];
    ["oev_gangRename_success", false] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
};

// 获取旧名称用于日志
private _oldNameResult = ["getgangname", [_gangIDStr]] call DB_fnc_gangMapper;
private _oldName = if (count _oldNameResult > 0) then { _oldNameResult select 0 } else { "Unknown" };
diag_log format ["[GangRename] oldName: %1", _oldName];

// 扣除帮派资金
private _newBalance = _currentFunds - _renameCost;
["updategangbank", [_gangIDStr, str _newBalance]] call DB_fnc_gangMapper;
diag_log format ["[GangRename] Updated bank balance to: %1", _newBalance];

// 记录银行历史 (type 3 = 改名费用)
["addbankhistory", [name _unit, getPlayerUID _unit, "3", str _renameCost, _gangIDStr]] call DB_fnc_gangMapper;

// 更新帮派名称
["renamegang", [_gangIDStr, _newName]] call DB_fnc_gangMapper;
diag_log format ["[GangRename] Renamed gang to: %1", _newName];

// 更新所有成员的帮派名称
["renamegangmembers", [_gangIDStr, _newName]] call DB_fnc_gangMapper;

// 更新帮派建筑的帮派名称
["renamegangbuildings", [_gangIDStr, _newName]] call DB_fnc_gangMapper;

// 记录日志
[
    ["event", "Gang Rename"],
    ["player", name _unit],
    ["player_id", getPlayerUID _unit],
    ["gang_id", _gangIDStr],
    ["old_name", _oldName],
    ["new_name", _newName],
    ["cost", _renameCost],
    ["new_balance", _newBalance]
] call OES_fnc_logIt;

diag_log format ["[GangRename] SUCCESS - Player %1 (%2) renamed gang %3 from '%4' to '%5'. Cost: $%6",
    name _unit, getPlayerUID _unit, _gangIDStr, _oldName, _newName, _renameCost];

// 通知操作者
[0, format ["帮派名称已从 '%1' 修改为 '%2'，花费 $%3", _oldName, _newName, [_renameCost] call OES_fnc_numberToString]] remoteExec ["OEC_fnc_broadcast", _ownerID];

// 更新所有在线帮派成员的本地数据
{
    if (isPlayer _x && alive _x) then {
        private _memberGang = _x getVariable ["gang_data", []];
        if (count _memberGang >= 3) then {
            private _memberGangID = _memberGang select 0;
            if (str _memberGangID == _gangIDStr) then {
                // 更新成员的本地帮派数据
                private _updatedGangData = [_memberGangID, _newName, _memberGang select 2];
                _x setVariable ["gang_data", _updatedGangData, true];
                ["oev_gang_data", _updatedGangData] remoteExec ["OEC_fnc_netSetVar", owner _x, false];

                // 通知成员 (除了操作者)
                if (_x != _unit) then {
                    [0, format ["帮派名称已被修改为 '%1'", _newName]] remoteExec ["OEC_fnc_broadcast", owner _x];
                };
            };
        };
    };
} forEach allPlayers;

// 返回成功给客户端
diag_log "[GangRename] Sending success to client";
["oev_gangRename_success", true] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
["oev_gangRename_newName", _newName] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
