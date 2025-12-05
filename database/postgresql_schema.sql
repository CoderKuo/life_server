/*
 * ============================================
 * Olympus Altis Life - PostgreSQL 数据库架构
 * ============================================
 *
 * 此文件包含从 MySQL 迁移到 PostgreSQL 所需的表结构
 * 基于 extDB3 MySQL 架构转换而来
 *
 * 使用方法:
 *   1. 创建数据库: CREATE DATABASE arma3;
 *   2. 连接到数据库后执行此脚本
 *   3. 配置 arma3-pgsql.ini 中的连接信息
 *
 * 注意:
 *   - 所有 MySQL 的 AUTO_INCREMENT 改为 PostgreSQL 的 SERIAL
 *   - TEXT 类型保持不变
 *   - TINYINT 改为 SMALLINT
 *   - DATETIME 改为 TIMESTAMP
 *   - MySQL 特有的 ENUM 改为 VARCHAR + CHECK 约束
 */

-- ============================================
-- 玩家表
-- ============================================
CREATE TABLE IF NOT EXISTS players (
    id SERIAL PRIMARY KEY,
    playerid VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(64) NOT NULL,
    cash INTEGER DEFAULT 0,
    bankacc INTEGER DEFAULT 0,

    -- 管理员/权限等级
    adminlevel SMALLINT DEFAULT 0,
    designer_level SMALLINT DEFAULT 0,
    developer_level SMALLINT DEFAULT 0,
    civcouncil_level SMALLINT DEFAULT 0,
    restrictions_level SMALLINT DEFAULT 0,
    supportteam SMALLINT DEFAULT 0,

    -- 捐赠者状态
    newdonor VARCHAR(10) DEFAULT '0',

    -- 许可证 (存储为 JSON 数组)
    civ_licenses TEXT DEFAULT '[]',
    cop_licenses TEXT DEFAULT '[]',
    med_licenses TEXT DEFAULT '[]',

    -- 逮捕状态
    arrested SMALLINT DEFAULT 0,

    -- 装备 (存储为 JSON 数组)
    civ_gear TEXT DEFAULT '[]',
    cop_gear TEXT DEFAULT '[]',
    med_gear TEXT DEFAULT '[]',

    -- 别名
    aliases TEXT DEFAULT '[]',

    -- 玩家统计
    player_stats TEXT DEFAULT '[0,0,0,0,0,0,0,0,0,0]',

    -- 通缉状态
    wanted TEXT DEFAULT '[]',

    -- 坐标
    coordinates TEXT DEFAULT '[]',

    -- 警戒逮捕
    vigiarrests INTEGER DEFAULT 0,
    vigiarrests_stored INTEGER DEFAULT 0,

    -- 存款箱
    deposit_box TEXT DEFAULT '[]',

    -- 服务器跟踪
    last_server INTEGER DEFAULT 1,
    last_side VARCHAR(10) DEFAULT 'civ',
    last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- 战争击杀
    warkills INTEGER DEFAULT 0,
    current_title VARCHAR(100) DEFAULT '',

    -- 图标
    hex_icon TEXT DEFAULT '',
    hex_icon_redemptions INTEGER DEFAULT 0,

    -- 时间戳
    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_players_playerid ON players(playerid);
CREATE INDEX idx_players_name ON players(name);
CREATE INDEX idx_players_last_server ON players(last_server);

-- ============================================
-- 玩家统计表
-- ============================================
CREATE TABLE IF NOT EXISTS stats (
    id SERIAL PRIMARY KEY,
    playerid VARCHAR(50) NOT NULL UNIQUE,

    -- 击杀统计
    civ_kills INTEGER DEFAULT 0,
    cop_kills INTEGER DEFAULT 0,
    plane_kills INTEGER DEFAULT 0,
    cop_lethals INTEGER DEFAULT 0,

    -- 活动统计
    epipen INTEGER DEFAULT 0,
    lockpick_suc INTEGER DEFAULT 0,
    robberies INTEGER DEFAULT 0,
    prison_time INTEGER DEFAULT 0,
    sui_vest INTEGER DEFAULT 0,

    -- 毒品销售
    drugs_sold_cocaine INTEGER DEFAULT 0,
    drugs_sold_heroin INTEGER DEFAULT 0,
    drugs_sold_marijuana INTEGER DEFAULT 0,
    drugs_sold_lsd INTEGER DEFAULT 0,
    drugs_sold_meth INTEGER DEFAULT 0,

    -- 炸弹/AA
    bombs_planted INTEGER DEFAULT 0,
    AA_hacked INTEGER DEFAULT 0,

    -- 警察活动
    pardons INTEGER DEFAULT 0,
    cop_arrests INTEGER DEFAULT 0,
    tickets_issued_paid INTEGER DEFAULT 0,
    defuses INTEGER DEFAULT 0,
    donuts INTEGER DEFAULT 0,
    drugs_seized_currency INTEGER DEFAULT 0,

    -- 其他统计
    misc_stats TEXT DEFAULT '[]',

    FOREIGN KEY (playerid) REFERENCES players(playerid) ON DELETE CASCADE
);

CREATE INDEX idx_stats_playerid ON stats(playerid);

-- ============================================
-- 车辆表
-- ============================================
CREATE TABLE IF NOT EXISTS vehicles (
    id SERIAL PRIMARY KEY,
    side VARCHAR(10) NOT NULL DEFAULT 'civ',
    classname VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'Car',
    pid VARCHAR(50) NOT NULL,
    alive SMALLINT DEFAULT 1,
    active SMALLINT DEFAULT 0,
    plate VARCHAR(20) DEFAULT '',
    color INTEGER DEFAULT 0,
    insured SMALLINT DEFAULT 0,
    modifications TEXT DEFAULT '[]',
    customName VARCHAR(100) DEFAULT '',

    -- 服务器跟踪
    server INTEGER DEFAULT 1,

    -- 时间戳
    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (pid) REFERENCES players(playerid) ON DELETE CASCADE
);

CREATE INDEX idx_vehicles_pid ON vehicles(pid);
CREATE INDEX idx_vehicles_side ON vehicles(side);
CREATE INDEX idx_vehicles_alive ON vehicles(alive);
CREATE INDEX idx_vehicles_active ON vehicles(active);
CREATE INDEX idx_vehicles_server ON vehicles(server);

-- ============================================
-- 帮派车辆表
-- ============================================
CREATE TABLE IF NOT EXISTS gangvehicles (
    id SERIAL PRIMARY KEY,
    classname VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'Car',
    gang_id INTEGER NOT NULL,
    alive SMALLINT DEFAULT 1,
    active SMALLINT DEFAULT 0,
    plate VARCHAR(20) DEFAULT '',
    color INTEGER DEFAULT 0,
    insured SMALLINT DEFAULT 0,
    modifications TEXT DEFAULT '[]',
    customName VARCHAR(100) DEFAULT '',

    -- 服务器跟踪
    server INTEGER DEFAULT 1,

    -- 时间戳
    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_gangvehicles_gang_id ON gangvehicles(gang_id);
CREATE INDEX idx_gangvehicles_alive ON gangvehicles(alive);
CREATE INDEX idx_gangvehicles_server ON gangvehicles(server);

-- ============================================
-- 房屋表
-- ============================================
CREATE TABLE IF NOT EXISTS houses (
    id SERIAL PRIMARY KEY,
    pid VARCHAR(50) NOT NULL,
    pos TEXT NOT NULL,
    owned SMALLINT DEFAULT 1,
    server INTEGER DEFAULT 1,

    -- 存储
    trunk TEXT DEFAULT '[]',

    -- 房屋类型
    classname VARCHAR(100) DEFAULT '',

    -- 时间戳
    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (pid) REFERENCES players(playerid) ON DELETE CASCADE
);

CREATE INDEX idx_houses_pid ON houses(pid);
CREATE INDEX idx_houses_server ON houses(server);
CREATE INDEX idx_houses_owned ON houses(owned);

-- ============================================
-- 房屋钥匙表
-- ============================================
CREATE TABLE IF NOT EXISTS house_keys (
    id SERIAL PRIMARY KEY,
    houseid INTEGER NOT NULL,
    playerid VARCHAR(50) NOT NULL,

    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (houseid) REFERENCES houses(id) ON DELETE CASCADE,
    FOREIGN KEY (playerid) REFERENCES players(playerid) ON DELETE CASCADE
);

CREATE INDEX idx_house_keys_houseid ON house_keys(houseid);
CREATE INDEX idx_house_keys_playerid ON house_keys(playerid);

-- ============================================
-- 帮派成员表
-- ============================================
CREATE TABLE IF NOT EXISTS gangmembers (
    id SERIAL PRIMARY KEY,
    gangid INTEGER NOT NULL,
    gangname VARCHAR(100) NOT NULL,
    playerid VARCHAR(50) NOT NULL,
    rank SMALLINT DEFAULT 0,

    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (playerid) REFERENCES players(playerid) ON DELETE CASCADE
);

CREATE INDEX idx_gangmembers_gangid ON gangmembers(gangid);
CREATE INDEX idx_gangmembers_playerid ON gangmembers(playerid);
CREATE INDEX idx_gangmembers_gangname ON gangmembers(gangname);

-- ============================================
-- 帮派表 (账户)
-- ============================================
CREATE TABLE IF NOT EXISTS ganks (
    id SERIAL PRIMARY KEY,
    gangid INTEGER NOT NULL UNIQUE,
    gangname VARCHAR(100) NOT NULL,
    bank INTEGER DEFAULT 0,
    maxmembers INTEGER DEFAULT 8,

    -- 帮派统计
    kills INTEGER DEFAULT 0,
    deaths INTEGER DEFAULT 0,

    -- 时间戳
    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ganks_gangid ON ganks(gangid);
CREATE INDEX idx_ganks_gangname ON ganks(gangname);

-- ============================================
-- 帮派建筑表
-- ============================================
CREATE TABLE IF NOT EXISTS gangbldgs (
    id SERIAL PRIMARY KEY,
    gang_id INTEGER NOT NULL,
    pos TEXT NOT NULL,
    owned SMALLINT DEFAULT 1,
    server INTEGER DEFAULT 1,

    -- 存储
    trunk TEXT DEFAULT '[]',

    -- 油量
    oil INTEGER DEFAULT 0,

    -- 时间戳
    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_gangbldgs_gang_id ON gangbldgs(gang_id);
CREATE INDEX idx_gangbldgs_server ON gangbldgs(server);
CREATE INDEX idx_gangbldgs_owned ON gangbldgs(owned);

-- ============================================
-- 领土表
-- ============================================
CREATE TABLE IF NOT EXISTS territories (
    id SERIAL PRIMARY KEY,
    territory_name VARCHAR(100) NOT NULL,
    gang_id INTEGER DEFAULT 0,
    gang_name VARCHAR(100) DEFAULT '',
    capture_progress INTEGER DEFAULT 0,
    server INTEGER DEFAULT 1,

    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_territories_server ON territories(server);
CREATE INDEX idx_territories_gang_id ON territories(gang_id);

-- ============================================
-- 市场表
-- ============================================
CREATE TABLE IF NOT EXISTS market (
    id SERIAL PRIMARY KEY,
    reset SMALLINT DEFAULT 0,

    -- 物品价格 (可以根据需要添加更多列)
    item_prices TEXT DEFAULT '[]',

    -- 服务器
    server INTEGER DEFAULT 1,

    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_market_server ON market(server);

-- ============================================
-- 多玩家ID表 (用于检测小号)
-- ============================================
CREATE TABLE IF NOT EXISTS mpid (
    id SERIAL PRIMARY KEY,
    pids TEXT NOT NULL,

    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 征服赛程表
-- ============================================
CREATE TABLE IF NOT EXISTS conquest_schedule (
    id SERIAL PRIMARY KEY,
    server INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL,
    completed SMALLINT DEFAULT 0,
    cancelled SMALLINT DEFAULT 0,

    insert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conquest_schedule_server ON conquest_schedule(server);
CREATE INDEX idx_conquest_schedule_start_time ON conquest_schedule(start_time);
CREATE INDEX idx_conquest_schedule_completed ON conquest_schedule(completed);

-- ============================================
-- 征服记录表
-- ============================================
CREATE TABLE IF NOT EXISTS conquests (
    id SERIAL PRIMARY KEY,
    winner_id INTEGER DEFAULT 0,
    winner_name VARCHAR(100) DEFAULT '',
    date_started TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_ended TIMESTAMP,
    server INTEGER DEFAULT 1,

    -- 详细信息
    details TEXT DEFAULT '{}'
);

CREATE INDEX idx_conquests_winner_id ON conquests(winner_id);
CREATE INDEX idx_conquests_date_started ON conquests(date_started);
CREATE INDEX idx_conquests_server ON conquests(server);

-- ============================================
-- 服务器日志表
-- ============================================
CREATE TABLE IF NOT EXISTS server_logs (
    id SERIAL PRIMARY KEY,
    log_type VARCHAR(50) DEFAULT 'general',
    message TEXT,
    player_id VARCHAR(50),
    extra_data TEXT DEFAULT '{}',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_server_logs_type ON server_logs(log_type);
CREATE INDEX idx_server_logs_player_id ON server_logs(player_id);
CREATE INDEX idx_server_logs_created_at ON server_logs(created_at);

-- ============================================
-- 存储过程: 清理旧房屋
-- ============================================
CREATE OR REPLACE FUNCTION houseCleanup1() RETURNS void AS $$
BEGIN
    -- 删除超过30天未更新的房屋
    DELETE FROM houses
    WHERE last_updated < NOW() - INTERVAL '30 days'
    AND server = 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION houseCleanup2() RETURNS void AS $$
BEGIN
    DELETE FROM houses
    WHERE last_updated < NOW() - INTERVAL '30 days'
    AND server = 2;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 存储过程: 重置车辆
-- ============================================
CREATE OR REPLACE FUNCTION resetLifeVehicles1() RETURNS void AS $$
BEGIN
    UPDATE vehicles SET active = 0 WHERE server = 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION resetLifeVehicles2() RETURNS void AS $$
BEGIN
    UPDATE vehicles SET active = 0 WHERE server = 2;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 存储过程: 删除死亡车辆
-- ============================================
CREATE OR REPLACE FUNCTION deleteDeadVehicles() RETURNS void AS $$
BEGIN
    DELETE FROM vehicles WHERE alive = 0;
    DELETE FROM gangvehicles WHERE alive = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 存储过程: 删除旧帮派
-- ============================================
CREATE OR REPLACE FUNCTION deleteOldGangs() RETURNS void AS $$
BEGIN
    -- 删除没有成员的帮派
    DELETE FROM ganks
    WHERE gangid NOT IN (SELECT DISTINCT gangid FROM gangmembers);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 存储过程: 删除旧房屋
-- ============================================
CREATE OR REPLACE FUNCTION deleteOldHouses1() RETURNS void AS $$
BEGIN
    DELETE FROM houses
    WHERE last_updated < NOW() - INTERVAL '60 days'
    AND server = 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION deleteOldHouses2() RETURNS void AS $$
BEGIN
    DELETE FROM houses
    WHERE last_updated < NOW() - INTERVAL '60 days'
    AND server = 2;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 存储过程: 帮派建筑清理
-- ============================================
CREATE OR REPLACE FUNCTION gangBuildingCleanup() RETURNS void AS $$
BEGIN
    DELETE FROM gangbldgs
    WHERE last_updated < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 存储过程: 更新成员名称
-- ============================================
CREATE OR REPLACE FUNCTION updateMemberNames() RETURNS void AS $$
BEGIN
    -- 同步帮派成员名称与玩家表
    -- 这里需要根据实际需求实现
    NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 存储过程: 发放现金
-- ============================================
CREATE OR REPLACE FUNCTION giveCash() RETURNS void AS $$
BEGIN
    -- 占位符 - 根据需要实现
    NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 存储过程: 删除合同
-- ============================================
CREATE OR REPLACE FUNCTION deleteContracts() RETURNS void AS $$
BEGIN
    -- 占位符 - 根据需要实现
    NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 完成提示
-- ============================================
-- 执行完成后，请确保:
-- 1. 在 arma3-pgsql.ini 中配置正确的数据库连接信息
-- 2. 在 init.sqf 中将 life_db_backend 改为 "pgsql"
-- 3. 从 MySQL 导出数据并导入到这些表中 (如果需要迁移现有数据)
