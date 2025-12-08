/*
 * fn_messageMapper.sqf
 * Message Data Access Layer - PostgreSQL Native Syntax
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

    case "getrecent": {
        _params params [
            ["_uid", "", [""]],
            ["_limit", "10", [""]]
        ];
        private _sql = "SELECT fromID, toID, message, fromName, toName FROM messages WHERE toID='%1' ORDER BY time DESC LIMIT %2";
        _result = [1, "message_get_recent", _sql, [_uid, _limit]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // INSERT Operations
    // ==========================================

    case "insert": {
        _params params [
            ["_fromId", "", [""]],
            ["_toId", "", [""]],
            ["_message", "", [""]],
            ["_fromName", "", [""]],
            ["_toName", "", [""]]
        ];
        private _sql = "INSERT INTO messages (fromID, toID, message, fromName, toName) VALUES('%1', '%2', '\"\"%3\"\"', '%4', '%5')";
        _result = [2, "message_insert", _sql, [_fromId, _toId, _message, _fromName, _toName]] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[MessageMapper] Unknown method: %1", _method];
        _result = [];
    };
};

_result
