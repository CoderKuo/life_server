/*
 * 文件: fn_asyncCall.sqf
 * 描述: 数据库异步调用路由器
 *
 * 原作者: 布莱恩"补品"Boardwine
 * 修改: 添加 PostgreSQL 支持，通过 life_db_backend 变量切换后端
 *
 * 配置说明:
 *   在 init.sqf 中设置 life_db_backend 变量:
 *     life_db_backend = "extdb3";  // 使用 MySQL (默认，保持原有行为)
 *     life_db_backend = "pgsql";   // 使用 PostgreSQL
 *
 *   可选配置:
 *     life_db_auto_convert = true;  // 自动转换 MySQL 语法到 PostgreSQL (默认 true)
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

// 获取当前后端配置，默认使用 extdb3 保持向后兼容
private _backend = missionNamespace getVariable ["life_db_backend", "extdb3"];

switch (toLower _backend) do {
    case "pgsql": {
        // PostgreSQL 后端

        // 如果启用了自动 SQL 转换
        if (missionNamespace getVariable ["life_db_auto_convert", true]) then {
            _queryStmt = [_queryStmt] call OES_fnc_mysqlToPgsql;
        };

        // 调用 PostgreSQL 兼容层
        [_queryStmt, _mode, _multiarr] call OES_fnc_asyncCall_pgsql
    };

    case "extdb3";
    default {
        // extDB3 后端 (MySQL) - 默认行为
        [_queryStmt, _mode, _multiarr] call OES_fnc_asyncCall_extdb3
    };
}