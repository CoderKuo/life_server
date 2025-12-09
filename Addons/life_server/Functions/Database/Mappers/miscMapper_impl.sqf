/*
 * miscMapper_impl.sqf
 * Misc Data Access Layer - Full Implementation
 * This file is loaded at runtime via compile preprocessFileLineNumbers
 */

params [["_method", "", [""]], ["_params", [], [[]]]];

private _result = [];

switch (toLower _method) do {

    // ==========================================
    // Market Operations
    // ==========================================

    case "getmarketprices": {
        _params params [["_id", "1", [""]]];
        private _sql = "SELECT market_array FROM market WHERE id='%1'";
        _result = [1, "market_get_prices", _sql, [_id]] call DB_fnc_dbExecute;
    };

    case "checkmarketreset": {
        _params params [["_id", "1", [""]]];
        private _sql = "SELECT reset FROM market WHERE id='%1'";
        _result = [1, "market_check_reset", _sql, [_id]] call DB_fnc_dbExecute;
    };

    case "updatemarketprices": {
        _params params [["_id", "1", [""]], ["_marketArray", "", [""]], ["_resetFlag", false, [false]]];
        private _sql = if (_resetFlag) then {
            "UPDATE market SET reset='0', market_array='%2' WHERE id='%1'"
        } else {
            "UPDATE market SET market_array='%2' WHERE id='%1'"
        };
        _result = [2, "market_update_prices", _sql, [_id, _marketArray]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Conquest Operations
    // ==========================================

    case "getmaxconquestid": {
        _params params [["_server", "", [""]]];
        private _sql = "SELECT MAX(id) FROM conquests WHERE server=%1";
        _result = [1, "conquest_get_max_id", _sql, [_server]] call DB_fnc_dbExecute;
    };

    case "recordconquest": {
        _params params [["_server", "", [""]], ["_pot", "", [""]], ["_totalPoints", "", [""]], ["_winnerId", "", [""]]];
        private _sql = "INSERT INTO conquests (server,pot,total_points,winner_id) VALUES (%1,%2,%3,%4)";
        _result = [2, "conquest_record", _sql, [_server, _pot, _totalPoints, _winnerId]] call DB_fnc_dbExecute;
    };

    case "recordconquestgangs": {
        _params params [["_values", "", [""]]];
        private _sql = "INSERT INTO conquest_gangs (conquest_id,gang_id,points,payout) VALUES %1";
        _result = [2, "conquest_record_gangs", _sql, [_values]] call DB_fnc_dbExecute;
    };

    case "cancelconquest": {
        _params params [["_id", "", [""]], ["_server", "", [""]]];
        private _sql = "UPDATE conquest_schedule SET cancelled=1 WHERE id=%1 AND server=%2";
        _result = [2, "conquest_cancel", _sql, [_id, _server]] call DB_fnc_dbExecute;
    };

    case "completeconquest": {
        _params params [["_id", "", [""]], ["_server", "", [""]]];
        private _sql = "UPDATE conquest_schedule SET completed=1 WHERE id=%1 AND server=%2";
        _result = [2, "conquest_complete", _sql, [_id, _server]] call DB_fnc_dbExecute;
    };

    case "getmonthlywinner": {
        private _sql = "SELECT winner_id FROM conquests WHERE date_started BETWEEN DATE_TRUNC('month', NOW() - INTERVAL '1 month')::date AND (DATE_TRUNC('month', NOW()) - INTERVAL '1 day')::date GROUP BY winner_id ORDER BY COUNT(winner_id) DESC LIMIT 1";
        _result = [1, "conquest_get_monthly_winner", _sql, []] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Message Operations
    // ==========================================

    case "getmessages": {
        _params params [["_toId", "", [""]]];
        private _sql = "SELECT fromID, toID, message, fromName, toName FROM messages WHERE toID='%1' ORDER BY time DESC LIMIT 10";
        _result = [1, "message_get", _sql, [_toId], true] call DB_fnc_dbExecute;
    };

    case "sendmessage": {
        _params params [["_fromId", "", [""]], ["_toId", "", [""]], ["_message", "", [""]], ["_fromName", "", [""]], ["_toName", "", [""]]];
        private _sql = "INSERT INTO messages (fromID, toID, message, fromName, toName) VALUES('%1', '%2', '""%3""', '%4', '%5')";
        _result = [2, "message_send", _sql, [_fromId, _toId, _message, _fromName, _toName]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Log Operations
    // ==========================================

    case "addplayerlog": {
        _params params [["_pid", "", [""]], ["_title", "", [""]], ["_log", "", [""]]];
        private _sql = "INSERT INTO playerlogs (playerID,logTitle,log) VALUES('%1','%2','%3')";
        _result = [2, "log_add_player", _sql, [_pid, _title, _log]] call DB_fnc_dbExecute;
    };

    case "addactionlog": {
        _params params [["_pid", "", [""]], ["_name", "", [""]], ["_action", "", [""]], ["_detail", "", [""]], ["_actionId", "0", [""]], ["_instanceId", "1", [""]]];
        private _sql = "INSERT INTO log(playerid, playername, action, action_detail, actionid, instanceid) VALUES('%1', '%2', '%3', '%4', %5, %6)";
        _result = [2, "log_add_action", _sql, [_pid, _name, _action, _detail, _actionId, _instanceId]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Voting Operations
    // ==========================================

    case "countvotes": {
        private _sql = "SELECT COUNT(*) FROM votes";
        _result = [1, "vote_count", _sql, []] call DB_fnc_dbExecute;
    };

    case "getvotes": {
        _params params [["_offset", 0, [0]]];
        private _sql = "SELECT votes.voteID, votes.voterID, votes.candidateID FROM votes LIMIT 10 OFFSET %1";
        _result = [1, "vote_get", _sql, [_offset], true] call DB_fnc_dbExecute;
    };

    case "voteget": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT voterID, candidateID FROM votes WHERE voterID='%1'";
        _result = [1, "vote_get_by_player", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "voteinsert": {
        _params params [["_voterId", "", [""]], ["_candidateId", "", [""]]];
        private _sql = "INSERT INTO votes (voterID,candidateID) VALUES ('%1','%2')";
        _result = [2, "vote_insert", _sql, [_voterId, _candidateId]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Server Time Operations
    // ==========================================

    case "getservertime": {
        _params params [["_offset", "", [""]], ["_mod", "", [""]]];
        private _sql = format ["SELECT 240-FLOOR(EXTRACT(EPOCH FROM (NOW() AT TIME ZONE 'UTC' AT TIME ZONE 'US/Eastern')::time)/60 + %1) %% 240 as time_remaining", _offset];
        _result = [1, "server_get_time", _sql, []] call DB_fnc_dbExecute;
    };

    case "checkhardreset": {
        _params params [["_offset", "", [""]], ["_hour", "", [""]]];
        // 返回 1 或 0 而不是布尔值，避免 parseSimpleArray 解析错误
        private _sql = format ["SELECT CASE WHEN EXTRACT(HOUR FROM ((NOW() + INTERVAL '%1 minutes') AT TIME ZONE 'UTC' AT TIME ZONE 'US/Eastern'))=%2 THEN 1 ELSE 0 END as is_hard", _offset, _hour];
        _result = [1, "server_check_hard_reset", _sql, []] call DB_fnc_dbExecute;
    };

    case "checktimerange": {
        _params params [["_start", "", [""]], ["_end", "", [""]]];
        // 返回 1 或 0 而不是布尔值，避免 parseSimpleArray 解析错误
        private _sql = format ["SELECT CASE WHEN (NOW() AT TIME ZONE 'UTC' AT TIME ZONE 'US/Eastern')::time BETWEEN '%1:30:00' AND '%2:30:00' THEN 1 ELSE 0 END as in_range", _start, _end];
        _result = [1, "server_check_time_range", _sql, []] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Hex Icon Operations
    // ==========================================

    case "createhexicon": {
        _params params [["_pid", "", [""]]];
        private _sql = "INSERT INTO hex_icons (pid) VALUES ('%1')";
        _result = [2, "hex_create", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "updatehexicon": {
        _params params [["_column", "", [""]], ["_pid", "", [""]]];
        private _sql = format ["UPDATE hex_icons SET ""%1""=1 WHERE pid='%%1'", _column];
        _result = [2, "hex_update", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "hexget": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT * FROM hex_icons WHERE pid='%1'";
        _result = [1, "hex_get", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Date Difference Calculation
    // ==========================================

    case "getdatediff": {
        _params params [["_date", "", [""]]];
        private _sql = "SELECT ('%1'::date - CURRENT_DATE)";
        _result = [1, "date_diff", _sql, [_date]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Stored Procedure Calls
    // ==========================================

    case "callupdatemembernames": {
        private _sql = "CALL updateMemberNames()";
        _result = [2, "sp_update_member_names", _sql, []] call DB_fnc_dbExecute;
    };

    case "calldeletecontracts": {
        private _sql = "CALL deleteContracts()";
        _result = [2, "sp_delete_contracts", _sql, []] call DB_fnc_dbExecute;
    };

    case "callselectmax": {
        private _sql = "SELECT * FROM selectMax()";
        _result = [1, "sp_select_max", _sql, []] call DB_fnc_dbExecute;
    };

    case "callhousecleanup": {
        private _sql = "CALL houseCleanup1()";
        _result = [2, "sp_house_cleanup", _sql, []] call DB_fnc_dbExecute;
    };

    case "callgivecash": {
        private _sql = "CALL giveCash()";
        _result = [2, "sp_give_cash", _sql, []] call DB_fnc_dbExecute;
    };

    case "callresetlifevehicles": {
        private _sql = "CALL resetLifeVehicles1()";
        _result = [2, "sp_reset_life_vehicles", _sql, []] call DB_fnc_dbExecute;
    };

    case "callgangbuildingcleanup": {
        private _sql = "CALL gangBuildingCleanup()";
        _result = [2, "sp_gang_building_cleanup", _sql, []] call DB_fnc_dbExecute;
    };

    case "calldeleteoldhouses": {
        private _sql = "CALL deleteOldHouses1()";
        _result = [2, "sp_delete_old_houses", _sql, []] call DB_fnc_dbExecute;
    };

    case "calldeletedeadvehicles": {
        private _sql = "CALL deleteDeadVehicles()";
        _result = [2, "sp_delete_dead_vehicles", _sql, []] call DB_fnc_dbExecute;
    };

    case "calldeleteoldgangs": {
        private _sql = "CALL deleteOldGangs()";
        _result = [2, "sp_delete_old_gangs", _sql, []] call DB_fnc_dbExecute;
    };

    case "callsetzonekill": {
        _params params [["_p1", "", [""]], ["_p2", "", [""]]];
        private _sql = "CALL setZoneKill(%1,%2)";
        _result = [2, "sp_set_zone_kill", _sql, [_p1, _p2]] call DB_fnc_dbExecute;
    };

    case "callinsertstatm": {
        _params params [["_values", "", [""]]];
        private _sql = format ["CALL insertStatM(%1)", _values];
        _result = [2, "sp_insert_stat_m", _sql, []] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Hitman System
    // ==========================================

    case "hitmaninsert": {
        _params params [["_targetPid", "", [""]], ["_bounty", "", [""]], ["_targetTime", "", [""]], ["_issuerPid", "", [""]]];
        private _sql = "INSERT INTO hitman (targetPID, bounty, targetTime, issuerPID, active) VALUES('%1','%2','%3','%4','1')";
        _result = [2, "hitman_insert", _sql, [_targetPid, _bounty, _targetTime, _issuerPid]] call DB_fnc_dbExecute;
    };

    case "hitmanget": {
        _params params [["_targetPid", "", [""]]];
        private _sql = "SELECT bounty, targetTime FROM hitman WHERE targetPID='%1' AND active='1'";
        _result = [1, "hitman_get", _sql, [_targetPid]] call DB_fnc_dbExecute;
    };

    case "hitmandeactivate": {
        _params params [["_targetPid", "", [""]]];
        private _sql = "UPDATE hitman SET active ='0' WHERE targetPID='%1' AND active='1'";
        _result = [2, "hitman_deactivate", _sql, [_targetPid]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Loadout System
    // ==========================================

    case "loadoutsave": {
        _params params [["_pid", "", [""]], ["_physicalItems", "", [""]], ["_virtualItems", "", [""]], ["_shop", "", [""]], ["_slot", "", [""]]];
        private _sql = "INSERT INTO loadoutsNew (pid, physical_items, virtual_items, shop, loadout) VALUES('%1','%2','%3','%4','%5') ON CONFLICT (pid, shop, loadout) DO UPDATE SET physical_items = EXCLUDED.physical_items, virtual_items = EXCLUDED.virtual_items";
        _result = [2, "loadout_save", _sql, [_pid, _physicalItems, _virtualItems, _shop, _slot]] call DB_fnc_dbExecute;
    };

    case "loadoutget": {
        _params params [["_pid", "", [""]], ["_slot", "", [""]], ["_shop", "", [""]]];
        private _sql = "SELECT physical_items, virtual_items FROM loadoutsNew WHERE pid='%1' AND loadout='%2' AND shop='%3'";
        _result = [1, "loadout_get", _sql, [_pid, _slot, _shop]] call DB_fnc_dbExecute;
    };

    case "loadoutcheck": {
        _params params [["_pid", "", [""]], ["_slot", "", [""]], ["_shop", "", [""]]];
        private _sql = "SELECT pid, physical_items, virtual_items FROM loadoutsNew WHERE pid='%1' AND loadout='%2' AND shop='%3' AND physical_items!='[]' AND virtual_items!='[]'";
        _result = [1, "loadout_check", _sql, [_pid, _slot, _shop]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // MPID Log Operations
    // ==========================================

    case "mpidsearch": {
        _params params [["_searchConditions", "", [""]]];
        private _sql = format ["SELECT id,pids FROM mpid WHERE %1", _searchConditions];
        _result = [1, "mpid_search", _sql, []] call DB_fnc_dbExecute;
    };

    case "mpidinsert": {
        _params params [["_pids", "", [""]]];
        private _sql = "INSERT INTO mpid (pids) VALUES ('%1')";
        _result = [2, "mpid_insert", _sql, [_pids]] call DB_fnc_dbExecute;
    };

    case "mpidupdate": {
        _params params [["_pids", "", [""]], ["_id", "", [""]]];
        private _sql = "UPDATE mpid SET pids='%1' WHERE id=%2";
        _result = [2, "mpid_update", _sql, [_pids, _id]] call DB_fnc_dbExecute;
    };

    case "mpiddelete": {
        _params params [["_ids", "", [""]]];
        private _sql = format ["DELETE FROM mpid WHERE id IN (%1)", _ids];
        _result = [2, "mpid_delete", _sql, []] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Lottery Operations
    // ==========================================

    case "lottery_get_config": {
        _params params [["_key", "", [""]]];
        private _sql = "SELECT config_value FROM lottery_config WHERE config_key='%1'";
        _result = [1, "lottery_get_config", _sql, [_key]] call DB_fnc_dbExecute;
    };

    case "lottery_set_config": {
        _params params [["_key", "", [""]], ["_value", "", [""]]];
        private _sql = "INSERT INTO lottery_config (config_key, config_value) VALUES ('%1', '%2') ON CONFLICT (config_key) DO UPDATE SET config_value = '%2'";
        _result = [2, "lottery_set_config", _sql, [_key, _value]] call DB_fnc_dbExecute;
    };

    case "lottery_add_history": {
        _params params [["_round", "", [""]], ["_type", "", [""]], ["_pool", "", [""]], ["_tickets", "", [""]], ["_players", "", [""]], ["_jackpot", "", [""]], ["_winners", "", [""]]];
        private _sql = "INSERT INTO lottery_history (round_number, lottery_type, total_pool, ticket_count, player_count, jackpot_amount, winners) VALUES (%1, '%2', %3, %4, %5, %6, '%7')";
        _result = [2, "lottery_add_history", _sql, [_round, _type, _pool, _tickets, _players, _jackpot, _winners]] call DB_fnc_dbExecute;
    };

    case "lottery_get_history": {
        _params params [["_type", "", [""]]];
        private _sql = "SELECT round_number, lottery_type, total_pool, ticket_count, player_count, winners, created_at FROM lottery_history WHERE lottery_type = '%1' ORDER BY id DESC LIMIT 10";
        _result = [1, "lottery_get_history", _sql, [_type], true] call DB_fnc_dbExecute;
    };

    case "lottery_update_player_bought": {
        _params params [["_uid", "", [""]], ["_name", "", [""]], ["_amount", "", [""]], ["_spent", "", [""]]];
        private _sql = "INSERT INTO lottery_player_stats (playerid, name, total_bought, total_spent, last_updated) VALUES ('%1', '%2', %3, %4, NOW()) ON CONFLICT (playerid) DO UPDATE SET name = '%2', total_bought = lottery_player_stats.total_bought + %3, total_spent = lottery_player_stats.total_spent + %4, last_updated = NOW()";
        _result = [2, "lottery_update_player_bought", _sql, [_uid, _name, _amount, _spent]] call DB_fnc_dbExecute;
    };

    case "lottery_update_player_won": {
        _params params [["_uid", "", [""]], ["_name", "", [""]], ["_prize", "", [""]], ["_historyJson", "", [""]]];
        private _sql = "INSERT INTO lottery_player_stats (playerid, name, total_won, total_winnings, win_history, last_updated) VALUES ('%1', '%2', 1, %3, '%4', NOW()) ON CONFLICT (playerid) DO UPDATE SET name = '%2', total_won = lottery_player_stats.total_won + 1, total_winnings = lottery_player_stats.total_winnings + %3, win_history = lottery_player_stats.win_history || '%4', last_updated = NOW()";
        _result = [2, "lottery_update_player_won", _sql, [_uid, _name, _prize, _historyJson]] call DB_fnc_dbExecute;
    };

    case "lottery_get_player_stats": {
        _params params [["_uid", "", [""]]];
        private _sql = "SELECT total_bought, total_spent, total_won, total_winnings, win_history FROM lottery_player_stats WHERE playerid = '%1'";
        _result = [1, "lottery_get_player_stats", _sql, [_uid]] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[MiscMapper] Unknown method: %1", _method];
        _result = [];
    };
};

_result
