/*
 * fn_vehicleMapper.sqf
 * Vehicle Data Access Layer - PostgreSQL Native Syntax
 */

params [
    ["_method", "", [""]],
    ["_params", [], [[]]]
];

// 入口调试日志 - 使用 diag_log 确保输出到 RPT
diag_log format ["[VehicleMapper] ENTRY - method=%1, params=%2, _this=%3", _method, _params, _this];

private _result = [];

switch (toLower _method) do {

    // ==========================================
    // SELECT Operations
    // ==========================================

    case "getbyplayer": {
        _params params [["_pid", "", [""]]];
        // PostgreSQL: Use ::text instead of CONVERT(id, char)
        private _sql = "SELECT id::text FROM vehicles WHERE pid='%1'";
        _result = [1, "vehicle_get_by_player", _sql, [_pid]] call DB_fnc_dbExecute;
    };

    case "getbygang": {
        _params params [["_gangId", "", [""]]];
        private _sql = "SELECT id::text FROM gangvehicles WHERE gang_id='%1'";
        _result = [1, "vehicle_get_by_gang", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    case "getdetails": {
        _params params [
            ["_id", "", [""]],
            ["_pid", "", [""]]
        ];
        private _sql = "SELECT id::text, side, classname, type, pid, alive, active, plate, jsonb_to_sqf(color), insured, jsonb_to_sqf(modifications), customName FROM vehicles WHERE id=%1 AND pid='%2'";
        _result = [1, "vehicle_get_details", _sql, [_id, _pid]] call DB_fnc_dbExecute;
    };

    case "getgangdetails": {
        _params params [
            ["_id", "", [""]],
            ["_gangId", "", [""]]
        ];
        private _sql = "SELECT id::text, side, classname, type, gang_id, alive, active, plate, jsonb_to_sqf(color), insured, jsonb_to_sqf(modifications) FROM gangvehicles WHERE id=%1 AND gang_id='%2'";
        _result = [1, "vehicle_get_gang_details", _sql, [_id, _gangId]] call DB_fnc_dbExecute;
    };

    case "getpersistent": {
        _params params [
            ["_server", "", [""]],
            ["_side", "", [""]]
        ];
        private _sql = "SELECT id::text, side, classname, type, pid, alive, active, plate, jsonb_to_sqf(color), jsonb_to_sqf(inventory), insured, jsonb_to_sqf(modifications), jsonb_to_sqf(persistentposition), persistentDirection FROM vehicles WHERE alive='1' AND (active='0' OR active='%1') AND persistentServer='%1' AND side='%2'";
        _result = [1, "vehicle_get_persistent", _sql, [_server, _side], true] call DB_fnc_dbExecute;
    };

    case "getgangpersistent": {
        _params params [
            ["_server", "", [""]],
            ["_side", "", [""]]
        ];
        private _sql = "SELECT id::text, side, classname, type, gang_id, alive, active, plate, jsonb_to_sqf(color), jsonb_to_sqf(inventory), insured, jsonb_to_sqf(modifications), jsonb_to_sqf(persistentposition), persistentDirection FROM gangvehicles WHERE alive='1' AND (active='0' OR active='%1') AND persistentServer='%1' AND side='%2'";
        _result = [1, "vehicle_get_gang_persistent", _sql, [_server, _side], true] call DB_fnc_dbExecute;
    };

    case "countbyplayer": {
        _params params [
            ["_pid", "", [""]],
            ["_side", "", [""]]
        ];
        private _sql = "SELECT COUNT(id) FROM vehicles WHERE pid='%1' AND alive='1' AND side='%2'";
        _result = [1, "vehicle_count_by_player", _sql, [_pid, _side]] call DB_fnc_dbExecute;
    };

    case "countbygang": {
        _params params [["_gangId", "", [""]]];
        private _sql = "SELECT COUNT(id) FROM gangvehicles WHERE gang_id='%1' AND alive='1'";
        _result = [1, "vehicle_count_by_gang", _sql, [_gangId]] call DB_fnc_dbExecute;
    };

    case "getactiveid": {
        _params params [
            ["_pid", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "SELECT id::text FROM vehicles WHERE pid='%1' AND active='%2'";
        _result = [1, "vehicle_get_active_id", _sql, [_pid, _server]] call DB_fnc_dbExecute;
    };

    case "getgangactiveid": {
        _params params [
            ["_gangId", "", [""]],
            ["_server", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "SELECT id::text, side, classname, type, plate FROM gangvehicles WHERE gang_id='%1' AND active='%2' AND plate='%3'";
        _result = [1, "vehicle_get_gang_active_id", _sql, [_gangId, _server, _plate]] call DB_fnc_dbExecute;
    };

    case "getbypidplate": {
        _params params [
            ["_pid", "", [""]],
            ["_active", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "SELECT id::text FROM vehicles WHERE pid='%1' AND active='%2' AND alive='1' AND plate='%3'";
        _result = [1, "vehicle_get_by_pid_plate", _sql, [_pid, _active, _plate]] call DB_fnc_dbExecute;
    };

    case "getdetailsbyplate": {
        _params params [
            ["_pid", "", [""]],
            ["_server", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "SELECT id::text, side, classname, type, plate, jsonb_to_sqf(modifications) FROM vehicles WHERE pid='%1' AND active='%2' AND alive='1' AND plate='%3'";
        _result = [1, "vehicle_get_details_by_plate", _sql, [_pid, _server, _plate]] call DB_fnc_dbExecute;
    };

    case "claim": {
        _params params [
            ["_newPid", "", [""]],
            ["_oldPid", "", [""]],
            ["_plate", "", [""]],
            ["_color", "", [""]]
        ];
        // color 格式: ["ColorName", 0] - 使用 JSON 格式（双引号）
        private _colorArr = format ["[""%1"",0]", _color];
        private _sql = format ["UPDATE vehicles SET active='0', persistentServer='0', pid='%%1', color='%1'::jsonb, side='civ' WHERE pid='%%2' AND plate='%%3'", _colorArr];
        _result = [2, "vehicle_claim", _sql, [_newPid, _oldPid, _plate]] call DB_fnc_dbExecute;
    };

    case "deactivateandkill": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET active='1', alive='0', insured='0', persistentServer='0' WHERE pid='%1' AND plate='%2'";
        _result = [2, "vehicle_deactivate_and_kill", _sql, [_pid, _plate]] call DB_fnc_dbExecute;
    };

    case "getlist": {
        _params params [
            ["_pid", "", [""]],
            ["_side", "", [""]],
            ["_type", "", [""]]
        ];
        // 第5个参数 true 表示返回多行结果
        private _sql = "SELECT id::text, side, classname, type, pid, alive, active, plate, jsonb_to_sqf(color), insured, jsonb_to_sqf(modifications), customName FROM vehicles WHERE pid='%1' AND alive='1' AND active='0' AND side='%2' AND type='%3' ORDER BY classname DESC";
        _result = [1, "vehicle_get_list", _sql, [_pid, _side, _type], true] call DB_fnc_dbExecute;
    };

    case "getganglist": {
        _params params [
            ["_gangId", "", [""]],
            ["_type", "", [""]]
        ];
        // 第5个参数 true 表示返回多行结果
        private _sql = "SELECT id::text, side, classname, type, gang_id, alive, active, plate, jsonb_to_sqf(color), insured, jsonb_to_sqf(modifications) FROM gangvehicles WHERE gang_id='%1' AND alive='1' AND active='0' AND type='%2' ORDER BY classname DESC";
        _result = [1, "vehicle_get_gang_list", _sql, [_gangId, _type], true] call DB_fnc_dbExecute;
    };

    // ==========================================
    // INSERT Operations
    // ==========================================

    case "insert": {
        diag_log "[VehicleMapper] INSERT case matched!";
        _params params [
            ["_side", "", [""]],
            ["_classname", "", [""]],
            ["_type", "", [""]],
            ["_pid", "", [""]],
            ["_active", "0", [""]],
            ["_color", "", [""]],
            ["_plate", "", [""]],
            ["_mods", "[0,0,0,0,0,0,0,0]", [""]]
        ];
        diag_log format["[VehicleMapper:insert] Params: side=%1, class=%2, type=%3, pid=%4, active=%5, color=%6, plate=%7, mods=%8", _side, _classname, _type, _pid, _active, _color, _plate, _mods];
        // color 格式: ["ColorName", 0] - 使用 JSON 格式（双引号）
        private _colorArr = format ["[""%1"",0]", _color];
        private _sql = format [
            "INSERT INTO vehicles (side, classname, type, pid, alive, active, inventory, color, plate, insured, modifications) VALUES ('%1', '%2', '%3', '%4', '1', '%5', '[]'::jsonb, '%6'::jsonb, '%7', '0', '%8'::jsonb)",
            _side, _classname, _type, _pid, _active, _colorArr, _plate, _mods
        ];
        diag_log format["[VehicleMapper:insert] SQL: %1", _sql];
        _result = [2, "vehicle_insert", _sql, []] call DB_fnc_dbExecute;
        diag_log format["[VehicleMapper:insert] Result: %1", _result];
    };

    case "insertgang": {
        _params params [
            ["_side", "", [""]],
            ["_classname", "", [""]],
            ["_type", "", [""]],
            ["_gangId", "", [""]],
            ["_active", "0", [""]],
            ["_color", "", [""]],
            ["_plate", "", [""]],
            ["_mods", "[0,0,0,0,0,0,0,0]", [""]]
        ];
        // color 格式: ["ColorName", 0] - 使用 JSON 格式（双引号）
        private _colorArr = format ["[""%1"",0]", _color];
        private _sql = format [
            "INSERT INTO gangvehicles (side, classname, type, gang_id, alive, active, inventory, color, plate, insured, modifications) VALUES ('%1', '%2', '%3', '%4', '1', '%5', '[]'::jsonb, '%6'::jsonb, '%7', '0', '%8'::jsonb)",
            _side, _classname, _type, _gangId, _active, _colorArr, _plate, _mods
        ];
        _result = [2, "vehicle_insert_gang", _sql, []] call DB_fnc_dbExecute;
    };

    // ==========================================
    // UPDATE Operations
    // ==========================================

    case "setinactive": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET active='0', persistentServer='0' WHERE pid='%1' AND plate='%2'";
        _result = [2, "vehicle_set_inactive", _sql, [_pid, _plate]] call DB_fnc_dbExecute;
    };

    case "setganginactive": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET active='0', persistentServer='0' WHERE gang_id='%1' AND plate='%2'";
        _result = [2, "vehicle_set_gang_inactive", _sql, [_gangId, _plate]] call DB_fnc_dbExecute;
    };

    case "updateinventory": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]],
            ["_classname", "", [""]],
            ["_inventory", "", [""]],
            ["_server", "", [""]],
            ["_position", "", [""]],
            ["_direction", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET inventory='%4'::jsonb, persistentServer='%5', persistentPosition='%6'::jsonb, persistentDirection='%7' WHERE pid='%1' AND plate='%2' AND classname='%3'";
        _result = [2, "vehicle_update_inventory", _sql, [_pid, _plate, _classname, _inventory, _server, _position, _direction]] call DB_fnc_dbExecute;
    };

    case "updateganginventory": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]],
            ["_classname", "", [""]],
            ["_inventory", "", [""]],
            ["_server", "", [""]],
            ["_position", "", [""]],
            ["_direction", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET inventory='%4'::jsonb, persistentServer='%5', persistentPosition='%6'::jsonb, persistentDirection='%7' WHERE gang_id='%1' AND plate='%2' AND classname='%3'";
        _result = [2, "vehicle_update_gang_inventory", _sql, [_gangId, _plate, _classname, _inventory, _server, _position, _direction]] call DB_fnc_dbExecute;
    };

    case "updatepersistent": {
        _params params [
            ["_pid", "", [""]],
            ["_id", "", [""]],
            ["_active", "", [""]],
            ["_server", "", [""]],
            ["_position", "", [""]],
            ["_direction", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET active='%3', persistentServer='%4', persistentPosition='%5', persistentDirection='%6' WHERE pid='%1' AND id=%2";
        _result = [2, "vehicle_update_persistent", _sql, [_pid, _id, _active, _server, _position, _direction]] call DB_fnc_dbExecute;
    };

    case "updategangpersistent": {
        _params params [
            ["_gangId", "", [""]],
            ["_id", "", [""]],
            ["_active", "", [""]],
            ["_server", "", [""]],
            ["_position", "", [""]],
            ["_direction", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET active='%3', persistentServer='%4', persistentPosition='%5', persistentDirection='%6' WHERE gang_id='%1' AND id=%2";
        _result = [2, "vehicle_update_gang_persistent", _sql, [_gangId, _id, _active, _server, _position, _direction]] call DB_fnc_dbExecute;
    };

    case "sell": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET alive='0' WHERE pid='%1' AND plate='%2'";
        _result = [2, "vehicle_sell", _sql, [_pid, _plate]] call DB_fnc_dbExecute;
    };

    case "sellgang": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET alive='0' WHERE gang_id='%1' AND plate='%2'";
        _result = [2, "vehicle_sell_gang", _sql, [_gangId, _plate]] call DB_fnc_dbExecute;
    };

    case "chop": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]],
            ["_color", "", [""]]
        ];
        // color 格式: ["ColorName", 0] - 使用 JSON 格式（双引号）
        private _colorArr = format ["[""%1"",0]", _color];
        private _sql = format ["UPDATE vehicles SET active='0', insured='0', modifications='[0,0,0,0,0,0,0,0]'::jsonb, inventory='[]'::jsonb, color='%1'::jsonb, persistentServer='0' WHERE pid='%%1' AND plate='%%2'", _colorArr];
        _result = [2, "vehicle_chop", _sql, [_pid, _plate]] call DB_fnc_dbExecute;
    };

    case "chopgang": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]],
            ["_color", "", [""]]
        ];
        // color 格式: ["ColorName", 0] - 使用 JSON 格式（双引号）
        private _colorArr = format ["[""%1"",0]", _color];
        private _sql = format ["UPDATE gangvehicles SET active='0', insured='0', modifications='[0,0,0,0,0,0,0,0]'::jsonb, inventory='[]'::jsonb, color='%1'::jsonb, persistentServer='0' WHERE gang_id='%%1' AND plate='%%2'", _colorArr];
        _result = [2, "vehicle_chop_gang", _sql, [_gangId, _plate]] call DB_fnc_dbExecute;
    };

    case "transfer": {
        _params params [
            ["_id", "", [""]],
            ["_newPid", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET pid='%2', color='[-1,0]'::jsonb WHERE id=%1";
        _result = [2, "vehicle_transfer", _sql, [_id, _newPid]] call DB_fnc_dbExecute;
    };

    case "deletebyid": {
        _params params [
            ["_pid", "", [""]],
            ["_id", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET alive='0' WHERE pid='%1' AND id=%2";
        _result = [2, "vehicle_delete_by_id", _sql, [_pid, _id]] call DB_fnc_dbExecute;
    };

    case "deletegangbyplate": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET alive='0' WHERE gang_id='%1' AND plate='%2'";
        _result = [2, "vehicle_delete_gang_by_plate", _sql, [_gangId, _plate]] call DB_fnc_dbExecute;
    };

    case "seizeandtransfer": {
        _params params [
            ["_oldPid", "", [""]],
            ["_plate", "", [""]],
            ["_newPid", "", [""]],
            ["_color", "", [""]],
            ["_side", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET active='0', persistentServer='0', pid='%3', color='%4'::jsonb, side='%5' WHERE pid='%1' AND plate='%2'";
        _result = [2, "vehicle_seize_transfer", _sql, [_oldPid, _plate, _newPid, _color, _side]] call DB_fnc_dbExecute;
    };

    case "updatemods": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]],
            ["_insured", "", [""]],
            ["_mods", "", [""]],
            ["_color", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET insured='%3', modifications='%4'::jsonb, color='%5'::jsonb WHERE pid='%1' AND plate='%2'";
        _result = [2, "vehicle_update_mods", _sql, [_pid, _plate, _insured, _mods, _color]] call DB_fnc_dbExecute;
    };

    case "updategangmods": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]],
            ["_insured", "", [""]],
            ["_mods", "", [""]],
            ["_color", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET insured='%3', modifications='%4'::jsonb, color='%5'::jsonb WHERE gang_id='%1' AND plate='%2'";
        _result = [2, "vehicle_update_gang_mods", _sql, [_gangId, _plate, _insured, _mods, _color]] call DB_fnc_dbExecute;
    };

    case "updatecustomname": {
        _params params [
            ["_pid", "", [""]],
            ["_id", "", [""]],
            ["_name", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET customName='%3' WHERE pid='%1' AND id='%2'";
        _result = [2, "vehicle_update_custom_name", _sql, [_pid, _id, _name]] call DB_fnc_dbExecute;
    };

    case "setactive": {
        _params params [
            ["_pid", "", [""]],
            ["_id", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET active='%3', persistentServer='0' WHERE pid='%1' AND id=%2";
        _result = [2, "vehicle_set_active", _sql, [_pid, _id, _server]] call DB_fnc_dbExecute;
    };

    case "setgangactive": {
        _params params [
            ["_gangId", "", [""]],
            ["_id", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET active='%3', persistentServer='0' WHERE gang_id='%1' AND id=%2";
        _result = [2, "vehicle_set_gang_active", _sql, [_gangId, _id, _server]] call DB_fnc_dbExecute;
    };

    case "setdead": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]],
            ["_insured", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET alive='0', active='0', insured=%3 WHERE pid='%1' AND plate='%2'";
        _result = [2, "vehicle_set_dead", _sql, [_pid, _plate, _insured]] call DB_fnc_dbExecute;
    };

    case "setgangdead": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]],
            ["_insured", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET alive='0', active='0', insured=%3 WHERE gang_id='%1' AND plate='%2'";
        _result = [2, "vehicle_set_gang_dead", _sql, [_gangId, _plate, _insured]] call DB_fnc_dbExecute;
    };

    case "respawn": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]],
            ["_color", "", [""]],
            ["_insured", "", [""]]
        ];
        // color 格式: ["ColorName", 0] - 使用 JSON 格式（双引号）
        private _colorArr = format ["[""%1"",0]", _color];
        private _sql = format ["UPDATE vehicles SET alive='1', insured=%2, modifications='[0,0,0,0,0,0,0,0]'::jsonb, inventory='[]'::jsonb, color='%1'::jsonb WHERE pid='%%1' AND plate='%%2'", _colorArr, _insured];
        _result = [2, "vehicle_respawn", _sql, [_pid, _plate]] call DB_fnc_dbExecute;
    };

    case "respawngang": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]],
            ["_color", "", [""]],
            ["_insured", "", [""]]
        ];
        // color 格式: ["ColorName", 0] - 使用 JSON 格式（双引号）
        private _colorArr = format ["[""%1"",0]", _color];
        private _sql = format ["UPDATE gangvehicles SET alive='1', insured=%2, modifications='[0,0,0,0,0,0,0,0]'::jsonb, inventory='[]'::jsonb, color='%1'::jsonb WHERE gang_id='%%1' AND plate='%%2'", _colorArr, _insured];
        _result = [2, "vehicle_respawn_gang", _sql, [_gangId, _plate]] call DB_fnc_dbExecute;
    };

    case "respawnfull": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET alive='1', insured='0' WHERE pid='%1' AND plate='%2'";
        _result = [2, "vehicle_respawn_full", _sql, [_pid, _plate]] call DB_fnc_dbExecute;
    };

    case "respawnfullgang": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET alive='1', insured='0' WHERE gang_id='%1' AND plate='%2'";
        _result = [2, "vehicle_respawn_full_gang", _sql, [_gangId, _plate]] call DB_fnc_dbExecute;
    };

    // Vehicle death handler - no insurance
    case "markdead": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET alive='0' WHERE pid='%1' AND plate='%2'";
        _result = [2, "vehicle_mark_dead", _sql, [_pid, _plate]] call DB_fnc_dbExecute;
    };

    case "markgangdead": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET alive='0' WHERE gang_id='%1' AND plate='%2'";
        _result = [2, "vehicle_mark_gang_dead", _sql, [_gangId, _plate]] call DB_fnc_dbExecute;
    };

    // Vehicle death handler - basic insurance (reset some mods)
    case "deadbasicins": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]],
            ["_color", "", [""]],
            ["_mods", "", [""]]
        ];
        // color 格式: ["ColorName", 0] - 使用 JSON 格式（双引号）
        private _colorArr = format ["[""%1"",0]", _color];
        private _sql = format ["UPDATE vehicles SET active='0', insured='0', modifications='%2'::jsonb, inventory='[]'::jsonb, color='%1'::jsonb, persistentServer='0' WHERE pid='%%1' AND plate='%%2'", _colorArr, _mods];
        _result = [2, "vehicle_dead_basic_ins", _sql, [_pid, _plate]] call DB_fnc_dbExecute;
    };

    case "deadgangbasicins": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]],
            ["_color", "", [""]],
            ["_mods", "", [""]]
        ];
        // color 格式: ["ColorName", 0] - 使用 JSON 格式（双引号）
        private _colorArr = format ["[""%1"",0]", _color];
        private _sql = format ["UPDATE gangvehicles SET active='0', insured='0', modifications='%2'::jsonb, inventory='[]'::jsonb, color='%1'::jsonb, persistentServer='0' WHERE gang_id='%%1' AND plate='%%2'", _colorArr, _mods];
        _result = [2, "vehicle_dead_gang_basic_ins", _sql, [_gangId, _plate]] call DB_fnc_dbExecute;
    };

    // Vehicle death handler - full insurance (keep mods)
    case "deadfullins": {
        _params params [
            ["_pid", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE vehicles SET active='0', insured='0', inventory='[]'::jsonb, persistentServer='0' WHERE pid='%1' AND plate='%2'";
        _result = [2, "vehicle_dead_full_ins", _sql, [_pid, _plate]] call DB_fnc_dbExecute;
    };

    case "deadgangfullins": {
        _params params [
            ["_gangId", "", [""]],
            ["_plate", "", [""]]
        ];
        private _sql = "UPDATE gangvehicles SET active='0', insured='0', inventory='[]'::jsonb, persistentServer='0' WHERE gang_id='%1' AND plate='%2'";
        _result = [2, "vehicle_dead_gang_full_ins", _sql, [_gangId, _plate]] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[VehicleMapper] Unknown method: %1", _method];
        _result = [];
    };
};

diag_log format ["[VehicleMapper] EXIT - returning: %1", _result];
_result
