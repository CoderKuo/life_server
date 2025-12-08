/*
 * fn_conquestMapper.sqf
 * Conquest Data Access Layer - PostgreSQL Native Syntax
 */

params [
    ["_method", "", [""]],
    ["_params", [], [[]]]
];

private _result = [];

switch (toLower _method) do {

    // ==========================================
    // SELECT Operations
    // ==========================================

    case "getwinnername": {
        _params params [["_gangId", "", [""]]];
        private _sql = "SELECT name FROM gangs WHERE id=%1";
        _result = [1, "conquest_get_winner_name", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    case "getlatestid": {
        _params params [["_server", "", [""]]];
        private _sql = "SELECT MAX(id) FROM conquests WHERE server=%1";
        _result = [1, "conquest_get_latest_id", _sql, [_server]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // INSERT Operations
    // ==========================================

    case "insertconquest": {
        _params params [
            ["_server", "", [""]],
            ["_pot", "", [""]],
            ["_totalPoints", "", [""]],
            ["_winnerId", "", [""]]
        ];
        private _sql = "INSERT INTO conquests (server, pot, total_points, winner_id) VALUES (%1, %2, %3, %4)";
        _result = [2, "conquest_insert", _sql, [_server, _pot, _totalPoints, _winnerId]] call DB_fnc_dbExecute;
    };

    case "insertgangs": {
        _params params [["_valueStr", "", [""]]];
        private _sql = "INSERT INTO conquest_gangs (conquest_id, gang_id, points, payout) VALUES %1";
        _result = [2, "conquest_insert_gangs", _sql, [_valueStr]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // UPDATE Operations
    // ==========================================

    case "setcancelled": {
        _params params [
            ["_id", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE conquest_schedule SET cancelled=1 WHERE id=%1 AND server=%2";
        _result = [2, "conquest_set_cancelled", _sql, [_id, _server]] call DB_fnc_dbExecute;
    };

    case "setcompleted": {
        _params params [
            ["_id", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE conquest_schedule SET completed=1 WHERE id=%1 AND server=%2";
        _result = [2, "conquest_set_completed", _sql, [_id, _server]] call DB_fnc_dbExecute;
    };

    case "getscheduled": {
        // Get pending conquest events
        _params params [["_server", "", [""]]];
        private _sql = "SELECT id,completed,cancelled FROM conquest_schedule WHERE server=%1 AND start_time<=now() AND completed=0 AND cancelled=0 ORDER BY start_time ASC LIMIT 1";
        _result = [1, "conquest_get_scheduled", _sql, [_server]] call DB_fnc_dbExecute;
    };

    case "getmonthlywinner": {
        // Get gang with most conquests last month
        private _sql = "SELECT winner_id FROM conquests WHERE date_started BETWEEN DATE_TRUNC('month', NOW() - INTERVAL '1 month')::date AND (DATE_TRUNC('month', NOW()) - INTERVAL '1 day')::date GROUP BY winner_id ORDER BY COUNT(winner_id) DESC LIMIT 1";
        _result = [1, "conquest_get_monthly_winner", _sql, []] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[ConquestMapper] Unknown method: %1", _method];
        _result = [];
    };
};

_result
