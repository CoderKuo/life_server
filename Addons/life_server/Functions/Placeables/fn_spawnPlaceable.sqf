/*
 * fn_spawnPlaceable.sqf
 * 服务端生成放置物品
 */
params [
    ["_unit", objNull, [objNull]],
    ["_type", "", [""]],
    ["_className", "", [""]],
    ["_pos", [], [[]]],
    ["_dir", 0, [0]],
    ["_houseId", -1, [0]]
];

if (isNull _unit) exitWith {};
if (_houseId == -1) exitWith {};

private _pid = getPlayerUID _unit;
private _server = serverName;

// 创建物体
private _obj = createVehicle [_className, _pos, [], 0, "NONE"];
_obj setPosATL _pos;
_obj setDir _dir;
_obj enableSimulation false;

// 保存到数据库
private _posStr = str _pos;
private _result = ["insert", [str _houseId, _pid, _type, _className, _posStr, str _dir, _server]] call DB_fnc_placeableMapper;

diag_log format ["[Placeable] DB insert result: %1 (type: %2)", _result, typeName _result];

private _placeableId = -1;
if (!isNil "_result" && {count _result > 0}) then {
    private _firstRow = _result select 0;
    if (typeName _firstRow == "ARRAY") then {
        _placeableId = parseNumber (_firstRow select 0);
    } else {
        _placeableId = parseNumber _firstRow;
    };
};
diag_log format ["[Placeable] Parsed ID: %1", _placeableId];

// 设置物体变量
_obj setVariable ["placeable_id", _placeableId, true];
_obj setVariable ["placeable_type", _type, true];
_obj setVariable ["owner_pid", _pid, true];
_obj setVariable ["house_id", _houseId, true];

diag_log format ["[Placeable] Spawned %1 at %2 for player %3, ID: %4", _type, _pos, _pid, _placeableId];
