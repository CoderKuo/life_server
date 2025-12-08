/*
 * fn_escapeArray.sqf
 * PostgreSQL JSONB Safe Array Escape
 *
 * Description:
 * Converts an array to a valid JSON string format for PostgreSQL JSONB storage.
 * JSON requires double quotes for strings, not single quotes.
 *
 * Parameter(s):
 * _this select 0: ARRAY - The array to escape
 *
 * Returns:
 * STRING - Array as valid JSON string for JSONB insertion
 */

params [["_array", [], [[]]]];

// Convert array to string - SQF str function uses double quotes
// Example: [["name"]] becomes "[[""name""]]"
private _string = str _array;

// For JSONB, we need valid JSON format which uses double quotes
// The double quotes in the string need to be escaped for SQL
// [[""name""]] -> [[\"name\"]] for JSON inside SQL single quotes
// But PostgreSQL can handle '{"key": "value"}' directly
// We just need to escape single quotes in the content if any

// Replace any single quotes in the content with escaped single quotes for SQL safety
_string = _string splitString "'" joinString "''";

// Return the string (keep double quotes for valid JSON)
_string
