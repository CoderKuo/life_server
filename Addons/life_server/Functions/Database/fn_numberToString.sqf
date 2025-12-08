/*
 * fn_numberToString.sqf
 * Number to String Conversion (avoids scientific notation)
 *
 * Description:
 * Converts a number to string format, avoiding scientific notation
 * that can occur with very large numbers in SQF.
 *
 * Parameter(s):
 * _this select 0: NUMBER - The number to convert
 *
 * Returns:
 * STRING - Number as string without scientific notation
 *
 * Example:
 * [1234567890] call OES_fnc_numberToString
 * Returns: "1234567890"
 */

params [["_number", 0, [0]]];

// Handle negative numbers
private _isNegative = _number < 0;
if (_isNegative) then {
    _number = abs _number;
};

// Use BIS function to get individual digits
private _digits = _number call BIS_fnc_numberDigits;

// Build string from digits
private _result = "";
{
    _result = _result + str _x;
} forEach _digits;

// Add negative sign if needed
if (_isNegative) then {
    _result = "-" + _result;
};

_result
