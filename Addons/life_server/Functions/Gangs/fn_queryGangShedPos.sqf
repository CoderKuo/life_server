/*
    File: fn_queryGangShedPos.sqf
    Description: 查询玩家帮派的所有仓库位置和到期时间并返回给客户端
*/

params [
    ["_player", objNull, [objNull]],
    ["_gangId", -1, [0]],
    ["_gangName", "", [""]]
];

if (isNull _player) exitWith {};
if (_gangId <= 0) exitWith {
    // 没有帮派ID，返回空
    [[[], -1], "OEC_fnc_receiveGangShedPos", owner _player] call OEC_fnc_MP;
};

// 使用 spawn 执行异步数据库查询
[_player, _gangId, _gangName] spawn {
    params ["_player", "_gangId", "_gangName"];

    if (isNull _player) exitWith {};

    // 从数据库查询帮派所有仓库位置和到期天数（多行）
    // 使用 _multiRow = true 获取所有行
    private _sql = format ["SELECT pos, (nextpayment::date - CURRENT_DATE) as days_left FROM gangbldgs WHERE gang_id='%1' AND server='%2' AND owned='1'", _gangId, olympus_server];
    private _queryResult = [1, "gang_shed_info", _sql, [], true] call DB_fnc_dbExecute;

    diag_log format ["[QueryGangShedPos] gangId=%1, raw result=%2", _gangId, _queryResult];

    private _sheds = [];  // 存储所有仓库 [[pos1, days1], [pos2, days2], ...]
    private _minDaysLeft = -1;

    if (!isNil "_queryResult" && {_queryResult isEqualType []} && {count _queryResult > 0}) then {
        {
            private _row = _x;

            // 检查行格式
            if (_row isEqualType [] && {count _row >= 2}) then {
                private _posData = _row select 0;
                private _daysData = _row select 1;

                // 解析位置
                private _shedPos = [];
                if (!isNil "_posData" && {_posData isEqualType ""} && {_posData != ""} && {_posData != "[]"}) then {
                    _shedPos = parseSimpleArray _posData;
                    if (isNil "_shedPos" || {!(_shedPos isEqualType [])}) then {
                        _shedPos = call compile _posData;
                    };
                    if (isNil "_shedPos") then {
                        _shedPos = [];
                    };
                };

                // 解析剩余天数
                private _daysLeft = -1;
                if (!isNil "_daysData") then {
                    if (_daysData isEqualType "") then {
                        _daysLeft = parseNumber _daysData;
                    } else {
                        _daysLeft = _daysData;
                    };
                };

                // 添加到仓库列表
                if (count _shedPos > 0) then {
                    _sheds pushBack [_shedPos, _daysLeft];

                    // 记录最小到期天数
                    if (_minDaysLeft < 0 || _daysLeft < _minDaysLeft) then {
                        _minDaysLeft = _daysLeft;
                    };
                };
            };
        } forEach _queryResult;

        diag_log format ["[QueryGangShedPos] Parsed %1 sheds, minDaysLeft: %2", count _sheds, _minDaysLeft];
    };

    if (isNull _player) exitWith {};

    // 返回结果给客户端: [仓库数组, 最小到期天数]
    // 仓库数组格式: [[pos1, days1], [pos2, days2], ...]
    diag_log format ["[QueryGangShedPos] Sending to client: sheds=%1, minDays=%2", _sheds, _minDaysLeft];
    [[_sheds, _minDaysLeft], "OEC_fnc_receiveGangShedPos", owner _player] call OEC_fnc_MP;
};
