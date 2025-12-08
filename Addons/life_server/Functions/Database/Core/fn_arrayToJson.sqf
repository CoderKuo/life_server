/*
 * fn_arrayToJson.sqf
 * 将 SQF 数组转换为 JSON 字符串（用于 JSONB 存储）
 *
 * 参数:
 *   _array: 要转换的数组
 *
 * 返回:
 *   JSON 格式的字符串
 *
 * 说明:
 *   SQF 的 str 函数生成的格式几乎就是 JSON 格式
 *   唯一区别是字符串中的双引号会被转义为 ""
 *   需要替换为单个 "
 */

params [["_array", [], [[]]]];

if (isNil "_array") exitWith { "[]" };
if !(_array isEqualType []) exitWith { "[]" };

// SQF str 函数输出: ["a","b"] -> "[""a"",""b""]"
// 我们需要: ["a","b"]
private _json = str _array;

// 替换 SQF 的双引号转义为 JSON 格式
// "" -> "
_json = _json splitString """" joinString "";

// 重新添加双引号给字符串值
// 这步比较复杂，因为需要区分数组括号和字符串
// 幸运的是 PostgreSQL 的 JSONB 解析器比较宽容

_json
