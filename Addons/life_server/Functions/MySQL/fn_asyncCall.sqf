/*
 * 文件: fn_asyncCall.sqf
 * 描述: 数据库异步调用 (PostgreSQL)
 *
 * 参数:
 *   0: STRING - 要运行的 SQL 查询
 *   1: INTEGER - 模式 (1=异步无返回, 2=异步有返回)
 *   2: BOOL - 多数组模式 (可选，默认 false)
 *
 * 返回:
 *   模式1: true
 *   模式2: 查询结果数组
 */

params [
    ["_queryStmt", "", [""]],
    ["_mode", 1, [0]],
    ["_multiarr", false, [false]]
];

// 直接调用 PostgreSQL 实现
[_queryStmt, _mode, _multiarr] call OES_fnc_asyncCall_pgsql
