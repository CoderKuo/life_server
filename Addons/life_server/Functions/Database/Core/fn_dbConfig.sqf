/*
 * fn_dbConfig.sqf
 * Database Configuration Center
 *
 * Usage:
 *   [] call DB_fnc_dbConfig;          // Initialize config
 *   ["get", "tableName"] call DB_fnc_dbConfig;  // Get table name
 */

params [
    ["_action", "init", [""]],
    ["_key", "", [""]]
];

switch (_action) do {
    case "init": {
        // ========================================
        // Table name config (supports different table names for different environments)
        // ========================================
        missionNamespace setVariable ["DB_TABLES", createHashMapFromArray [
            ["players", "players"],
            ["vehicles", "vehicles"],
            ["gangvehicles", "gangvehicles"],
            ["houses", "houses"],
            ["gangs", "gangs"],
            ["gangmembers", "gangmembers"],
            ["gangbldgs", "gangbldgs"],
            ["gangbankhistory", "gangbankhistory"],
            ["gangwars", "gangwars"],
            ["territories", "territories"],
            ["market", "market"],
            ["conquests", "conquests"],
            ["conquest_gangs", "conquest_gangs"],
            ["conquest_schedule", "conquest_schedule"],
            ["stats", "stats"],
            ["messages", "messages"],
            ["playerlogs", "playerlogs"],
            ["log", "log"],
            ["votes", "votes"],
            ["hex_icons", "hex_icons"]
        ]];

        // ========================================
        // Column name mapping (for MySQL/PostgreSQL differences)
        // ========================================
        missionNamespace setVariable ["DB_COLUMNS", createHashMapFromArray [
            // If some column names differ between databases, map them here
            // ["mysql_column", "pgsql_column"]
        ]];

        // ========================================
        // Default values config
        // ========================================
        missionNamespace setVariable ["DB_DEFAULTS", createHashMapFromArray [
            ["player_cash", "0"],
            ["player_bank", "500000"],
            ["empty_array", "[]"],
            ["empty_inventory", "[[],0]"],
            ["default_stats", "[0,0,0,0,0,0,0,0,0,0]"],
            ["default_arrested", "[0,0,0]"]
        ]];

        // ========================================
        // Debug mode
        // ========================================
        missionNamespace setVariable ["life_db_debug", false];

        diag_log "[DB_Config] Database configuration initialized";
        true
    };

    case "get": {
        private _tables = missionNamespace getVariable ["DB_TABLES", createHashMap];
        _tables getOrDefault [_key, _key]
    };

    case "getColumn": {
        private _columns = missionNamespace getVariable ["DB_COLUMNS", createHashMap];
        _columns getOrDefault [_key, _key]
    };

    case "getDefault": {
        private _defaults = missionNamespace getVariable ["DB_DEFAULTS", createHashMap];
        _defaults getOrDefault [_key, ""]
    };

    case "setDebug": {
        missionNamespace setVariable ["life_db_debug", _key == "true"];
        true
    };

    default { nil };
};
