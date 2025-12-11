/*
 * fn_breweryGetStorage.sqf
 * 服务端获取酿酒设备存储
 */
params [
	["_unit", objNull, [objNull]],
	["_placeableId", -1, [0]]
];

if (isNull _unit || _placeableId == -1) exitWith {};

// 从数据库获取存储
private _result = ["getstorage", [str _placeableId]] call DB_fnc_placeableMapper;

private _storage = [];
if (!isNil "_result" && {count _result > 0}) then {
	private _storageStr = _result select 0;
	if (!isNil "_storageStr" && {_storageStr != ""}) then {
		_storage = parseSimpleArray _storageStr;
		if (isNil "_storage") then {_storage = []};
	};
};

// 发送到客户端
[["oev_brewery_storage", _storage], "OEC_fnc_netSetVar", owner _unit, false] call OEC_fnc_MP;
[["oev_brewery_storage_ready", true], "OEC_fnc_netSetVar", owner _unit, false] call OEC_fnc_MP;
