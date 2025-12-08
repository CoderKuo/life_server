/*
 * fn_logMapper.sqf
 * Log Data Access Layer - PostgreSQL Native Syntax
 */

params [
    ["_method", "", [""]],
    ["_params", [], [[]]]
];

private _result = [];

switch (toLower _method) do {

    case "insertlog": {
        _params params [
            ["_pid", "", [""]],
            ["_title", "", [""]],
            ["_log", "", [""]]
        ];
        private _sql = "INSERT INTO playerlogs (playerID, logTitle, log) VALUES('%1', '%2', '%3')";
        _result = [2, "log_insert", _sql, [_pid, _title, _log]] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[LogMapper] Unknown method: %1", _method];
        _result = [];
    };
};

_result
