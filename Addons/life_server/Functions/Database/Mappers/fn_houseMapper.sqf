/*
 * fn_houseMapper.sqf
 * House Data Access Layer - PostgreSQL Native Syntax
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
        _params params [
            ["_pos", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "SELECT id FROM houses WHERE pos='%1' AND owned='1' AND server='%2'";
        _result = [1, "house_exists", _sql, [_pos, _server]] call DB_fnc_dbExecute;
    };

    case "isinauction": {
        _params params [
            ["_id", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "SELECT inAH FROM houses WHERE id='%1' AND owned='1' AND server='%2'";
        _result = [1, "house_in_auction", _sql, [_id, _server]] call DB_fnc_dbExecute;
    };

    case "getowner": {
        _params params [
            ["_pos", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "SELECT pid FROM houses WHERE pos='%1' AND owned='1' AND server='%2'";
        _result = [1, "house_get_owner", _sql, [_pos, _server]] call DB_fnc_dbExecute;
    };

    case "getbyplayer": {
        _params params [
            ["_pid", "", [""]],
            ["_server", "", [""]],
            ["_limit", 5, [0]]
        ];
        private _sql = format ["SELECT pid, pos, id FROM houses WHERE pid='%%1' AND owned='1' AND server='%%2' LIMIT %1", _limit];
        _result = [1, "house_get_by_player", _sql, [_pid, _server], true] call DB_fnc_dbExecute;
    };

    case "getcomponents": {
        _params params [
            ["_id", "", [""]],
            ["_server", "", [""]],
            ["_pid", "", [""]]
        ];
        private _sql = "SELECT jsonb_to_sqf(phys_comp), jsonb_to_sqf(virt_comp) FROM houses WHERE pid='%3' AND id='%1' AND owned='1' AND server='%2'";
        _result = [1, "house_get_components", _sql, [_id, _server, _pid]] call DB_fnc_dbExecute;
    };

    case "getall": {
        // PostgreSQL: Use (date1 - date2) instead of DATEDIFF, LIMIT x OFFSET y instead of LIMIT y,x, ::text to avoid scientific notation
        _params params [
            ["_offset", 0, [0]],
            ["_server", "", [""]]
        ];
        private _sql = "SELECT houses.id, houses.pid::text, houses.pos, players.name, jsonb_to_sqf(houses.player_keys), jsonb_to_sqf(houses.inventory), houses.storageCapacity, houses.inAH, houses.oil, jsonb_to_sqf(houses.physical_inventory), houses.physicalStorageCapacity, (houses.expires_on::date - CURRENT_DATE) FROM houses INNER JOIN players ON houses.pid=players.playerid WHERE houses.owned='1' AND server='%2' LIMIT 10 OFFSET %1";
        _result = [1, "house_get_all", _sql, [_offset, _server], true] call DB_fnc_dbExecute;
    };

    case "count": {
        _params params [["_server", "", [""]]];
        private _sql = "SELECT COUNT(*) FROM houses WHERE owned='1' AND server='%1'";
        _result = [1, "house_count", _sql, [_server]] call DB_fnc_dbExecute;
    };

    case "getbykeys": {
        // PostgreSQL: Use JSONB ? operator to check if player_keys contains the pid
        _params params [
            ["_pid", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "SELECT houses.pid::text, houses.pos, houses.id, players.name FROM houses INNER JOIN players ON houses.pid = players.playerid WHERE player_keys ? '%1' AND server='%2'";
        _result = [1, "house_get_by_keys", _sql, [_pid, _server], true] call DB_fnc_dbExecute;
    };

    // ==========================================
    // INSERT Operations
    // ==========================================

    case "insert": {
        // PostgreSQL: Use CURRENT_DATE + INTERVAL '45 days'
        _params params [
            ["_pid", "", [""]],
            ["_pos", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "INSERT INTO houses (pid, pos, inventory, owned, physical_inventory, server, expires_on) VALUES('%1', '%2', '[[],0]'::jsonb, '1', '[[],0]'::jsonb, '%3', CURRENT_DATE + INTERVAL '45 days')";
        _result = [2, "house_insert", _sql, [_pid, _pos, _server]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // UPDATE Operations
    // ==========================================

    case "updateowner": {
        _params params [
            ["_id", "", [""]],
            ["_oldPid", "", [""]],
            ["_newPid", "", [""]],
            ["_keys", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET pid='%3', player_keys='%4'::jsonb, inAH='0' WHERE id='%1' AND pid='%2' AND server='%5'";
        _result = [2, "house_update_owner", _sql, [_id, _oldPid, _newPid, _keys, _server]] call DB_fnc_dbExecute;
    };

    case "updateauction": {
        _params params [
            ["_id", "", [""]],
            ["_pid", "", [""]],
            ["_inAH", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET inAH='%3' WHERE id='%1' AND pid='%2' AND server='%4'";
        _result = [2, "house_update_auction", _sql, [_id, _pid, _inAH, _server]] call DB_fnc_dbExecute;
    };

    case "removeauction": {
        _params params [
            ["_id", "", [""]],
            ["_pid", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET inAH='0' WHERE id='%1' AND pid='%2' AND server='%3'";
        _result = [2, "house_remove_auction", _sql, [_id, _pid, _server]] call DB_fnc_dbExecute;
    };

    case "updateinventory": {
        _params params [
            ["_id", "", [""]],
            ["_inventory", "", [""]],
            ["_physInventory", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET inventory='%2'::jsonb, physical_inventory='%3'::jsonb WHERE id='%1' AND server='%4'";
        _result = [2, "house_update_inventory", _sql, [_id, _inventory, _physInventory, _server]] call DB_fnc_dbExecute;
    };

    case "updatekeys": {
        _params params [
            ["_id", "", [""]],
            ["_pid", "", [""]],
            ["_keys", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET player_keys='%3'::jsonb WHERE id='%1' AND pid='%2' AND server='%4'";
        _result = [2, "house_update_keys", _sql, [_id, _pid, _keys, _server]] call DB_fnc_dbExecute;
    };

    case "updatestorage": {
        _params params [
            ["_id", "", [""]],
            ["_pid", "", [""]],
            ["_capacity", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET storageCapacity='%3' WHERE id='%1' AND pid='%2' AND server='%4'";
        _result = [2, "house_update_storage", _sql, [_id, _pid, _capacity, _server]] call DB_fnc_dbExecute;
    };

    case "updatephysicalstorage": {
        _params params [
            ["_id", "", [""]],
            ["_pid", "", [""]],
            ["_capacity", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET physicalStorageCapacity='%3' WHERE id='%1' AND pid='%2' AND server='%4'";
        _result = [2, "house_update_physical_storage", _sql, [_id, _pid, _capacity, _server]] call DB_fnc_dbExecute;
    };

    case "extenddeed": {
        // PostgreSQL: Use expires_on + INTERVAL 'N days'
        _params params [
            ["_id", "", [""]],
            ["_days", 0, [0]],
            ["_server", "", [""]]
        ];
        private _sql = format ["UPDATE houses SET expires_on = expires_on + INTERVAL '%1 days' WHERE id='%%1' AND server='%%2'", _days];
        _result = [2, "house_extend_deed", _sql, [_id, _server]] call DB_fnc_dbExecute;
    };

    case "upgradeoil": {
        _params params [
            ["_id", "", [""]],
            ["_pid", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET oil='1' WHERE id='%1' AND pid='%2' AND server='%3'";
        _result = [2, "house_upgrade_oil", _sql, [_id, _pid, _server]] call DB_fnc_dbExecute;
    };

    case "resetcomponents": {
        _params params [
            ["_id", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET phys_comp='[[]]'::jsonb, virt_comp='[[]]'::jsonb WHERE owned='1' AND id='%1' AND server='%2'";
        _result = [2, "house_reset_components", _sql, [_id, _server]] call DB_fnc_dbExecute;
    };

    case "sell": {
        _params params [
            ["_id", "", [""]],
            ["_pid", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET owned='0', pos='[]' WHERE id='%1' AND pid='%2' AND server='%3'";
        _result = [2, "house_sell", _sql, [_id, _pid, _server]] call DB_fnc_dbExecute;
    };

    // ==========================================
    // Data Migration Operations (Storage Conversion)
    // ==========================================

    case "getownedhousepaged": {
        // Paged get owned houses
        _params params [
            ["_offset", 0, [0]],
            ["_server", "", [""]]
        ];
        private _sql = format ["SELECT id, pid FROM houses WHERE owned='1' AND server='%%1' LIMIT 1 OFFSET %1", _offset];
        _result = [1, "house_get_owned_paged", _sql, [_server]] call DB_fnc_dbExecute;
    };

    case "gethousecrates": {
        // Get house crates data
        _params params [
            ["_pid", "", [""]],
            ["_houseId", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "SELECT id, pid, houseid, inventory FROM crates WHERE owned='1' AND pid='%1' AND houseid='%2' AND server='%3'";
        _result = [1, "house_get_crates", _sql, [_pid, _houseId, _server], true] call DB_fnc_dbExecute;
    };

    case "setphysinventory": {
        // Set house physical inventory
        _params params [
            ["_physInventory", "", [""]],
            ["_houseId", "", [""]],
            ["_pid", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE houses SET physical_inventory='%1'::jsonb WHERE id='%2' AND pid='%3' AND server='%4'";
        _result = [2, "house_set_phys_inventory", _sql, [_physInventory, _houseId, _pid, _server]] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[HouseMapper] Unknown method: %1", _method];
        _result = [];
    };
};

_result
