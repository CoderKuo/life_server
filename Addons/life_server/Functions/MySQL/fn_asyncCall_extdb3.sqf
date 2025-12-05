/*
 * 文件: fn_asyncCall_extdb3.sqf
 * 描述: 原始 extDB3 异步调用函数（备份）
 *
 * 作者: 布莱恩"补品"Boardwine
 * 说明: 提交对ExtDB的异步调用
 *
 * 参数:
 *   0: STRING - 要运行的查询
 *   1: INTEGER - 模式 (1=ASYNC+无返回用于update/insert, 2=ASYNC+有返回用于query)
 *   2: BOOL - True返回单个数组，false返回多个条目（主要用于车库）
 *
 * 返回:
 *   模式1: true
 *   模式2: 查询结果数组
 */

private["_queryResult","_key","_return","_loop"];
params [
    ["_queryStmt","",[""]],
    ["_mode",1,[0]],
    ["_multiarr",false,[false]]
];

_key = "extDB3" callExtension format["%1:%2:%3",_mode,(call life_sql_id),_queryStmt];

if (_mode isEqualTo 1) exitWith {true};

_key = call compile format["%1",_key];
_key = (_key select 1);
_queryResult = "extDB3" callExtension format["4:%1", _key];

// 确保收到数据
if (_queryResult isEqualTo "[3]") then {
    for "_i" from 0 to 1 step 0 do {
        if (!(_queryResult isEqualTo "[3]")) exitWith {};
        _queryResult = "extDB3" callExtension format["4:%1", _key];
    };
};

if (_queryResult isEqualTo "[5]") then {
    _loop = true;
    for "_i" from 0 to 1 step 0 do {
        _queryResult = "";
        for "_i" from 0 to 1 step 0 do {
            _pipe = "extDB3" callExtension format["5:%1", _key];
            if (_pipe isEqualTo "") exitWith {_loop = false};
            _queryResult = _queryResult + _pipe;
        };
    if (!_loop) exitWith {};
    };
};
_queryResult = call compile _queryResult;
if ((_queryResult select 0) isEqualTo 0) exitWith {[]};
_return = (_queryResult select 1);
if (!_multiarr && count _return > 0) then {
    _return = (_return select 0);
};

_return
