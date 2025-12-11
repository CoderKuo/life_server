/*
 * fn_breweryUpdateStorage.sqf
 * 服务端更新酿酒设备存储
 */
params [
	["_unit", objNull, [objNull]],
	["_placeableId", -1, [0]],
	["_storage", [], [[]]]
];

if (isNull _unit || _placeableId == -1) exitWith {};

// 清理空项目
private _cleanStorage = [];
{
	if ((_x select 1) > 0) then {
		_cleanStorage pushBack _x;
	};
} forEach _storage;

// 保存到数据库
private _storageStr = str _cleanStorage;
["updatestorage", [str _placeableId, _storageStr]] call DB_fnc_placeableMapper;

diag_log format ["[Brewery] Updated storage for placeable %1: %2", _placeableId, _storageStr];
