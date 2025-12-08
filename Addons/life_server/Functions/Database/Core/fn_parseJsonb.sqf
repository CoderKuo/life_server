/*
 * fn_parseJsonb.sqf
 * JSONB Data Parser
 *
 * Description:
 * Parses JSONB data returned from PostgreSQL (as SQF format string).
 * Handles both string and array inputs safely.
 *
 * Parameter(s):
 * _this select 0: ANY - The data to parse (string or array)
 * _this select 1: ANY - Default value if parsing fails (default: [])
 *
 * Returns:
 * ARRAY - Parsed array or default value
 *
 * Example:
 * _licenses = [_rawData, []] call DB_fnc_parseJsonb;
 * _stats = [_rawData, [0,0,0,0,0,0,0,0,0,0]] call DB_fnc_parseJsonb;
 */

params [
    ["_data", nil, ["", []]],
    ["_default", [], [[], 0, ""]]
];

// If data is nil or empty, return default
if (isNil "_data") exitWith { _default };

// If already an array, return it directly
if (_data isEqualType []) exitWith { _data };

// If not a string, return default
if !(_data isEqualType "") exitWith { _default };

// If empty string, return default
if (_data == "" || _data == "[]") exitWith { _default };

// Parse the string
private _result = parseSimpleArray _data;

// Validate result
if (isNil "_result" || {!(_result isEqualType [])}) exitWith { _default };

_result
