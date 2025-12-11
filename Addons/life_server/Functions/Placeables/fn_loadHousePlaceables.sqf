/*
 * fn_loadHousePlaceables.sqf
 * 加载房屋内的放置物品
 */
params [
    ["_houseId", -1, [0]],
    ["_house", objNull, [objNull]]
];

if (_houseId == -1) exitWith {};

private _server = serverName;
private _placeables = ["getbyhouse", [str _houseId, _server]] call DB_fnc_placeableMapper;

if (isNil "_placeables" || {count _placeables == 0}) exitWith {};

{
    _x params ["_id", "_type", "_className", "_posStr", "_dir", "_ownerPid"];

    private _pos = parseSimpleArray _posStr;
    private _dirNum = parseNumber _dir;

    // 创建物体
    private _obj = createVehicle [_className, _pos, [], 0, "NONE"];
    _obj setPosATL _pos;
    _obj setDir _dirNum;
    _obj enableSimulation false;

    // 设置变量
    _obj setVariable ["placeable_id", parseNumber _id, true];
    _obj setVariable ["placeable_type", _type, true];
    _obj setVariable ["owner_pid", _ownerPid, true];
    _obj setVariable ["house_id", _houseId, true];

    // 添加交互动作
    _obj addAction ["<t color='#00ff00'>使用酿酒设备</t>", {
        params ["_target", "_caller", "_actionId", "_arguments"];
        [_target, "use"] call OEC_fnc_placeableInteract;
    }, nil, 6, true, true, "", "true", 3];

    _obj addAction ["<t color='#ff9900'>拾取设备</t>", {
        params ["_target", "_caller", "_actionId", "_arguments"];
        [_target, "pickup"] call OEC_fnc_placeableInteract;
    }, nil, 5, false, true, "", "true", 3];

    diag_log format ["[Placeable] Loaded %1 (ID: %2) at %3", _type, _id, _pos];
} forEach _placeables;
