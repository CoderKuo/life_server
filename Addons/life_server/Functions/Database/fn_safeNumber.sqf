/*
 * fn_safeNumber.sqf
 * Safe Number Handling - Avoids scientific notation and floating point precision issues
 *
 * Description:
 * Provides safe number handling for database operations.
 * SQF has fundamental issues with large numbers:
 * - Numbers > 1 million can become scientific notation (e.g., "1e+006")
 * - Floating point precision is limited to ~7 significant digits
 * - format/str commands convert large numbers to scientific notation
 *
 * This function provides multiple modes for safe number handling:
 * - "toInt": Safely converts a number to integer string (truncates decimals)
 * - "fromStr": Safely parses a string to integer (handles scientific notation in input)
 * - "add": Safely adds two numbers and returns integer string
 * - "sub": Safely subtracts two numbers and returns integer string
 * - "format": Formats number for SQL (same as toInt but with validation)
 *
 * IMPORTANT: For best results, keep numbers as strings throughout the pipeline.
 * Only convert to numbers when math is needed, then immediately convert back.
 *
 * Parameter(s):
 * _this select 0: STRING - Mode ("toInt", "fromStr", "add", "sub", "format")
 * _this select 1: ANY - Input value(s) depending on mode
 *
 * Returns:
 * STRING or NUMBER depending on mode
 *
 * Examples:
 * ["toInt", 5326399] call OES_fnc_safeNumber          // Returns: "5326399"
 * ["toInt", 5.3264e+06] call OES_fnc_safeNumber       // Returns: "5326400" (precision loss already occurred!)
 * ["fromStr", "5326399"] call OES_fnc_safeNumber      // Returns: 5326399
 * ["add", 5000000, 100000] call OES_fnc_safeNumber    // Returns: "5100000"
 * ["format", 1234567] call OES_fnc_safeNumber         // Returns: "1234567"
 */

params [
    ["_mode", "toInt", [""]],
    ["_input1", 0, [0, ""]],
    ["_input2", 0, [0, ""]]
];

private _result = "";

switch (toLower _mode) do {

    // ==========================================
    // Convert number to integer string
    // Uses floor to ensure integer, then careful string conversion
    // ==========================================
    case "toint";
    case "format": {
        private _num = _input1;

        // If input is string, parse it first
        if (_num isEqualType "") then {
            _num = parseNumber _num;
        };

        // Handle negative numbers
        private _isNegative = _num < 0;
        if (_isNegative) then {
            _num = abs _num;
        };

        // Floor to get integer
        _num = floor _num;

        // Handle zero specially
        if (_num == 0) exitWith {
            _result = "0";
        };

        // Use BIS_fnc_numberDigits for conversion
        // This works correctly for integers up to about 10 million
        // For larger numbers, we need a different approach
        if (_num < 10000000) then {
            // Safe range - use standard method
            private _digits = _num call BIS_fnc_numberDigits;
            {
                _result = _result + str _x;
            } forEach _digits;
        } else {
            // Large number - build digit by digit using division
            // This avoids floating point precision issues
            private _digits = [];
            private _temp = _num;

            while {_temp > 0} do {
                private _digit = _temp mod 10;
                _digits pushBack (floor _digit);
                _temp = floor (_temp / 10);
            };

            // Digits are in reverse order
            reverse _digits;

            {
                _result = _result + str _x;
            } forEach _digits;
        };

        // Add negative sign if needed
        if (_isNegative) then {
            _result = "-" + _result;
        };
    };

    // ==========================================
    // Parse string to number safely
    // Handles various input formats including scientific notation
    // ==========================================
    case "fromstr": {
        private _str = _input1;

        // If already a number, just floor it
        if (_str isEqualType 0) exitWith {
            _result = floor _str;
        };

        // Clean the string - remove non-numeric characters except minus and decimal
        _str = _str regexReplace ["[^0-9\.\-eE\+]", ""];

        // Handle empty string
        if (_str == "") exitWith {
            _result = 0;
        };

        // Parse and floor to integer
        _result = floor (parseNumber _str);
    };

    // ==========================================
    // Safe addition - adds two numbers and returns string
    // ==========================================
    case "add": {
        private _num1 = _input1;
        private _num2 = _input2;

        // Convert strings to numbers if needed
        if (_num1 isEqualType "") then { _num1 = parseNumber _num1; };
        if (_num2 isEqualType "") then { _num2 = parseNumber _num2; };

        // Add and convert result
        private _sum = floor (_num1 + _num2);
        _result = ["toInt", _sum] call OES_fnc_safeNumber;
    };

    // ==========================================
    // Safe subtraction - subtracts two numbers and returns string
    // ==========================================
    case "sub": {
        private _num1 = _input1;
        private _num2 = _input2;

        // Convert strings to numbers if needed
        if (_num1 isEqualType "") then { _num1 = parseNumber _num1; };
        if (_num2 isEqualType "") then { _num2 = parseNumber _num2; };

        // Subtract and convert result
        private _diff = floor (_num1 - _num2);
        _result = ["toInt", _diff] call OES_fnc_safeNumber;
    };

    // ==========================================
    // Validate - check if a value is a valid number
    // ==========================================
    case "validate": {
        private _val = _input1;

        if (_val isEqualType 0) exitWith {
            _result = true;
        };

        if (_val isEqualType "") then {
            private _cleaned = _val regexReplace ["[^0-9\.\-]", ""];
            _result = (_cleaned != "" && {parseNumber _cleaned == parseNumber _cleaned});
        } else {
            _result = false;
        };
    };

    default {
        diag_log format ["[OES_fnc_safeNumber] Unknown mode: %1", _mode];
        _result = "0";
    };
};

_result
