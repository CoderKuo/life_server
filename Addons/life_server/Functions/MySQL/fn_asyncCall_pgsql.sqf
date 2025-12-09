/*
 * 文件: fn_asyncCall_pgsql.sqf
 * 描述: PostgreSQL 兼容层 - 替代 extDB3 的异步调用
 *
 * 此文件提供与原 fn_asyncCall.sqf 相同的接口，但使用 arma3_pgsql 扩展
 *
 * 参数:
 *   0: STRING - 要运行的 SQL 查询
 *   1: INTEGER - 模式 (1=异步INSERT/UPDATE无返回, 2=异步SELECT有返回)
 *   2: BOOL - True返回单个数组，False返回多个条目（用于车库等）
 *
 * 返回:
 *   模式1: true
 *   模式2: 查询结果数组
 */

private ["_queryResult", "_ticket", "_uniqueId", "_return", "_loop"];
params [
    ["_queryStmt", "", [""]],
    ["_mode", 1, [0]],
    ["_multiarr", false, [false]]
];

// ==========================================
// 科学计数法修复函数
// 递归处理数组/值，将科学计数法字符串转换为数字
// ==========================================
private _fixScientificNotation = {
    params ["_value"];

    // 如果是数组，递归处理每个元素
    if (_value isEqualType []) exitWith {
        _value apply { [_x] call _fixScientificNotation }
    };

    // 如果是字符串，检查是否是科学计数法格式
    if (_value isEqualType "") exitWith {
        // 匹配科学计数法: 数字e+/-数字 (如 "1.40001e+07", "5e+06", "-3.5e-02")
        if (_value regexMatch "^-?[0-9]+\.?[0-9]*[eE][+-]?[0-9]+$") then {
            parseNumber _value
        } else {
            _value
        };
    };

    // 其他类型直接返回
    _value
};

// 获取协议名称（在init.sqf中设置）
private _protocol = missionNamespace getVariable ["life_pgsql_protocol", "SQL_MAIN"];

// 模式1: 异步执行，不需要返回结果 (INSERT/UPDATE/DELETE)
if (_mode isEqualTo 1) exitWith {
    [_protocol, _queryStmt] call PGSQL_fnc_callAsync;
    true
};

// 模式2: 异步执行，需要返回结果 (SELECT)
_ticket = [_protocol, _queryStmt, true] call PGSQL_fnc_callAsync;

// 检查是否成功提交
if (isNil "_ticket" || {(_ticket select 0) != 2}) exitWith {
    diag_log format ["[PGSQL] asyncCall 错误: 无法提交查询 - %1", _queryStmt];
    []
};

_uniqueId = _ticket select 1;

// 等待结果
_queryResult = [_uniqueId] call PGSQL_fnc_getAsync;

// 如果结果仍在等待 [3]，持续轮询
if (_queryResult isEqualTo [3]) then {
    private _timeout = diag_tickTime + 30; // 30秒超时
    while {_queryResult isEqualTo [3] && diag_tickTime < _timeout} do {
        _queryResult = [_uniqueId] call PGSQL_fnc_getAsync;
        if (_queryResult isEqualTo [3]) then {
            uiSleep 0.01; // 短暂等待避免CPU占用过高
        };
    };
};

// 处理大数据结果 [5]
if (_queryResult isEqualTo [5]) then {
    _loop = true;
    private _data = "";
    while {_loop} do {
        private _part = [_uniqueId, true] call PGSQL_fnc_getAsync;
        if (_part isEqualTo "") then {
            _loop = false;
        } else {
            _data = _data + _part;
        };
    };
    _queryResult = parseSimpleArray _data;
    if (isNil "_queryResult") then {
        _queryResult = [0, []];
    };
};

// 检查结果格式
if (_queryResult isEqualTo "" || isNil "_queryResult") exitWith {
    diag_log format ["[PGSQL] asyncCall 警告: 空结果 - %1", _queryStmt];
    []
};

// 检查是否成功 (返回码1表示成功)
if ((_queryResult select 0) isEqualTo 0) exitWith {
    diag_log format ["[PGSQL] asyncCall 错误: %1 - 查询: %2", _queryResult, _queryStmt];
    []
};

// 提取数据部分
_return = _queryResult select 1;

// 处理返回格式
if (!_multiarr && count _return > 0) then {
    _return = _return select 0;
};

// 修复科学计数法: 将 "1.40001e+07" 等字符串转换回数字
_return = [_return] call _fixScientificNotation;

_return
