/*
 * fn_bankMapper.sqf
 * Bank/ATM Data Access Layer - Personal ATM transactions
 * Uses unified bank_history table
 */

params [
    ["_method", "", [""]],
    ["_params", [], [[]]]
];

private _result = [];

switch (toLower _method) do {

    // ==========================================
    // Personal ATM History Operations
    // ==========================================

    // Get player's ATM transaction history
    case "getatmhistory": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT type, amount, balance, target_name, EXTRACT(EPOCH FROM timestamp)::bigint FROM bank_history WHERE playerid='%1' AND gangid IS NULL ORDER BY timestamp DESC LIMIT 20";
        _result = [1, "atm_get_history", _sql, [_pid], true] call DB_fnc_dbExecute;
    };

    // Add ATM deposit record
    case "addatmdeposit": {
        _params params [["_name", "", [""]], ["_pid", "", [""]], ["_amount", 0, [0]], ["_balance", 0, [0]]];
        private _amountSafe = ["format", _amount] call OES_fnc_safeNumber;
        private _balanceSafe = ["format", _balance] call OES_fnc_safeNumber;
        private _sql = format ["INSERT INTO bank_history (name,playerid,type,amount,balance) VALUES('%%1','%%2',1,%1,%2)", _amountSafe, _balanceSafe];
        _result = [2, "atm_add_deposit", _sql, [_name, _pid]] call DB_fnc_dbExecute;
    };

    // Add ATM withdraw record
    case "addatmwithdraw": {
        _params params [["_name", "", [""]], ["_pid", "", [""]], ["_amount", 0, [0]], ["_balance", 0, [0]]];
        private _amountSafe = ["format", _amount] call OES_fnc_safeNumber;
        private _balanceSafe = ["format", _balance] call OES_fnc_safeNumber;
        private _sql = format ["INSERT INTO bank_history (name,playerid,type,amount,balance) VALUES('%%1','%%2',2,%1,%2)", _amountSafe, _balanceSafe];
        _result = [2, "atm_add_withdraw", _sql, [_name, _pid]] call DB_fnc_dbExecute;
    };

    // Add ATM transfer out record
    case "addatmtransferout": {
        _params params [["_name", "", [""]], ["_pid", "", [""]], ["_amount", 0, [0]], ["_balance", 0, [0]], ["_targetPid", "", [""]], ["_targetName", "", [""]]];
        private _amountSafe = ["format", _amount] call OES_fnc_safeNumber;
        private _balanceSafe = ["format", _balance] call OES_fnc_safeNumber;
        private _sql = format ["INSERT INTO bank_history (name,playerid,type,amount,balance,target_playerid,target_name) VALUES('%%1','%%2',3,%1,%2,'%%3','%%4')", _amountSafe, _balanceSafe];
        _result = [2, "atm_add_transfer_out", _sql, [_name, _pid, _targetPid, _targetName]] call DB_fnc_dbExecute;
    };

    // Add ATM transfer in record (receiving)
    case "addatmtransferin": {
        _params params [["_name", "", [""]], ["_pid", "", [""]], ["_amount", 0, [0]], ["_balance", 0, [0]], ["_senderPid", "", [""]], ["_senderName", "", [""]]];
        private _amountSafe = ["format", _amount] call OES_fnc_safeNumber;
        private _balanceSafe = ["format", _balance] call OES_fnc_safeNumber;
        private _sql = format ["INSERT INTO bank_history (name,playerid,type,amount,balance,target_playerid,target_name) VALUES('%%1','%%2',4,%1,%2,'%%3','%%4')", _amountSafe, _balanceSafe];
        _result = [2, "atm_add_transfer_in", _sql, [_name, _pid, _senderPid, _senderName]] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[BankMapper] Unknown method: %1", _method];
        _result = [];
    };
};

_result
