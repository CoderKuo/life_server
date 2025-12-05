/*
 * 文件: fn_dbRouter.sqf
 * 描述: 数据库路由器 - 统一的数据库调用接口
 *
 * 此函数作为数据库调用的统一入口，根据 life_db_backend 变量
 * 自动路由到 extDB3 或 arma3_pgsql
 *
 * 使用方法:
 *   在 init.sqf 中设置:
 *     life_db_backend = "extdb3";  // 使用 MySQL (extDB3)
 *     life_db_backend = "pgsql";   // 使用 PostgreSQL (arma3_pgsql)
 *
 * 参数:
 *   0: STRING - SQL 查询语句
 *   1: INTEGER - 模式 (1=异步无返回, 2=异步有返回)
 *   2: BOOL - 多数组模式 (可选，默认 false)
 *
 * 返回:
 *   模式1: true
 *   模式2: 查询结果数组
 *
 * 迁移说明:
 *   要将现有代码从 OES_fnc_asyncCall 迁移到此路由器：
 *   1. 将所有 call OES_fnc_asyncCall 替换为 call OES_fnc_dbRouter
 *   2. 或者保留原调用，修改 fn_asyncCall.sqf 调用此路由器
 */

params [
    ["_queryStmt", "", [""]],
    ["_mode", 1, [0]],
    ["_multiarr", false, [false]]
];

// 获取当前后端配置
private _backend = missionNamespace getVariable ["life_db_backend", "extdb3"];

// 根据后端选择调用方式
switch (toLower _backend) do {
    case "pgsql": {
        // 使用 PostgreSQL 后端

        // 如果启用了自动 SQL 转换，先转换查询语句
        if (missionNamespace getVariable ["life_db_auto_convert", true]) then {
            _queryStmt = [_queryStmt] call OES_fnc_mysqlToPgsql;
        };

        // 调用 PostgreSQL 兼容层
        [_queryStmt, _mode, _multiarr] call OES_fnc_asyncCall_pgsql
    };

    case "extdb3": {
        // 使用原始 extDB3 后端 (MySQL)
        [_queryStmt, _mode, _multiarr] call OES_fnc_asyncCall_extdb3
    };

    default {
        // 默认使用 extDB3
        diag_log format ["[DB Router] 警告: 未知的数据库后端 '%1'，使用默认 extDB3", _backend];
        [_queryStmt, _mode, _multiarr] call OES_fnc_asyncCall_extdb3
    };
};
