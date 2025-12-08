/*
 * ShongY制作日志系统
 * Modified: 迁移到 PostgreSQL Mapper 层
 */
params [
    ["_PID", "", [""]],
    ["_LOGTitle", "", [""]],
    ["_LOG", "", [""]]
];

// 使用 logMapper 插入日志
["insertlog", [_PID, _LOGTitle, _LOG]] call DB_fnc_logMapper;

//[getPlayerUID player, "TEST-Log", format ["%1 hat die Log Funktion mit Params getestet!",name player]] remoteExec ["DB_fnc_AdvancedLog",2];
