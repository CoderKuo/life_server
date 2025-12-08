/*
 * fn_escapeString.sqf
 * PostgreSQL Safe String Escape
 *
 * Description:
 * Makes a string safe to be passed to PostgreSQL by escaping single quotes
 * and removing potentially dangerous characters.
 *
 * Parameter(s):
 * _this select 0: STRING - The string to escape
 *
 * Returns:
 * STRING - Escaped string safe for SQL insertion
 */

params [["_string", "", [""]]];

// Characters to remove completely (dangerous for SQL)
private _removeChars = toArray "\`";

// Convert string to array for processing
private _charArray = toArray _string;

// First pass: remove dangerous characters
{
    if (_x in _removeChars) then {
        _charArray set [_forEachIndex, -1];
    };
} forEach _charArray;

_charArray = _charArray - [-1];

// Convert back to string
_string = toString _charArray;

// Escape single quotes for PostgreSQL (replace ' with '')
_string = _string splitString "'" joinString "''";

_string
