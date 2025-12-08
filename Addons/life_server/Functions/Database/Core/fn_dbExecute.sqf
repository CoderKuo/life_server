/*
 * fn_dbExecute.sqf
 * Database Execution Core Layer - PostgreSQL Native
 *
 * Parameters:
 *   _mode: Execution mode (1=SELECT needs return, 2=INSERT/UPDATE no return)
 *   _queryName: Query name (for logging)
 *   _sql: PostgreSQL SQL statement
 *   _params: SQL parameter array (for formatting)
 *   _multiRow: Return multiple rows (default: false for single row, true for all rows)
 *
 * Return:
 *   Query result or empty array
 *
 * Note: OES_fnc_asyncCall mode definition:
 *   1 = async no return
 *   2 = async with return
 * So we need to convert: our 1 -> their 2, our 2 -> their 1
 */

params [
    ["_mode", 1, [0]],
    ["_queryName", "", [""]],
    ["_sql", "", [""]],
    ["_params", [], [[]]],
    ["_multiRow", false, [false]]
];

// Apply parameters
if (count _params > 0) then {
    _sql = format ([_sql] + _params);
};

// Debug log - always output
diag_log format ["[DB_Execute] %1 | Mode: %2 | SQL: %3", _queryName, _mode, _sql];

// Convert mode: our 1(SELECT) -> asyncCall 2(with return)
//               our 2(UPDATE) -> asyncCall 1(no return)
private _asyncMode = if (_mode == 1) then { 2 } else { 1 };

// Execute query - use existing asyncCall router
// Pass _multiRow parameter to get all rows instead of just first row
private _result = [_sql, _asyncMode, _multiRow] call OES_fnc_asyncCall;

// Debug log - output result
diag_log format ["[DB_Execute] %1 | Result: %2", _queryName, _result];

_result
