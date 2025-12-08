/*
 * ============================================================
 * Mapper 层使用指南 / Mapper Layer Usage Guide
 * ============================================================
 *
 * 本文件展示如何从旧的直接 SQL 调用迁移到新的 Mapper 层
 * This file demonstrates how to migrate from direct SQL calls to the new Mapper layer
 *
 */

// ============================================================
// 初始化 / Initialization
// ============================================================

// 在服务器初始化时调用 (在 init.sqf 中)
// Call during server initialization (in init.sqf)
[] call DB_fnc_dbConfig;  // 初始化数据库配置

// ============================================================
// 玩家数据操作示例 / Player Data Examples
// ============================================================

// --- 旧方式 (Old way) ---
/*
private _query = format ["SELECT playerid, name FROM players WHERE playerid='%1'", _uid];
private _result = [1, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
private _result = ["exists", [_uid]] call DB_fnc_playerMapper;


// --- 旧方式: 插入新玩家 (Old: Insert new player) ---
/*
private _query = format ["INSERT INTO players (playerid, name, cash, bankacc, aliases...) VALUES('%1', '%2', '%3'...)", _uid, _name, _cash...];
[2, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
["insert", [_uid, _name, _cash, _bank, _aliases]] call DB_fnc_playerMapper;


// --- 旧方式: 更新现金 (Old: Update cash) ---
/*
private _query = format ["UPDATE players SET cash='%1' WHERE playerid='%2'", _cash, _uid];
[2, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
["updateCash", [_uid, _cash]] call DB_fnc_playerMapper;


// --- 旧方式: 获取警察数据 (Old: Get cop data) ---
/*
private _query = format ["SELECT playerid, name, cash, bankacc, adminlevel, newdonor, cop_licenses, coplevel, cop_gear, aliases, player_stats, wanted, blacklist, supportteam FROM players WHERE playerid='%1'", _uid];
private _result = [1, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
private _result = ["getCopData", [_uid, "cop_gear"]] call DB_fnc_playerMapper;


// ============================================================
// 车辆数据操作示例 / Vehicle Data Examples
// ============================================================

// --- 旧方式: 获取车辆列表 (Old: Get vehicle list) ---
/*
private _query = format ["SELECT CONVERT(id, char), side, classname... FROM vehicles WHERE pid='%1' AND alive='1' AND active='0' AND side='%2' AND type='%3' ORDER BY classname DESC", _uid, _side, _type];
private _result = [1, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
private _result = ["getList", [_uid, _side, _type]] call DB_fnc_vehicleMapper;


// --- 旧方式: 购买车辆 (Old: Purchase vehicle) ---
/*
private _query = format ["INSERT INTO vehicles (side, classname, type, pid, alive, active, inventory, color, plate, insured, modifications) VALUES ('%1', '%2', '%3', '%4', '1','0','""[]""', '""[%5,0]""', '%6', '0', '""%7""')", _side, _class, _type, _uid, _color, _plate, _mods];
[2, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
["insert", [_side, _class, _type, _uid, "0", _color, _plate, _mods]] call DB_fnc_vehicleMapper;


// ============================================================
// 房屋数据操作示例 / House Data Examples
// ============================================================

// --- 旧方式: 获取所有房屋 (Old: Get all houses) ---
/*
private _query = format ["SELECT houses.id, houses.pid, houses.pos, players.name, houses.player_keys, houses.inventory, houses.storageCapacity, houses.inAH, houses.oil, houses.physical_inventory, houses.physicalStorageCapacity, DATEDIFF(houses.expires_on, TIMESTAMP(CURRENT_DATE())) FROM houses INNER JOIN players ON houses.pid=players.playerid WHERE houses.owned='1' AND server='%2' LIMIT %1,10", _offset, _server];
private _result = [1, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
private _result = ["getAll", [_offset, _server]] call DB_fnc_houseMapper;


// --- 旧方式: 延长房产契约 (Old: Extend house deed) ---
/*
private _query = format ["UPDATE houses SET expires_on = DATE_ADD(expires_on, INTERVAL %1 DAY) WHERE id='%2' AND SERVER='%3'", _days, _id, _server];
[2, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
["extendDeed", [_id, _days, _server]] call DB_fnc_houseMapper;


// ============================================================
// 帮派数据操作示例 / Gang Data Examples
// ============================================================

// --- 旧方式: 创建帮派 (Old: Create gang) ---
/*
private _query = format ["INSERT INTO gangs (name) VALUES('%1')", _gangName];
private _result = [1, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
private _result = ["createGang", [_gangName]] call DB_fnc_gangMapper;


// --- 旧方式: 获取帮派成员 (Old: Get gang members) ---
/*
private _query = format ["SELECT playerid, name, rank FROM gangmembers WHERE gangid='%1' ORDER BY rank DESC", _gangId];
private _result = [1, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
private _result = ["getMembers", [_gangId]] call DB_fnc_gangMapper;


// --- 旧方式: 创建帮派建筑 (Old: Create gang building) ---
/*
private _query = format ["INSERT INTO gangbldgs (owner, classname, pos, inventory, owned, gang_id, gang_name, server, crate_count, lastpayment, nextpayment, physical_inventory) VALUES('%1', '%2', '%3', '""[[],0]""', '1', '%4', '%5', '%6', '2', NOW(), DATE_ADD(NOW(),INTERVAL 31 DAY), '""[[],0]""')", _owner, _class, _pos, _gangId, _gangName, _server];
[2, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
["createBuilding", [_owner, _class, _pos, _gangId, _gangName, _server]] call DB_fnc_gangMapper;


// ============================================================
// 杂项操作示例 / Miscellaneous Examples
// ============================================================

// --- 旧方式: 获取市场价格 (Old: Get market prices) ---
/*
private _query = "SELECT market_array FROM market WHERE id='1'";
private _result = [1, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
private _result = ["getMarketPrices", ["1"]] call DB_fnc_miscMapper;


// --- 旧方式: 调用存储过程 (Old: Call stored procedure) ---
/*
private _query = "CALL deleteOldHouses1";
[2, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
["callDeleteOldHouses", []] call DB_fnc_miscMapper;


// --- 旧方式: 添加日志 (Old: Add log) ---
/*
private _query = format ["INSERT INTO playerlogs (playerID,logTitle,log) VALUES('%1','%2','%3')", _uid, _title, _log];
[2, _query] call OES_fnc_asyncCall;
*/

// --- 新方式 (New way) ---
["addPlayerLog", [_uid, _title, _log]] call DB_fnc_miscMapper;


// ============================================================
// 优势 / Advantages
// ============================================================
/*
1. 自动数据库切换 - 无需修改调用代码即可切换 MySQL/PostgreSQL
   Auto database switching - Switch MySQL/PostgreSQL without code changes

2. SQL 语法自动转换 - MySQL 语法自动转换为 PostgreSQL
   Auto SQL conversion - MySQL syntax auto-converted to PostgreSQL

3. 集中管理 - 所有 SQL 在一个地方，便于维护
   Centralized - All SQL in one place, easy to maintain

4. 类型安全 - 参数化查询，避免 SQL 注入
   Type safety - Parameterized queries, prevent SQL injection

5. 日志记录 - 启用调试模式可记录所有查询
   Logging - Debug mode logs all queries

6. 代码简洁 - 调用更简单，代码更清晰
   Clean code - Simpler calls, cleaner code
*/

// ============================================================
// 迁移步骤 / Migration Steps
// ============================================================
/*
1. 在 CfgFunctions.hpp 中添加: #include "Functions\Database\CfgFunctions.hpp"
2. 在 init.sqf 中初始化: [] call DB_fnc_dbConfig;
3. 逐步替换旧的 SQL 调用为新的 Mapper 调用
4. 测试每个功能确保正常工作
5. 删除旧的直接 SQL 调用代码
*/
