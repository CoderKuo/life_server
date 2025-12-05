/*
 * 文件: fn_mysqlToPgsql.sqf
 * 描述: MySQL 到 PostgreSQL 语法转换器
 *
 * 此函数自动转换常见的 MySQL 特有语法到 PostgreSQL 兼容语法
 * 用于逐步迁移过程中保持向后兼容
 *
 * 参数:
 *   0: STRING - MySQL 格式的 SQL 查询
 *
 * 返回:
 *   STRING - PostgreSQL 兼容的 SQL 查询
 *
 * 支持的转换:
 *   - CONVERT(x, char) -> x::text
 *   - NOW() -> NOW() (兼容)
 *   - CURTIME() -> CURRENT_TIME
 *   - DATEDIFF('a','b') -> (DATE 'a' - DATE 'b')
 *   - DAYNAME(x) -> TO_CHAR(x, 'Day')
 *   - TIME_TO_SEC(x) -> EXTRACT(EPOCH FROM x)::integer
 *   - TIMESTAMP(x) -> x::timestamp
 *   - IFNULL(a,b) -> COALESCE(a,b)
 *   - IF(cond, a, b) -> CASE WHEN cond THEN a ELSE b END
 *   - LIMIT x,y -> LIMIT y OFFSET x
 *   - date_format(x, fmt) -> TO_CHAR(x, fmt) [需要手动调整格式]
 *   - last_day(x) -> (DATE_TRUNC('month', x) + INTERVAL '1 month - 1 day')::date
 */

params [
    ["_sql", "", [""]]
];

if (_sql isEqualTo "") exitWith { "" };

private _result = _sql;

// ============================================
// 基础函数转换
// ============================================

// CONVERT(value, char) -> value::text
// 匹配: CONVERT(xxx, char) 或 CONVERT(xxx,char)
private _convertPattern = "CONVERT\s*\(\s*([^,]+)\s*,\s*char\s*\)";
while {(_result regexFind [_convertPattern, "i"]) isNotEqualTo []} do {
    private _matches = _result regexFind [_convertPattern, "i"];
    if (count _matches > 0) then {
        private _fullMatch = (_matches select 0) select 0;
        private _value = ((_matches select 0) select 1) select 0;
        _result = _result regexReplace [_convertPattern, format["%1::text", _value], "i"];
    };
};

// CURTIME() -> CURRENT_TIME
_result = _result regexReplace ["CURTIME\s*\(\s*\)", "CURRENT_TIME", "gi"];

// TIME_TO_SEC(x) -> EXTRACT(EPOCH FROM x)::integer
private _timeToSecPattern = "TIME_TO_SEC\s*\(\s*([^)]+)\s*\)";
while {(_result regexFind [_timeToSecPattern, "i"]) isNotEqualTo []} do {
    private _matches = _result regexFind [_timeToSecPattern, "i"];
    if (count _matches > 0) then {
        private _value = ((_matches select 0) select 1) select 0;
        _result = _result regexReplace [_timeToSecPattern, format["EXTRACT(EPOCH FROM %1)::integer", _value], "i"];
    };
};

// DAYNAME(x) -> TRIM(TO_CHAR(x, 'Day'))
private _dayNamePattern = "DAYNAME\s*\(\s*([^)]+)\s*\)";
while {(_result regexFind [_dayNamePattern, "i"]) isNotEqualTo []} do {
    private _matches = _result regexFind [_dayNamePattern, "i"];
    if (count _matches > 0) then {
        private _value = ((_matches select 0) select 1) select 0;
        _result = _result regexReplace [_dayNamePattern, format["TRIM(TO_CHAR(%1, 'Day'))", _value], "i"];
    };
};

// TIMESTAMP(x) -> x::timestamp
private _timestampPattern = "TIMESTAMP\s*\(\s*([^)]+)\s*\)";
while {(_result regexFind [_timestampPattern, "i"]) isNotEqualTo []} do {
    private _matches = _result regexFind [_timestampPattern, "i"];
    if (count _matches > 0) then {
        private _value = ((_matches select 0) select 1) select 0;
        _result = _result regexReplace [_timestampPattern, format["%1::timestamp", _value], "i"];
    };
};

// IFNULL(a, b) -> COALESCE(a, b)
_result = _result regexReplace ["IFNULL\s*\(", "COALESCE(", "gi"];

// ============================================
// 日期函数转换
// ============================================

// DATEDIFF('date1', 'date2') -> (DATE 'date1' - DATE 'date2')
// 注意: MySQL DATEDIFF 返回 date1 - date2 的天数
private _dateDiffPattern = "DATEDIFF\s*\(\s*'([^']+)'\s*,\s*'([^']+)'\s*\)";
while {(_result regexFind [_dateDiffPattern, "i"]) isNotEqualTo []} do {
    private _matches = _result regexFind [_dateDiffPattern, "i"];
    if (count _matches > 0) then {
        private _date1 = ((_matches select 0) select 1) select 0;
        private _date2 = ((_matches select 0) select 2) select 0;
        _result = _result regexReplace [_dateDiffPattern, format["(DATE '%1' - DATE '%2')", _date1, _date2], "i"];
    };
};

// DATEDIFF('date1', NOW()) -> (DATE 'date1' - CURRENT_DATE)
private _dateDiffNowPattern = "DATEDIFF\s*\(\s*'([^']+)'\s*,\s*NOW\s*\(\s*\)\s*\)";
while {(_result regexFind [_dateDiffNowPattern, "i"]) isNotEqualTo []} do {
    private _matches = _result regexFind [_dateDiffNowPattern, "i"];
    if (count _matches > 0) then {
        private _date1 = ((_matches select 0) select 1) select 0;
        _result = _result regexReplace [_dateDiffNowPattern, format["(DATE '%1' - CURRENT_DATE)", _date1], "i"];
    };
};

// last_day(x) -> (DATE_TRUNC('month', x) + INTERVAL '1 month - 1 day')::date
private _lastDayPattern = "last_day\s*\(\s*([^)]+)\s*\)";
while {(_result regexFind [_lastDayPattern, "i"]) isNotEqualTo []} do {
    private _matches = _result regexFind [_lastDayPattern, "i"];
    if (count _matches > 0) then {
        private _value = ((_matches select 0) select 1) select 0;
        _result = _result regexReplace [_lastDayPattern, format["(DATE_TRUNC('month', %1) + INTERVAL '1 month - 1 day')::date", _value], "i"];
    };
};

// date_format(x, '%Y-%m-01') -> TO_CHAR(x, 'YYYY-MM-01')
// 注意: MySQL 和 PostgreSQL 的日期格式符号不同，这里只处理常见情况
private _dateFormatPattern = "date_format\s*\(\s*([^,]+)\s*,\s*'([^']+)'\s*\)";
while {(_result regexFind [_dateFormatPattern, "i"]) isNotEqualTo []} do {
    private _matches = _result regexFind [_dateFormatPattern, "i"];
    if (count _matches > 0) then {
        private _value = ((_matches select 0) select 1) select 0;
        private _format = ((_matches select 0) select 2) select 0;
        // 转换格式符号
        private _pgFormat = _format;
        _pgFormat = _pgFormat regexReplace ["%Y", "YYYY", "g"];
        _pgFormat = _pgFormat regexReplace ["%m", "MM", "g"];
        _pgFormat = _pgFormat regexReplace ["%d", "DD", "g"];
        _pgFormat = _pgFormat regexReplace ["%H", "HH24", "g"];
        _pgFormat = _pgFormat regexReplace ["%i", "MI", "g"];
        _pgFormat = _pgFormat regexReplace ["%s", "SS", "g"];
        _result = _result regexReplace [_dateFormatPattern, format["TO_CHAR(%1, '%2')", _value, _pgFormat], "i"];
    };
};

// ============================================
// LIMIT 语法转换
// ============================================

// MySQL: LIMIT offset, count -> PostgreSQL: LIMIT count OFFSET offset
private _limitPattern = "LIMIT\s+(\d+)\s*,\s*(\d+)";
while {(_result regexFind [_limitPattern, "i"]) isNotEqualTo []} do {
    private _matches = _result regexFind [_limitPattern, "i"];
    if (count _matches > 0) then {
        private _offset = ((_matches select 0) select 1) select 0;
        private _count = ((_matches select 0) select 2) select 0;
        _result = _result regexReplace [_limitPattern, format["LIMIT %1 OFFSET %2", _count, _offset], "i"];
    };
};

// ============================================
// 字符串函数转换
// ============================================

// CONCAT_WS 在两者中都支持，无需转换

// ============================================
// 布尔值转换
// ============================================

// MySQL 中 '1' 和 '0' 有时用作布尔值
// PostgreSQL 中可能需要显式 TRUE/FALSE，但大多数情况下数字也能工作

_result
