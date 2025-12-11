/*
 * fn_removePlaceable.sqf
 * 服务端移除放置物品
 */
params [
    ["_unit", objNull, [objNull]],
    ["_placeableId", -1, [0]],
    ["_type", "", [""]]
];

if (isNull _unit) exitWith {};
if (_placeableId == -1) exitWith {};

private _pid = getPlayerUID _unit;

// 从数据库删除
["delete", [str _placeableId, _pid]] call DB_fnc_placeableMapper;

// 查找并删除物体
{
    if ((_x getVariable ["placeable_id", -1]) == _placeableId) exitWith {
        deleteVehicle _x;

        // 返还物品给玩家
        private _itemName = switch (_type) do {
            case "brewery": {"brewery_kit"};
            case "brewery_adv": {"brewery_kit_adv"};
            default {""};
        };

        if (_itemName != "") then {
            [[true, _itemName, 1], "OEC_fnc_handleInv", _unit, false] call OES_fnc_MPexec;
            [0, format["设备已拾取并放入背包"]] remoteExec ["OEC_fnc_broadcast", owner _unit];
        };

        diag_log format ["[Placeable] Removed ID: %1 by player %2", _placeableId, _pid];
    };
} forEach (allMissionObjects "All");
