/*
    File: fn_queryGangShedPos.sqf
    Description: 查询玩家帮派的仓库位置和到期时间并返回给客户端
*/

params [
    ["_player", objNull, [objNull]],
    ["_gangId", -1, [0]],
    ["_gangName", "", [""]]
];

if (isNull _player) exitWith {};
if (_gangId <= 0) exitWith {
    // 没有帮派ID，返回空
    [[[], "", -1], "OEC_fnc_receiveGangShedPos", owner _player] call OEC_fnc_MP;
};

// 使用 spawn 执行异步数据库查询
[_player, _gangId, _gangName] spawn {
    params ["_player", "_gangId", "_gangName"];

    if (isNull _player) exitWith {};

    // 从数据库查询帮派仓库位置和到期天数
    // 使用自定义SQL查询获取位置和剩余天数
    private _sql = format ["SELECT pos, (nextpayment::date - CURRENT_DATE) as days_left FROM gangbldgs WHERE gang_id='%1' AND server='%2' AND owned='1' LIMIT 1", _gangId, olympus_server];
    private _queryResult = [1, "gang_shed_info", _sql, []] call DB_fnc_dbExecute;

    diag_log format ["[QueryGangShedPos] gangId=%1, raw result=%2", _gangId, _queryResult];

    private _shedPos = [];
    private _shedClassName = "Land_i_Shed_Ind_F";
    private _daysLeft = -1;

    if (!isNil "_queryResult" && {_queryResult isEqualType []} && {count _queryResult > 0}) then {
        private _firstRow = _queryResult select 0;
        diag_log format ["[QueryGangShedPos] firstRow=%1, type=%2", _firstRow, typeName _firstRow];

        if (_firstRow isEqualType [] && {count _firstRow >= 2}) then {
            // 解析位置
            private _posData = _firstRow select 0;
            if (!isNil "_posData" && {_posData isEqualType ""} && {_posData != ""} && {_posData != "[]"}) then {
                _shedPos = call compile _posData;
            };

            // 解析剩余天数
            private _daysData = _firstRow select 1;
            if (!isNil "_daysData") then {
                if (_daysData isEqualType "") then {
                    _daysLeft = parseNumber _daysData;
                } else {
                    _daysLeft = _daysData;
                };
            };

            diag_log format ["[QueryGangShedPos] Parsed shedPos: %1, daysLeft: %2", _shedPos, _daysLeft];
        };
    };

    if (isNull _player) exitWith {};

    // 返回结果给客户端: [位置, 类名, 到期天数]
    diag_log format ["[QueryGangShedPos] Sending to client: pos=%1, class=%2, days=%3", _shedPos, _shedClassName, _daysLeft];
    [[_shedPos, _shedClassName, _daysLeft], "OEC_fnc_receiveGangShedPos", owner _player] call OEC_fnc_MP;
};
