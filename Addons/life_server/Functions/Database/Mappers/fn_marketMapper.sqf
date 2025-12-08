/*
 * fn_marketMapper.sqf
 * Market Data Access Layer - PostgreSQL Native Syntax
 */

diag_log "[MarketMapper] ENTRY POINT";
diag_log format ["[MarketMapper] _this = %1", _this];

params [
    ["_method", "", [""]],
    ["_params", [], [[]]]
];

diag_log format ["[MarketMapper] method=%1, params=%2", _method, _params];

private _result = [];

switch (toLower _method) do {

    // ==========================================
    // SELECT Operations
    // ==========================================

    case "getarray": {
        _params params [["_marketId", "", [""]]];
        private _sql = "SELECT market_array FROM market WHERE id='%1'";
        _result = [1, "market_get_array", _sql, [_marketId]] call DB_fnc_dbExecute;
    };

    case "getreset": {
        _params params [["_marketId", "", [""]]];
        private _sql = "SELECT reset FROM market WHERE id='%1'";
        _result = [1, "market_get_reset", _sql, [_marketId]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // UPDATE Operations
    // ==========================================

    case "updatearray": {
        _params params [
            ["_marketId", "", [""]],
            ["_marketArray", "", [""]]
        ];
        private _sql = "UPDATE market SET market_array='%2' WHERE id='%1'";
        _result = [2, "market_update_array", _sql, [_marketId, _marketArray]] call DB_fnc_dbExecute;
    };

    case "resetmarket": {
        _params params [
            ["_marketId", "", [""]],
            ["_marketArray", "", [""]]
        ];
        private _sql = "UPDATE market SET reset='0', market_array='%2' WHERE id='%1'";
        _result = [2, "market_reset", _sql, [_marketId, _marketArray]] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[MarketMapper] Unknown method: %1", _method];
        _result = [];
    };
};

_result
