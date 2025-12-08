/*
 * gangMapper_impl.sqf
 * Gang Data Access Layer - Full Implementation
 * This file is loaded at runtime via compile preprocessFileLineNumbers
 */

params [["_method", "", [""]], ["_params", [], [[]]]];

private _result = [];

switch (toLower _method) do {

    // ==========================================
    // Gang Operations
    // ==========================================

    case "gangexists": {
        _params params [["_name", "", [""]]];
        private _sql = "SELECT id FROM gangs WHERE name='%1' AND active='1'";
        _result = [1, "gang_exists", _sql, [_name]] call DB_fnc_dbExecute;
    };

    case "gangexistsinactive": {
        _params params [["_name", "", [""]]];
        private _sql = "SELECT id, active FROM gangs WHERE name='%1' AND active='0'";
        _result = [1, "gang_exists_inactive", _sql, [_name]] call DB_fnc_dbExecute;
    };

    case "getgangbank": {
        _params params [["_gangId", "", [""]]];
        private _sql = "SELECT bank FROM gangs WHERE id='%1'";
        _result = [1, "gang_get_bank", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    case "getgangname": {
        _params params [["_gangId", "", [""]]];
        private _sql = "SELECT name FROM gangs WHERE id=%1";
        _result = [1, "gang_get_name", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    case "creategang": {
        _params params [["_name", "", [""]]];
        private _sql = "INSERT INTO gangs (name) VALUES('%1')";
        _result = [1, "gang_create", _sql, [_name]] call DB_fnc_dbExecute;
    };

    case "activategang": {
        _params params [["_gangId", "", [""]]];
        private _sql = "UPDATE gangs SET active='1' WHERE id='%1'";
        _result = [2, "gang_activate", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    case "deactivategang": {
        _params params [["_gangId", "", [""]]];
        private _sql = "UPDATE gangs SET active='0' WHERE id='%1'";
        _result = [2, "gang_deactivate", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    case "updategangbank": {
        _params params [["_gangId", "", [""]], ["_amount", "", [""]]];
        // 移除逗号和其他非数字字符，然后解析，避免科学计数法
        private _amountStr = _amount regexReplace ["[^0-9\-]", ""];
        private _amountClean = parseNumber _amountStr;
        diag_log format ["[GangMapper:updategangbank] gangId=%1, original=%2, cleaned=%3", _gangId, _amount, _amountClean];
        // 使用整数格式避免科学计数法
        private _sql = format ["UPDATE gangs SET bank=%1 WHERE id='%2'", floor _amountClean, _gangId];
        _result = [2, "gang_update_bank", _sql, []] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Member Operations
    // ==========================================

    case "getmember": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT id FROM gangmembers WHERE playerid='%1'";
        _result = [1, "gang_get_member", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getmembers": {
        _params params [["_gangId", "", [""]]];
        private _sql = "SELECT playerid::text, name, rank FROM gangmembers WHERE gangid='%1' ORDER BY rank DESC";
        _result = [1, "gang_get_members", _sql, [_gangId], true] call DB_fnc_dbExecute;
    };

    case "countmembers": {
        _params params [["_gangId", "", [""]], ["_gangName", "", [""]]];
        private _sql = "SELECT COUNT(*) FROM gangmembers WHERE gangid='%1' AND gangname='%2'";
        _result = [1, "gang_count_members", _sql, [_gangId, _gangName]] call DB_fnc_dbExecute;
    };

    case "getplayergang": {
        _params params [["_pid", "", [""]]];
        private _sql = "SELECT gangid, gangname, rank FROM gangmembers WHERE playerid='%1'";
        _result = [1, "gang_get_player_gang", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "addmember": {
        _params params [["_pid", "", [""]], ["_name", "", [""]], ["_gangName", "", [""]], ["_gangId", "", [""]], ["_rank", "", [""]]];
        private _sql = "INSERT INTO gangmembers (playerid,name,gangname,gangid,rank) VALUES('%1','%2','%3','%4','%5')";
        _result = [2, "gang_add_member", _sql, [_pid, _name, _gangName, _gangId, _rank]] call DB_fnc_dbExecute;
    };

    case "updatemember": {
        _params params [["_pid", "", [""]], ["_gangName", "", [""]], ["_gangId", "", [""]], ["_rank", "", [""]]];
        private _sql = "UPDATE gangmembers SET gangname='%2', gangid='%3', rank='%4' WHERE playerid='%1'";
        _result = [2, "gang_update_member", _sql, [_pid, _gangName, _gangId, _rank]] call DB_fnc_dbExecute;
    };

    case "removemember": {
        _params params [["_pid", "", [""]]];
        private _sql = "UPDATE gangmembers SET gangname='', gangid='-1', rank='-1' WHERE playerid='%1'";
        _result = [2, "gang_remove_member", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "updatemembername": {
        _params params [["_pid", "", [""]], ["_name", "", [""]]];
        private _sql = "UPDATE gangmembers SET name='%2' WHERE playerid='%1'";
        _result = [2, "gang_update_member_name", _sql, [_pid, _name]] call DB_fnc_dbExecute;
    };

    case "updatememberfull": {
        _params params [["_memberId", "", [""]], ["_name", "", [""]], ["_gangName", "", [""]], ["_gangId", "", [""]], ["_rank", "", [""]]];
        private _sql = "UPDATE gangmembers SET name='%2', gangname='%3', gangid='%4', rank='%5' WHERE id='%1'";
        _result = [2, "gang_update_member_full", _sql, [_memberId, _name, _gangName, _gangId, _rank]] call DB_fnc_dbExecute;
    };

    case "removeallmembers": {
        _params params [["_gangId", "", [""]]];
        private _sql = "UPDATE gangmembers SET gangname='', gangid='-1', rank='-1' WHERE gangid='%1'";
        _result = [2, "gang_remove_all_members", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Building Operations
    // ==========================================

    case "getbuildingpositions": {
        _params params [["_gangId", "", [""]], ["_server", "", [""]]];
        private _sql = "SELECT pos FROM gangbldgs WHERE gang_id='%1' AND server='%2' AND owned='1'";
        _result = [1, "gang_get_building_positions", _sql, [_gangId, _server], true] call DB_fnc_dbExecute;
    };

    case "getbuildingid": {
        _params params [["_gangId", "", [""]], ["_gangName", "", [""]], ["_server", "", [""]]];
        private _sql = "SELECT id FROM gangbldgs WHERE gang_id='%1' AND gang_name='%2' AND owned='1' AND server='%3'";
        _result = [1, "gang_get_building_id", _sql, [_gangId, _gangName, _server]] call DB_fnc_dbExecute;
    };

    case "buildingexists": {
        _params params [["_pos", "", [""]], ["_server", "", [""]]];
        private _sql = "SELECT id FROM gangbldgs WHERE pos='%1' AND server='%2' AND owned='1'";
        _result = [1, "gang_building_exists", _sql, [_pos, _server]] call DB_fnc_dbExecute;
    };

    case "getallbuildings": {
        _params params [["_server", "", [""]], ["_offset", 0, [0]]];
        private _sql = "SELECT id, owner, classname, pos, jsonb_to_sqf(inventory), storage_cap, gang_id, gang_name, crate_count, lastpayment, nextpayment, paystatus, oil, jsonb_to_sqf(physical_inventory), physical_storage_cap FROM gangbldgs WHERE owned='1' AND server='%1' LIMIT 10 OFFSET %2";
        _result = [1, "gang_get_all_buildings", _sql, [_server, _offset], true] call DB_fnc_dbExecute;
    };

    case "getdaysuntilrent": {
        _params params [["_lastPayment", "", [""]], ["_payCount", 0, [0]]];
        private _sql = format ["SELECT (('%1'::date + %2 * INTERVAL '31 days')::date - CURRENT_DATE)", _lastPayment, _payCount];
        _result = [1, "gang_get_days_until_rent", _sql, []] call DB_fnc_dbExecute;
    };

    case "createbuilding": {
        _params params [["_owner", "", [""]], ["_classname", "", [""]], ["_pos", "", [""]], ["_gangId", "", [""]], ["_gangName", "", [""]], ["_server", "", [""]]];
        private _sql = "INSERT INTO gangbldgs (owner, classname, pos, inventory, owned, gang_id, gang_name, server, crate_count, lastpayment, nextpayment, physical_inventory) VALUES('%1', '%2', '%3', '[[],0]'::jsonb, '1', '%4', '%5', '%6', '2', NOW(), NOW() + INTERVAL '31 days', '[[],0]'::jsonb)";
        _result = [2, "gang_create_building", _sql, [_owner, _classname, _pos, _gangId, _gangName, _server]] call DB_fnc_dbExecute;
    };

    case "updatebuildingpayment": {
        _params params [["_gangId", "", [""]], ["_gangName", "", [""]], ["_server", "", [""]]];
        private _sql = "UPDATE gangbldgs SET lastpayment=NOW(), paystatus=paystatus+1 WHERE gang_id='%1' AND gang_name='%2' AND server='%3' AND owned='1' AND paystatus<2";
        _result = [2, "gang_update_building_payment", _sql, [_gangId, _gangName, _server]] call DB_fnc_dbExecute;
    };

    case "updatebuildingstorage": {
        _params params [["_gangId", "", [""]], ["_gangName", "", [""]], ["_server", "", [""]], ["_capacity", "", [""]], ["_type", "virtual", [""]]];
        private _column = if (_type == "physical") then { "physical_storage_cap" } else { "storage_cap" };
        private _sql = format ["UPDATE gangbldgs SET %1='%%4' WHERE gang_id='%%1' AND gang_name='%%2' AND server='%%3' AND owned='1'", _column];
        _result = [2, "gang_update_building_storage", _sql, [_gangId, _gangName, _server, _capacity]] call DB_fnc_dbExecute;
    };

    case "updatebuildinginventory": {
        _params params [["_gangId", "", [""]], ["_gangName", "", [""]], ["_server", "", [""]], ["_inventory", "", [""]], ["_physInventory", "", [""]]];
        private _sql = "UPDATE gangbldgs SET inventory='%4'::jsonb, physical_inventory='%5'::jsonb WHERE gang_name='%2' AND gang_id='%1' AND server='%3' AND owned='1'";
        _result = [2, "gang_update_building_inventory", _sql, [_gangId, _gangName, _server, _inventory, _physInventory]] call DB_fnc_dbExecute;
    };

    case "upgradebuildingoil": {
        _params params [["_gangId", "", [""]], ["_gangName", "", [""]], ["_server", "", [""]]];
        private _sql = "UPDATE gangbldgs SET oil='1' WHERE gang_id='%1' AND gang_name='%2' AND server='%3' AND owned='1'";
        _result = [2, "gang_upgrade_building_oil", _sql, [_gangId, _gangName, _server]] call DB_fnc_dbExecute;
    };

    case "sellbuilding": {
        _params params [["_gangId", "", [""]], ["_gangName", "", [""]], ["_server", "", [""]]];
        private _sql = "UPDATE gangbldgs SET owned='0', pos='[]' WHERE gang_id='%1' AND gang_name='%2' AND server='%3'";
        _result = [2, "gang_sell_building", _sql, [_gangId, _gangName, _server]] call DB_fnc_dbExecute;
    };

    case "countbuildings": {
        _params params [["_server", "", [""]]];
        private _sql = "SELECT COUNT(*) FROM gangbldgs WHERE server='%1' AND owned='1'";
        _result = [1, "gang_count_buildings", _sql, [_server]] call DB_fnc_dbExecute;
    };

    case "getbuildingdetails": {
        _params params [["_gangId", "", [""]], ["_gangName", "", [""]], ["_server", "", [""]]];
        private _sql = "SELECT id, owner, pos, classname, gang_name FROM gangbldgs WHERE gang_id='%1' AND gang_name='%2' AND server='%3' AND owned='1'";
        _result = [1, "gang_get_building_details", _sql, [_gangId, _gangName, _server]] call DB_fnc_dbExecute;
    };

    case "getbuildingbypos": {
        _params params [["_server", "", [""]], ["_owner", "", [""]], ["_pos", "", [""]]];
        private _sql = "SELECT id FROM gangbldgs WHERE server='%1' AND owner='%2' AND pos='%3' AND owned='1'";
        _result = [1, "gang_get_building_by_pos", _sql, [_server, _owner, _pos]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // War Operations
    // ==========================================

    case "getwarstatus": {
        _params params [["_gangId1", "", [""]], ["_gangId2", "", [""]]];
        private _sql = "SELECT init_gangid, ikills, ideaths, acpt_gangid, akills, adeaths, (CURRENT_DATE - date::date) FROM gangwars WHERE active='1' AND (init_gangid='%1' OR acpt_gangid='%1') AND (init_gangid='%2' OR acpt_gangid='%2')";
        _result = [1, "gang_get_war_status", _sql, [_gangId1, _gangId2]] call DB_fnc_dbExecute;
    };

    case "getwarenemy": {
        _params params [["_gangId", "", [""]]];
        private _sql = "SELECT init_gangid, init_gangname, acpt_gangid, acpt_gangname FROM gangwars WHERE active='1' AND (init_gangid='%1' OR acpt_gangid='%1')";
        _result = [1, "gang_get_war_enemy", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    case "declarewar": {
        _params params [["_instigator", "", [""]], ["_initGangId", "", [""]], ["_initGangName", "", [""]], ["_acceptor", "", [""]], ["_acptGangId", "", [""]], ["_acptGangName", "", [""]]];
        private _sql = "INSERT INTO gangwars (instigator,init_gangid,init_gangname,acceptor,acpt_gangid,acpt_gangname,active) VALUES ('%1','%2','%3','%4','%5','%6','1')";
        _result = [2, "gang_declare_war", _sql, [_instigator, _initGangId, _initGangName, _acceptor, _acptGangId, _acptGangName]] call DB_fnc_dbExecute;
    };

    case "endwar": {
        _params params [["_gangId1", "", [""]], ["_gangId2", "", [""]]];
        private _sql = "UPDATE gangwars SET active = '0' WHERE ((init_gangid='%1' AND acpt_gangid='%2') OR (acpt_gangid='%1' AND init_gangid='%2'))";
        _result = [2, "gang_end_war", _sql, [_gangId1, _gangId2]] call DB_fnc_dbExecute;
    };

    case "setwarstats": {
        _params params [["_p1", "", [""]], ["_p2", "", [""]], ["_p3", "", [""]], ["_p4", "", [""]], ["_p5", "", [""]], ["_p6", "", [""]], ["_p7", "", [""]]];
        private _sql = "CALL setWarStats(%1,%2,%3,%4,%5,%6,%7)";
        _result = [2, "gang_set_war_stats", _sql, [_p1, _p2, _p3, _p4, _p5, _p6, _p7]] call DB_fnc_dbExecute;
    };

    case "warexists": {
        _params params [["_gangId1", "", [""]], ["_gangId2", "", [""]]];
        private _sql = "SELECT id FROM gangwars WHERE active='1' AND ((init_gangid='%1' AND acpt_gangid='%2') OR (init_gangid='%2' AND acpt_gangid='%1'))";
        _result = [1, "gang_war_exists", _sql, [_gangId1, _gangId2]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Territory Operations
    // ==========================================

    case "getterritories": {
        _params params [["_server", "", [""]]];
        private _sql = "SELECT territory_name, gang_id, gang_name, capture_progress FROM territories WHERE server='%1'";
        _result = [1, "gang_get_territories", _sql, [_server], true] call DB_fnc_dbExecute;
    };

    case "updateterritory": {
        _params params [["_gangId", "", [""]], ["_gangName", "", [""]], ["_progress", "", [""]], ["_server", "", [""]], ["_territory", "", [""]]];
        private _sql = "UPDATE territories SET gang_id='%1', gang_name='%2', capture_progress='%3', territory_name='%5' WHERE server='%4' AND territory_name='%5'";
        _result = [2, "gang_update_territory", _sql, [_gangId, _gangName, _progress, _server, _territory]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Bank History Operations
    // ==========================================

    case "getbankhistory": {
        _params params [["_gangId", "", [""]]];
        private _sql = "SELECT name, playerid::text, type, amount FROM gangbankhistory WHERE gangid='%1' ORDER BY timestamp DESC LIMIT 20";
        _result = [1, "gang_get_bank_history", _sql, [_gangId], true] call DB_fnc_dbExecute;
    };

    case "addbankhistory": {
        _params params [["_name", "", [""]], ["_pid", "", [""]], ["_type", "", [""]], ["_amount", "", [""]], ["_gangId", "", [""]]];
        // 移除逗号和其他非数字字符，然后解析，避免科学计数法
        private _amountStr = _amount regexReplace ["[^0-9\-]", ""];
        private _amountClean = parseNumber _amountStr;
        diag_log format ["[GangMapper:addbankhistory] gangId=%1, amount=%2->%3", _gangId, _amount, _amountClean];
        // 使用整数格式避免科学计数法
        private _sql = format ["INSERT INTO gangbankhistory (name,playerid,type,amount,gangid) VALUES('%%1','%%2','%%3',%1,'%%4')", floor _amountClean];
        _result = [2, "gang_add_bank_history", _sql, [_name, _pid, _type, _gangId]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Gang Vehicle Operations
    // ==========================================

    case "deactivatevehicle": {
        _params params [["_gangId", "", [""]], ["_plate", "", [""]]];
        private _sql = "UPDATE gangvehicles SET active='0', persistentServer='0' WHERE gang_id='%1' AND plate='%2'";
        _result = [2, "gang_deactivate_vehicle", _sql, [_gangId, _plate]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Gang Status Check
    // ==========================================

    case "checkgangactive": {
        _params params [["_gangId", "", [""]]];
        private _sql = "SELECT active FROM gangs WHERE id='%1'";
        _result = [1, "gang_check_active", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Gang Rename Operations
    // ==========================================

    case "renamegang": {
        _params params [["_gangId", "", [""]], ["_newName", "", [""]]];
        private _sql = "UPDATE gangs SET name='%2' WHERE id='%1'";
        _result = [2, "gang_rename", _sql, [_gangId, _newName]] call DB_fnc_dbExecute;
    };

    case "renamegangmembers": {
        _params params [["_gangId", "", [""]], ["_newName", "", [""]]];
        private _sql = "UPDATE gangmembers SET gangname='%2' WHERE gangid='%1'";
        _result = [2, "gang_rename_members", _sql, [_gangId, _newName]] call DB_fnc_dbExecute;
    };

    case "renamegangbuildings": {
        _params params [["_gangId", "", [""]], ["_newName", "", [""]]];
        private _sql = "UPDATE gangbldgs SET gang_name='%2' WHERE gang_id='%1'";
        _result = [2, "gang_rename_buildings", _sql, [_gangId, _newName]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Zone Kill Operations
    // ==========================================

    case "setzonekill": {
        _params params [["_killerUid", "", [""]], ["_victimUid", "", [""]]];
        private _sql = "CALL setZoneKill('%1','%2')";
        _result = [2, "gang_set_zone_kill", _sql, [_killerUid, _victimUid]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Data Migration Operations
    // ==========================================

    case "countownedbuildings": {
        private _sql = "SELECT COUNT(*) FROM gangbldgs WHERE owned='1'";
        _result = [1, "gang_count_owned_buildings", _sql, []] call DB_fnc_dbExecute;
    };

    case "getownedbuildingpaged": {
        _params params [["_offset", 0, [0]]];
        private _sql = format ["SELECT id, gang_id FROM gangbldgs WHERE owned='1' LIMIT 1 OFFSET %1", _offset];
        _result = [1, "gang_get_owned_building_paged", _sql, []] call DB_fnc_dbExecute;
    };

    case "getgangcrates": {
        _params params [["_gangId", "", [""]], ["_bldgId", "", [""]]];
        private _sql = "SELECT id, bldg_id, gang_id, inventory FROM gangcrates WHERE owned='1' AND gang_id='%1' AND bldg_id='%2'";
        _result = [1, "gang_get_crates", _sql, [_gangId, _bldgId], true] call DB_fnc_dbExecute;
    };

    case "setbuildingphysinv": {
        _params params [["_physInventory", "", [""]], ["_bldgId", "", [""]], ["_gangId", "", [""]]];
        private _sql = "UPDATE gangbldgs SET physical_inventory='%1'::jsonb WHERE id='%2' AND gang_id='%3'";
        _result = [2, "gang_set_building_phys_inv", _sql, [_physInventory, _bldgId, _gangId]] call DB_fnc_dbExecute;
    };

    case "getgangleader": {
        _params params [["_gangId", "", [""]]];
        private _sql = "SELECT playerid::text, name FROM gangmembers WHERE gangid='%1' AND rank='5'";
        _result = [1, "gang_get_leader", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[GangMapper] Unknown method: %1", _method];
        _result = [];
    };
};

_result
