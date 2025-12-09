/*
 * fn_owner2Player.sqf
 * Author: Fusah
 * Modified: 使用 HashMap 缓存优化
 *
 * Description: 根据 client-ID 获取玩家对象 (仅服务器端使用)
 */

params [
	["_clientID", 0]
];

if !(isServer) exitWith {};
if (_clientID isEqualTo 0) exitWith {};

// 使用 HashMap 缓存 O(1) 查找
[_clientID] call OES_fnc_getPlayerByOwner
