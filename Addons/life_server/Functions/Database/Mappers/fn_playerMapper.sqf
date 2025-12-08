/*
 * fn_playerMapper.sqf
 * Player Data Access Layer - PostgreSQL Native (Pure JSONB)
 */

params [
    ["_method", "", [""]],
    ["_params", [], [[]]]
];

private _result = [];

switch (toLower _method) do {

    // ==========================================
    // SELECT Operations
    // ==========================================

    case "exists": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT playerid::text, name FROM players WHERE playerid='%1'";
        _result = [1, "player_exists", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getuid": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT uid FROM players WHERE playerid='%1'";
        _result = [1, "player_get_uid", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getsessioninfo": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT last_server, last_side, last_active::timestamp, NOW(), adminlevel, warkills, current_title, developer_level, hex_icon, hex_icon_redemptions, designer_level FROM players WHERE playerid='%1'";
        _result = [1, "player_session_info", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getfulldata": {
        _params params [
            ["_pid", "", [""]],
            ["_side", "civ", [""]],
            ["_gearCol", "civ_gear", [""]],
            ["_posCol", "coordinates", [""]]
        ];
        private _licensesCol = switch (toLower _side) do {
            case "cop": { "cop_licenses" };
            case "med": { "med_licenses" };
            default { "civ_licenses" };
        };

        private _sql = switch (toLower _side) do {
            case "cop": {
                format ["SELECT playerid::text, name, cash, bankacc, adminlevel, designer_level, developer_level, civcouncil_level, restrictions_level, newdonor, jsonb_to_sqf(%1), coplevel, jsonb_to_sqf(%2), jsonb_to_sqf(aliases), jsonb_to_sqf(player_stats), jsonb_to_sqf(wanted), blacklist, supportteam, vigiarrests, vigiarrests_stored, deposit_box FROM players WHERE playerid='%%1'", _licensesCol, _gearCol];
            };
            case "med": {
                format ["SELECT playerid::text, name, cash, bankacc, adminlevel, designer_level, developer_level, civcouncil_level, restrictions_level, newdonor, jsonb_to_sqf(%1), mediclevel, jsonb_to_sqf(%2), jsonb_to_sqf(aliases), jsonb_to_sqf(player_stats), jsonb_to_sqf(wanted), newslevel, supportteam, vigiarrests, vigiarrests_stored, deposit_box FROM players WHERE playerid='%%1'", _licensesCol, _gearCol];
            };
            default {
                format ["SELECT playerid::text, name, cash, bankacc, adminlevel, designer_level, developer_level, civcouncil_level, restrictions_level, newdonor, jsonb_to_sqf(civ_licenses), jsonb_to_sqf(arrested), jsonb_to_sqf(%1), jsonb_to_sqf(aliases), jsonb_to_sqf(player_stats), jsonb_to_sqf(wanted), jsonb_to_sqf(%2), supportteam, vigiarrests, vigiarrests_stored, deposit_box FROM players WHERE playerid='%%1'", _gearCol, _posCol];
            };
        };
        _result = [1, "player_full_data", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "countgangmembers": {
        _params params [
            ["_gangId", "", [""]],
            ["_gangName", "", [""]]
        ];
        private _sql = "SELECT COUNT(*) FROM gangmembers WHERE gangid='%1' AND gangname='%2'";
        _result = [1, "gang_count_members", _sql, [_gangId, _gangName]] call DB_fnc_dbExecute;
    };

    case "getcopdata": {
        _params params [
            ["_pid", "", [""]],
            ["_gearCol", "cop_gear", [""]]
        ];
        private _sql = format ["SELECT playerid::text, name, cash, bankacc, adminlevel, newdonor, jsonb_to_sqf(cop_licenses), coplevel, jsonb_to_sqf(%1), jsonb_to_sqf(aliases), jsonb_to_sqf(player_stats), jsonb_to_sqf(wanted), blacklist, supportteam FROM players WHERE playerid='%%1'", _gearCol];
        _result = [1, "player_cop_data", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getcopdataextended": {
        _params params [
            ["_pid", "", [""]],
            ["_gearCol", "cop_gear", [""]]
        ];
        private _sql = format ["SELECT playerid::text, name, cash, bankacc, adminlevel, designer_level, developer_level, restrictions_level, newdonor, jsonb_to_sqf(cop_licenses), coplevel, jsonb_to_sqf(%1), jsonb_to_sqf(aliases), jsonb_to_sqf(player_stats), jsonb_to_sqf(wanted), blacklist, supportteam FROM players WHERE playerid='%%1'", _gearCol];
        _result = [1, "player_cop_data_ext", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getcivdata": {
        _params params [
            ["_pid", "", [""]],
            ["_gearCol", "civ_gear", [""]],
            ["_coordCol", "coordinates", [""]]
        ];
        private _sql = format ["SELECT playerid::text, name, cash, bankacc, adminlevel, newdonor, jsonb_to_sqf(civ_licenses), jsonb_to_sqf(arrested), jsonb_to_sqf(%1), jsonb_to_sqf(aliases), jsonb_to_sqf(player_stats), jsonb_to_sqf(wanted), jsonb_to_sqf(%2), supportteam, vigiarrests FROM players WHERE playerid='%%1'", _gearCol, _coordCol];
        _result = [1, "player_civ_data", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getcivdataextended": {
        _params params [
            ["_pid", "", [""]],
            ["_gearCol", "civ_gear", [""]],
            ["_coordCol", "coordinates", [""]]
        ];
        private _sql = format ["SELECT playerid::text, name, cash, bankacc, adminlevel, designer_level, developer_level, restrictions_level, newdonor, jsonb_to_sqf(civ_licenses), jsonb_to_sqf(arrested), jsonb_to_sqf(%1), jsonb_to_sqf(aliases), jsonb_to_sqf(player_stats), jsonb_to_sqf(wanted), jsonb_to_sqf(%2), supportteam, vigiarrests FROM players WHERE playerid='%%1'", _gearCol, _coordCol];
        _result = [1, "player_civ_data_ext", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getmedicdata": {
        _params params [
            ["_pid", "", [""]],
            ["_gearCol", "med_gear", [""]]
        ];
        private _sql = format ["SELECT playerid::text, name, cash, bankacc, adminlevel, newdonor, jsonb_to_sqf(med_licenses), mediclevel, jsonb_to_sqf(%1), jsonb_to_sqf(aliases), jsonb_to_sqf(player_stats), jsonb_to_sqf(wanted), newslevel, supportteam FROM players WHERE playerid='%%1'", _gearCol];
        _result = [1, "player_medic_data", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getmedicdataextended": {
        _params params [
            ["_pid", "", [""]],
            ["_gearCol", "med_gear", [""]]
        ];
        private _sql = format ["SELECT playerid::text, name, cash, bankacc, adminlevel, designer_level, developer_level, restrictions_level, newdonor, jsonb_to_sqf(med_licenses), mediclevel, jsonb_to_sqf(%1), jsonb_to_sqf(aliases), jsonb_to_sqf(player_stats), jsonb_to_sqf(wanted), newslevel, supportteam FROM players WHERE playerid='%%1'", _gearCol];
        _result = [1, "player_medic_data_ext", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getstats": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT civ_kills, cop_kills, epipen, lockpick_suc, robberies, prison_time, sui_vest, plane_kills, (marijuana + heroinp + cocainep + crystalmeth + mmushroom + frogp + moonshine), (blastfed + blastjail + blastbw + blastbank), AA_hacked, cop_lethals, pardons, cop_arrests, tickets_issued_paid, defuses, donuts, drugs_seized_currency, vigiarrests, gokart_time, med_toolkits, AA_repaired, med_impounds, titan_hits, hits_claimed, hits_placed, bets_won, bets_lost, bets_won_value, bets_lost_value, vehicles_chopped, cops_robbed, jail_escapes, money_spent, events_won, kills_1km, conq_kills, conq_deaths, conq_captures, casino_winnings, casino_losses, casino_uses, lethal_injections FROM stats WHERE playerid='%1'";
        _result = [1, "player_stats", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getrealtorcash": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT realtor_cash FROM players WHERE playerid='%1'";
        _result = [1, "player_realtor_cash", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "gethousesalehistory": {
        _params params [["_pid", "", [""]]];
        // 获取售房历史 (JSONB数组)
        private _sql = "SELECT COALESCE(jsonb_to_sqf(house_sale_history), '[]') FROM players WHERE playerid='%1'";
        _result = [1, "player_house_sale_history", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // INSERT Operations
    // ==========================================

    case "insert": {
        _params params [
            ["_pid", "", [""]],
            ["_name", "", [""]],
            ["_cash", "0", [""]],
            ["_bank", "500000", [""]],
            ["_aliases", "[]", [""]]
        ];
        private _cashClean = parseNumber _cash;
        private _bankClean = parseNumber _bank;
        private _sql = "INSERT INTO players (playerid, name, cash, bankacc, aliases, cop_licenses, med_licenses, civ_licenses, civ_gear, cop_gear, med_gear, coordinates, player_stats, wanted, arrested) VALUES('%1', '%2', %3, %4, '%5'::jsonb, '[]'::jsonb, '[]'::jsonb, '[]'::jsonb, '[]'::jsonb, '[]'::jsonb, '[]'::jsonb, '[0,0,0]'::jsonb, '[0,0,0,0,0,0,0,0,0,0]'::jsonb, '[]'::jsonb, '[0,0,0]'::jsonb)";
        _result = [2, "player_insert", _sql, [_pid, _name, _cashClean, _bankClean, _aliases]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // UPDATE Operations
    // ==========================================

    case "updatebasic": {
        _params params [
            ["_pid", "", [""]],
            ["_name", "", [""]],
            ["_cash", "", [""]],
            ["_bank", "", [""]]
        ];
        private _cashClean = parseNumber _cash;
        private _bankClean = parseNumber _bank;
        private _sql = "UPDATE players SET name='%2', cash=%3, bankacc=%4 WHERE playerid='%1'";
        _result = [2, "player_update_basic", _sql, [_pid, _name, _cashClean, _bankClean]] call DB_fnc_dbExecute;
    };

    case "syncwithposition": {
        _params params [
            ["_pid", "", [""]],
            ["_name", "", [""]],
            ["_cash", "", [""]],
            ["_bank", "", [""]],
            ["_coordinates", "", [""]],
            ["_coordColumn", "coordinates", [""]]
        ];
        private _cashClean = parseNumber _cash;
        private _bankClean = parseNumber _bank;
        private _sql = format ["UPDATE players SET name='%%2', cash=%%3, bankacc=%%4, %1='%%5'::jsonb WHERE playerid='%%1'", _coordColumn];
        _result = [2, "player_sync_position", _sql, [_pid, _name, _cashClean, _bankClean, _coordinates]] call DB_fnc_dbExecute;
    };

    case "updatecash": {
        _params params [
            ["_pid", "", [""]],
            ["_cash", "", [""]]
        ];
        // 移除逗号和其他非数字字符，然后解析
        private _cashStr = _cash regexReplace ["[^0-9\-]", ""];
        private _cashClean = parseNumber _cashStr;
        // 调试日志
        diag_log format ["[PlayerMapper:updatecash] pid=%1, original=%2, cleaned=%3, parsed=%4", _pid, _cash, _cashStr, _cashClean];
        // 使用整数格式避免科学计数法
        private _sql = format ["UPDATE players SET cash=%1 WHERE playerid='%2'", floor _cashClean, _pid];
        _result = [2, "player_update_cash", _sql, []] call DB_fnc_dbExecute;
    };

    case "updatebank": {
        _params params [
            ["_pid", "", [""]],
            ["_bank", "", [""]]
        ];
        // 移除逗号和其他非数字字符，然后解析
        private _bankStr = _bank regexReplace ["[^0-9\-]", ""];
        private _bankClean = parseNumber _bankStr;
        // 调试日志
        diag_log format ["[PlayerMapper:updatebank] pid=%1, original=%2, cleaned=%3, parsed=%4", _pid, _bank, _bankStr, _bankClean];
        // 安全检查：阻止将银行余额设为0（除非明确允许）
        if (_bankClean <= 0) exitWith {
            diag_log format ["[PlayerMapper:updatebank] BLOCKED! Refusing to set bank to %1 for player %2", _bankClean, _pid];
            _result = false;
        };
        // 使用整数格式避免科学计数法
        private _sql = format ["UPDATE players SET bankacc=%1 WHERE playerid='%2'", floor _bankClean, _pid];
        _result = [2, "player_update_bank", _sql, []] call DB_fnc_dbExecute;
    };

    case "updatecashbank": {
        _params params [
            ["_pid", "", [""]],
            ["_cash", "", [""]],
            ["_bank", "", [""]]
        ];
        // 移除逗号和其他非数字字符，然后解析
        private _cashStr = _cash regexReplace ["[^0-9\-]", ""];
        private _bankStr = _bank regexReplace ["[^0-9\-]", ""];
        private _cashClean = parseNumber _cashStr;
        private _bankClean = parseNumber _bankStr;
        // 调试日志
        diag_log format ["[PlayerMapper:updatecashbank] pid=%1, cash=%2->%3, bank=%4->%5", _pid, _cash, _cashClean, _bank, _bankClean];
        // 使用整数格式避免科学计数法
        private _sql = format ["UPDATE players SET cash=%1, bankacc=%2 WHERE playerid='%3'", floor _cashClean, floor _bankClean, _pid];
        _result = [2, "player_update_cash_bank", _sql, []] call DB_fnc_dbExecute;
    };

    case "updatelicenses": {
        _params params [
            ["_pid", "", [""]],
            ["_licenses", "", [""]],
            ["_type", "civ", [""]]
        ];
        private _column = switch (toLower _type) do {
            case "cop": { "cop_licenses" };
            case "med": { "med_licenses" };
            default { "civ_licenses" };
        };
        private _sql = format ["UPDATE players SET %1='%%2'::jsonb WHERE playerid='%%1'", _column];
        _result = [2, "player_update_licenses", _sql, [_pid, _licenses]] call DB_fnc_dbExecute;
    };

    case "updategear": {
        _params params [
            ["_pid", "", [""]],
            ["_gear", "", [""]],
            ["_type", "civ", [""]]
        ];
        private _column = switch (toLower _type) do {
            case "cop": { "cop_gear" };
            case "med": { "med_gear" };
            default { "civ_gear" };
        };
        private _sql = format ["UPDATE players SET %1='%%2'::jsonb WHERE playerid='%%1'", _column];
        _result = [2, "player_update_gear", _sql, [_pid, _gear]] call DB_fnc_dbExecute;
    };

    case "updatewanted": {
        _params params [
            ["_pid", "", [""]],
            ["_wanted", "", [""]]
        ];
        private _sql = "UPDATE players SET wanted='%2'::jsonb WHERE playerid='%1'";
        _result = [2, "player_update_wanted", _sql, [_pid, _wanted]] call DB_fnc_dbExecute;
    };

    case "updatearrested": {
        _params params [
            ["_pid", "", [""]],
            ["_arrested", "", [""]]
        ];
        private _sql = "UPDATE players SET arrested='%2'::jsonb WHERE playerid='%1'";
        _result = [2, "player_update_arrested", _sql, [_pid, _arrested]] call DB_fnc_dbExecute;
    };

    case "updatestats": {
        _params params [
            ["_pid", "", [""]],
            ["_stats", "", [""]]
        ];
        private _sql = "UPDATE players SET player_stats='%2'::jsonb WHERE playerid='%1'";
        _result = [2, "player_update_stats", _sql, [_pid, _stats]] call DB_fnc_dbExecute;
    };

    case "updatealiases": {
        _params params [
            ["_pid", "", [""]],
            ["_aliases", "", [""]]
        ];
        private _sql = "UPDATE players SET aliases='%2'::jsonb WHERE playerid='%1'";
        _result = [2, "player_update_aliases", _sql, [_pid, _aliases]] call DB_fnc_dbExecute;
    };

    case "updatelastserver": {
        _params params [
            ["_pid", "", [""]],
            ["_server", "", [""]],
            ["_side", "", [""]]
        ];
        private _sql = "UPDATE players SET last_server='%2', last_side='%3' WHERE playerid='%1'";
        _result = [2, "player_update_last_server", _sql, [_pid, _server, _side]] call DB_fnc_dbExecute;
    };

    case "updatewarpts": {
        _params params [
            ["_pid", "", [""]],
            ["_amount", 0, [0]],
            ["_operation", "add", [""]]
        ];
        private _sql = switch (toLower _operation) do {
            case "add": { format ["UPDATE players SET warpts = warpts + %1 WHERE playerid='%%1'", _amount] };
            case "subtract": { format ["UPDATE players SET warpts = warpts - %1 WHERE playerid='%%1' AND warpts >= %1", _amount] };
            default { format ["UPDATE players SET warpts = %1 WHERE playerid='%%1'", _amount] };
        };
        _result = [2, "player_update_warpts", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "updaterealtorcash": {
        _params params [
            ["_pid", "", [""]],
            ["_amount", 0, [0]],
            ["_operation", "add", [""]]
        ];
        private _sql = switch (toLower _operation) do {
            case "add": { format ["UPDATE players SET realtor_cash = realtor_cash + %1 WHERE playerid='%%1'", _amount] };
            case "reset": { "UPDATE players SET realtor_cash = 0 WHERE playerid='%1'" };
            default { format ["UPDATE players SET realtor_cash = %1 WHERE playerid='%%1'", _amount] };
        };
        _result = [2, "player_update_realtor_cash", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "addhousesalehistory": {
        // 添加售房历史记录
        // 格式: [[houseType, price, buyerName, timestamp], ...]
        // 最多保留10条记录
        _params params [
            ["_pid", "", [""]],
            ["_houseType", "", [""]],
            ["_price", 0, [0]],
            ["_buyerName", "", [""]]
        ];
        // PostgreSQL: 使用 jsonb_insert 在数组开头添加新记录，然后截取前10条
        private _newRecord = format ["[\""%1\"", %2, \""%3\"", %4]", _houseType, _price, _buyerName, floor systemTime];
        private _sql = format [
            "UPDATE players SET house_sale_history = (SELECT jsonb_agg(elem) FROM (SELECT elem FROM jsonb_array_elements(COALESCE(house_sale_history, '[]'::jsonb)) AS elem LIMIT 9) sub) || '[%1]'::jsonb WHERE playerid='%%1'",
            _newRecord
        ];
        // 更简洁的方式: 直接在数组前面插入，然后保留最新10条
        _sql = format [
            "UPDATE players SET house_sale_history = (SELECT COALESCE(jsonb_agg(elem), '[]'::jsonb) FROM (SELECT elem FROM jsonb_array_elements('[%1]'::jsonb || COALESCE(house_sale_history, '[]'::jsonb)) WITH ORDINALITY AS t(elem, ord) ORDER BY ord LIMIT 10) sub) WHERE playerid='%%1'",
            _newRecord
        ];
        _result = [2, "player_add_house_sale_history", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "clearhousesalehistory": {
        _params params [["_pid", "", [""]]];
        private _sql = "UPDATE players SET house_sale_history = '[]'::jsonb WHERE playerid='%1'";
        _result = [2, "player_clear_house_sale_history", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "updatehexicon": {
        _params params [
            ["_pid", "", [""]],
            ["_icon", "", [""]]
        ];
        private _sql = "UPDATE players SET hex_icon='%2' WHERE playerid='%1'";
        _result = [2, "player_update_hex_icon", _sql, [_pid, _icon]] call DB_fnc_dbExecute;
    };

    case "decrementhexredemptions": {
        _params params [["_pid", "", [""]]];
        private _sql = "UPDATE players SET hex_icon_redemptions=hex_icon_redemptions-1 WHERE playerid='%1'";
        _result = [2, "player_decrement_hex", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // War Points Operations
    // ==========================================

    case "getwarpts": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT warpts FROM players WHERE playerid='%1'";
        _result = [1, "player_get_warpts", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "addwarpts": {
        _params params [
            ["_pid", "", [""]],
            ["_amount", "", [""]]
        ];
        private _sql = "UPDATE players SET warpts=warpts+%2 WHERE playerid='%1'";
        _result = [2, "player_add_warpts", _sql, [_pid, _amount]] call DB_fnc_dbExecute;
    };

    case "deductwarpts": {
        _params params [
            ["_pid", "", [""]],
            ["_amount", "", [""]]
        ];
        private _sql = "UPDATE players SET warpts=warpts-%2 WHERE playerid='%1'";
        _result = [2, "player_deduct_warpts", _sql, [_pid, _amount]] call DB_fnc_dbExecute;
    };

    case "deductwarptssafe": {
        _params params [
            ["_pid", "", [""]],
            ["_amount", "", [""]]
        ];
        private _sql = "UPDATE players SET warpts=GREATEST(warpts-%2, 0) WHERE playerid='%1'";
        _result = [2, "player_deduct_warpts_safe", _sql, [_pid, _amount]] call DB_fnc_dbExecute;
    };

    case "updatedepositbox": {
        _params params [
            ["_pid", "", [""]],
            ["_amount", 0, [0]]
        ];
        private _sql = "UPDATE players SET deposit_box=deposit_box+%2 WHERE playerid='%1'";
        _result = [2, "player_update_deposit_box", _sql, [_pid, _amount]] call DB_fnc_dbExecute;
    };

    case "incrementbank": {
        _params params [
            ["_pid", "", [""]],
            ["_amount", 0, [0]]
        ];
        private _sql = format ["UPDATE players SET bankacc=bankacc+%1 WHERE playerid='%%1'", _amount];
        _result = [2, "player_increment_bank", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Deposit Box Operations
    // ==========================================

    case "getdepositbox": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT deposit_box FROM players WHERE playerid='%1'";
        _result = [1, "player_get_deposit_box", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "resetdepositbox": {
        _params params [["_pid", "", [""]]];
        private _sql = "UPDATE players SET deposit_box=0 WHERE playerid='%1'";
        _result = [2, "player_reset_deposit_box", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Title Operations
    // ==========================================

    case "updatetitle": {
        _params params [
            ["_title", "", [""]],
            ["_pid", "", [""]]
        ];
        private _sql = "UPDATE players SET current_title = '%1' WHERE playerid='%2'";
        _result = [2, "player_update_title", _sql, [_title, _pid]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Vigilante Arrest Operations
    // ==========================================

    case "getvigiarrests": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT vigiarrests FROM players WHERE playerid='%1'";
        _result = [1, "player_get_vigi_arrests", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getvigiarrestsstored": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT vigiarrests_stored FROM players WHERE playerid='%1'";
        _result = [1, "player_get_vigi_arrests_stored", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "incrementvigiarrests": {
        _params params [["_pid", "", [""]]];
        private _sql = "UPDATE players SET vigiarrests = vigiarrests + 1 WHERE playerid='%1'";
        _result = [2, "player_increment_vigi_arrests", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "setvigiarrests": {
        _params params [
            ["_pid", "", [""]],
            ["_count", 0, [0]]
        ];
        private _sql = format ["UPDATE players SET vigiarrests = %1 WHERE playerid='%%1'", _count];
        _result = [2, "player_set_vigi_arrests", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "storevigiarrests": {
        _params params [
            ["_arrests", 0, [0]],
            ["_pid", "", [""]]
        ];
        private _sql = format ["UPDATE players SET vigiarrests_stored = %1, vigiarrests = 0 WHERE playerid='%%1'", _arrests];
        _result = [2, "player_store_vigi_arrests", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "redeemvigiarrests": {
        _params params [
            ["_stored", 0, [0]],
            ["_pid", "", [""]]
        ];
        private _sql = format ["UPDATE players SET vigiarrests=%1, vigiarrests_stored=0 WHERE playerid='%%1'", _stored];
        _result = [2, "player_redeem_vigi_arrests", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Prison Escapee Data
    // ==========================================

    case "getjaildata": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT uid, jsonb_to_sqf(arrested), jsonb_to_sqf(wanted) FROM players WHERE playerid='%1'";
        _result = [1, "player_get_jail_data", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "updatejaildata": {
        _params params [
            ["_arrested", "", [""]],
            ["_wanted", "", [""]],
            ["_coordinates", "", [""]],
            ["_pid", "", [""]],
            ["_uid", "", [""]]
        ];
        private _sql = "UPDATE players SET arrested='%1'::jsonb, wanted='%2'::jsonb, coordinates='%3'::jsonb WHERE playerid='%4' AND uid='%5'";
        _result = [2, "player_update_jail_data", _sql, [_arrested, _wanted, _coordinates, _pid, _uid]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Death/Position Operations
    // ==========================================

    case "updateoncivdeath": {
        _params params [
            ["_pid", "", [""]],
            ["_cash", "0", [""]],
            ["_gear", "", [""]],
            ["_position", "", [""]],
            ["_gearCol", "civ_gear", [""]],
            ["_posCol", "coordinates", [""]]
        ];
        private _cashClean = parseNumber _cash;
        private _sql = format ["UPDATE players SET cash=%%2, %1='%%3'::jsonb, %2='%%4'::jsonb WHERE playerid='%%1'", _gearCol, _posCol];
        _result = [2, "player_update_on_civ_death", _sql, [_pid, _cashClean, _gear, _position]] call DB_fnc_dbExecute;
    };

    case "updateposition": {
        _params params [
            ["_pid", "", [""]],
            ["_position", "", [""]],
            ["_posCol", "coordinates", [""]]
        ];
        private _sql = format ["UPDATE players SET %1='%%2'::jsonb WHERE playerid='%%1'", _posCol];
        _result = [2, "player_update_position", _sql, [_pid, _position]] call DB_fnc_dbExecute;
    };

    case "updatewarptssimple": {
        _params params [
            ["_pid", "", [""]],
            ["_amount", "0", [""]]
        ];
        private _sql = "UPDATE players SET warpts=%2 WHERE playerid='%1'";
        _result = [2, "player_update_warpts_simple", _sql, [_pid, _amount]] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[PlayerMapper] Unknown method: %1", _method];
        _result = [];
    };
};

_result
