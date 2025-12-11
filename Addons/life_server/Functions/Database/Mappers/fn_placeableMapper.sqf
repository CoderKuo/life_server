/*
 * fn_placeableMapper.sqf
 * Placeable Items Data Access Layer
 */
params [
    ["_method", "", [""]],
    ["_params", [], [[]]]
];

private _result = [];

switch (toLower _method) do {

    case "insert": {
        _params params [
            ["_houseId", "", [""]],
            ["_ownerPid", "", [""]],
            ["_itemType", "", [""]],
            ["_className", "", [""]],
            ["_pos", "", [""]],
            ["_dir", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "INSERT INTO house_placeables (house_id, owner_pid, item_type, class_name, pos, dir, server) VALUES('%1', '%2', '%3', '%4', '%5', '%6', '%7') RETURNING id";
        _result = [1, "placeable_insert", _sql, [_houseId, _ownerPid, _itemType, _className, _pos, _dir, _server]] call DB_fnc_dbExecute;
    };

    case "getbyhouse": {
        _params params [
            ["_houseId", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "SELECT id, item_type, class_name, pos, dir, owner_pid FROM house_placeables WHERE house_id='%1' AND server='%2'";
        _result = [1, "placeable_get_by_house", _sql, [_houseId, _server], true] call DB_fnc_dbExecute;
    };

    case "delete": {
        _params params [
            ["_id", "", [""]],
            ["_ownerPid", "", [""]]
        ];
        private _sql = "DELETE FROM house_placeables WHERE id='%1' AND owner_pid='%2'";
        _result = [2, "placeable_delete", _sql, [_id, _ownerPid]] call DB_fnc_dbExecute;
    };

    case "deletebyhouse": {
        _params params [
            ["_houseId", "", [""]],
            ["_server", "", [""]]
        ];
        private _sql = "DELETE FROM house_placeables WHERE house_id='%1' AND server='%2'";
        _result = [2, "placeable_delete_by_house", _sql, [_houseId, _server]] call DB_fnc_dbExecute;
    };

    case "getstorage": {
        _params params [["_id", "", [""]]];
        private _sql = "SELECT storage FROM house_placeables WHERE id='%1'";
        _result = [1, "placeable_get_storage", _sql, [_id]] call DB_fnc_dbExecute;
    };

    case "updatestorage": {
        _params params [
            ["_id", "", [""]],
            ["_storage", "", [""]]
        ];
        private _sql = "UPDATE house_placeables SET storage='%2' WHERE id='%1'";
        _result = [2, "placeable_update_storage", _sql, [_id, _storage]] call DB_fnc_dbExecute;
    };

    default {
        diag_log format ["[PlaceableMapper] Unknown method: %1", _method];
    };
};

_result
