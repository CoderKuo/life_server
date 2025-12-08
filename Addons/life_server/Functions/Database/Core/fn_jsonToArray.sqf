/*
 * fn_jsonToArray.sqf
 * 将 JSON 字符串转换为 SQF 数组
 *
 * 参数:
 *   _json: JSON 格式的字符串
 *
 * 返回:
 *   SQF 数组
 *
 * 说明:
 *   使用 parseSimpleArray 解析 JSON 字符串
 *   该函数可以正确解析 JSON 数组格式
 */

params [["_json", "[]", [""]]];

if (isNil "_json") exitWith { [] };
if !(_json isEqualType "") exitWith { [] };
if (_json == "" || _json == "null") exitWith { [] };

// parseSimpleArray 可以直接解析 JSON 数组格式
private _array = parseSimpleArray _json;

if (isNil "_array") then {
    diag_log format ["[jsonToArray] Failed to parse: %1", _json];
    _array = [];
};

_array
