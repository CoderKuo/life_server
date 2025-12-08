//	File: fn_mresToArray.sqf
//	Author: Bryan "Tonic" Boardwine";
//  Modified: PostgreSQL compatible - handles backticks and single quotes

//	Description:
//	Converts escaped array strings back to SQF arrays.
//	Handles multiple formats:
//	- Backticks (legacy): [[`name`]] -> [["name"]]
//	- Single quotes (PostgreSQL): [['name']] -> [["name"]]
//	- Two single quotes: '' -> " (escaped single quote becomes double quote)

private["_array"];
_array = param [0,"",[""]];
if(_array == "") exitWith {[]};

// Replace '' (two single quotes) with " (double quote)
// This handles PostgreSQL escaped quotes: [['name']] -> [["name"]]
// Also handles empty strings: [''] -> [""]
_array = _array splitString "''" joinString """";

// Convert to char array for legacy backtick handling
private _charArray = toArray _array;

for "_i" from 0 to (count _charArray)-1 do
{
	private _sel = _charArray select _i;
	// Convert backticks (96) to double quotes (34) - legacy format
	if(_sel == 96) then
	{
		_charArray set[_i,34];
	};
	// Convert remaining single quotes (39) to double quotes (34)
	if(_sel == 39) then
	{
		_charArray set[_i,34];
	};
};

_array = toString(_charArray);

// 尝试编译，如果失败返回空数组
private _result = [];
try {
	_result = call compile format["%1", _array];
} catch {
	diag_log format["[mresToArray] Failed to compile: %1", _array];
	_result = [];
};

if (isNil "_result") then { _result = []; };
if (!(_result isEqualType [])) then { _result = []; };

_result;