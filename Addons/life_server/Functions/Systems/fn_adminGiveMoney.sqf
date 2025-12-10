/*
 * fn_adminGiveMoney.sqf
 * 服务端管理员资金操作函数
 * 验证管理员权限并直接更新数据库
 * 支持操作: give(给钱), take(扣钱), set(设置)
 */

params [
    ["_operation", "give", [""]],
    ["_amount", 0, [0]],
    ["_targetPlayer", objNull, [objNull]],
    ["_adminUID", "", [""]],
    ["_clientAdminLevel", 0, [0]]
];

// 基本验证
if (_operation == "give" || _operation == "take") then {
    if (_amount <= 0) exitWith {
        diag_log format ["[AdminMoney] ERROR: Invalid amount %1 from %2", _amount, _adminUID];
    };
};
if (_operation == "set" && _amount < 0) exitWith {
    diag_log format ["[AdminMoney] ERROR: Cannot set negative amount %1 from %2", _amount, _adminUID];
};
if (_amount > 1000000000) exitWith {
    diag_log format ["[AdminMoney] ERROR: Amount too large %1 from %2", _amount, _adminUID];
};
if (isNull _targetPlayer) exitWith {
    diag_log format ["[AdminMoney] ERROR: Target player is null, from %1", _adminUID];
};
if (_adminUID == "") exitWith {
    diag_log format ["[AdminMoney] ERROR: Admin UID is empty"];
};

// 服务端验证管理员权限 - 从数据库查询真实的管理员等级
private _adminResult = ["getadminlevel", [_adminUID]] call DB_fnc_playerMapper;
private _serverAdminLevel = if (count _adminResult > 0) then { parseNumber (str (_adminResult select 0)) } else { 0 };

// 验证权限 - 必须是3级或以上管理员
if (_serverAdminLevel < 3) exitWith {
    diag_log format ["[AdminMoney] SECURITY: Unauthorized access attempt by %1 (claimed level %2, actual level %3)", _adminUID, _clientAdminLevel, _serverAdminLevel];

    // 记录安全事件
    private _ownerID = remoteExecutedOwner;
    format ["安全警告: 未授权的管理员资金操作尝试 (管理等级: %1)", _serverAdminLevel] remoteExec ["hint", _ownerID];
};

// 获取目标玩家的UID
private _targetUID = getPlayerUID _targetPlayer;
private _targetName = name _targetPlayer;

if (_targetUID == "") exitWith {
    diag_log format ["[AdminMoney] ERROR: Target UID is empty for player %1", _targetName];
};

// 获取目标玩家当前银行余额
private _bankResult = ["getbank", [_targetUID]] call DB_fnc_playerMapper;
// 使用安全数字函数解析，避免浮点数精度问题
private _currentBank = 0;
if (count _bankResult > 0) then {
    private _bankVal = _bankResult select 0;
    // 防御性检查：如果 OES_fnc_safeNumber 未加载，使用 parseNumber
    if (!isNil "OES_fnc_safeNumber") then {
        _currentBank = ["fromStr", _bankVal] call OES_fnc_safeNumber;
    } else {
        _currentBank = parseNumber (str _bankVal);
        diag_log "[AdminMoney] WARNING: OES_fnc_safeNumber not loaded, using parseNumber fallback";
    };
};

private _newBank = 0;
private _operationName = "";
private _logEvent = "";

switch (toLower _operation) do {
    case "give": {
        _newBank = _currentBank + _amount;
        _operationName = "给予";
        _logEvent = "admin_give_money";

        // 更新数据库 - 增加银行余额
        ["incrementbank", [_targetUID, _amount]] call DB_fnc_playerMapper;
    };

    case "take": {
        // 确保不会变成负数
        if (_amount > _currentBank) then {
            _newBank = 0;
            _amount = _currentBank; // 只能扣除现有的金额
        } else {
            _newBank = _currentBank - _amount;
        };
        _operationName = "扣除";
        _logEvent = "admin_take_money";

        // 更新数据库 - 减少银行余额
        ["incrementbank", [_targetUID, -_amount]] call DB_fnc_playerMapper;
    };

    case "set": {
        _newBank = _amount;
        _operationName = "设置";
        _logEvent = "admin_set_money";

        // 更新数据库 - 直接设置银行余额 (使用安全数字函数)
        private _amountSafe = ["format", _amount] call OES_fnc_safeNumber;
        ["updatebank", [_targetUID, _amountSafe]] call DB_fnc_playerMapper;
    };

    default {
        diag_log format ["[AdminMoney] ERROR: Unknown operation %1 from %2", _operation, _adminUID];
    };
};

// 通知目标玩家更新本地余额
private _targetOwnerID = owner _targetPlayer;
[_operation, _amount, _newBank] remoteExec ["OEC_fnc_adminMoneyReceived", _targetOwnerID];

// 记录日志 - 使用安全数字格式避免科学计数法
private _amountStr = if (!isNil "OES_fnc_safeNumber") then { ["format", _amount] call OES_fnc_safeNumber } else { str _amount };
private _newBankStr = if (!isNil "OES_fnc_safeNumber") then { ["format", _newBank] call OES_fnc_safeNumber } else { str _newBank };
diag_log format ["[AdminMoney] SUCCESS: Admin %1 (level %2) %3 $%4 %5 %6 (%7), new balance: $%8",
    _adminUID, _serverAdminLevel, _operationName, _amountStr,
    if (_operation == "set") then {"给"} else {if (_operation == "take") then {"从"} else {"给"}},
    _targetName, _targetUID, _newBankStr];

// 服务端高级日志
[_targetPlayer, _logEvent, format ["Admin %1 %2 $%3, new balance: $%4", _adminUID, _operationName, _amountStr, _newBankStr], 0, 1] call OES_fnc_AdvancedLog;
