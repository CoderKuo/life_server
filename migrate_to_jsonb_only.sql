-- ============================================
-- 迁移脚本：从双写模式切换到纯 JSONB 模式
-- 执行前请确保已备份数据库！
-- ============================================

-- 步骤 1: 备份当前表结构（可选，用于回滚）
-- pg_dump -U postgres -d arma3 -t players -t vehicles -t gangvehicles -t houses -t gangbldgs > backup_before_jsonb_migration.sql

BEGIN;

-- ============================================
-- Players 表
-- ============================================

-- 删除旧的 TEXT 列，重命名 JSONB 列
ALTER TABLE players DROP COLUMN IF EXISTS civ_licenses;
ALTER TABLE players RENAME COLUMN civ_licenses_json TO civ_licenses;

ALTER TABLE players DROP COLUMN IF EXISTS cop_licenses;
ALTER TABLE players RENAME COLUMN cop_licenses_json TO cop_licenses;

ALTER TABLE players DROP COLUMN IF EXISTS med_licenses;
ALTER TABLE players RENAME COLUMN med_licenses_json TO med_licenses;

ALTER TABLE players DROP COLUMN IF EXISTS civ_gear;
ALTER TABLE players RENAME COLUMN civ_gear_json TO civ_gear;

ALTER TABLE players DROP COLUMN IF EXISTS cop_gear;
ALTER TABLE players RENAME COLUMN cop_gear_json TO cop_gear;

ALTER TABLE players DROP COLUMN IF EXISTS med_gear;
ALTER TABLE players RENAME COLUMN med_gear_json TO med_gear;

ALTER TABLE players DROP COLUMN IF EXISTS coordinates;
ALTER TABLE players RENAME COLUMN coordinates_json TO coordinates;

ALTER TABLE players DROP COLUMN IF EXISTS aliases;
ALTER TABLE players RENAME COLUMN aliases_json TO aliases;

ALTER TABLE players DROP COLUMN IF EXISTS player_stats;
ALTER TABLE players RENAME COLUMN player_stats_json TO player_stats;

ALTER TABLE players DROP COLUMN IF EXISTS wanted;
ALTER TABLE players RENAME COLUMN wanted_json TO wanted;

ALTER TABLE players DROP COLUMN IF EXISTS arrested;
ALTER TABLE players RENAME COLUMN arrested_json TO arrested;

-- ============================================
-- Vehicles 表
-- ============================================

ALTER TABLE vehicles DROP COLUMN IF EXISTS color;
ALTER TABLE vehicles RENAME COLUMN color_json TO color;

ALTER TABLE vehicles DROP COLUMN IF EXISTS inventory;
ALTER TABLE vehicles RENAME COLUMN inventory_json TO inventory;

ALTER TABLE vehicles DROP COLUMN IF EXISTS modifications;
ALTER TABLE vehicles RENAME COLUMN modifications_json TO modifications;

ALTER TABLE vehicles DROP COLUMN IF EXISTS persistentposition;
ALTER TABLE vehicles RENAME COLUMN persistentposition_json TO persistentposition;

-- ============================================
-- Gang Vehicles 表
-- ============================================

ALTER TABLE gangvehicles DROP COLUMN IF EXISTS color;
ALTER TABLE gangvehicles RENAME COLUMN color_json TO color;

ALTER TABLE gangvehicles DROP COLUMN IF EXISTS inventory;
ALTER TABLE gangvehicles RENAME COLUMN inventory_json TO inventory;

ALTER TABLE gangvehicles DROP COLUMN IF EXISTS modifications;
ALTER TABLE gangvehicles RENAME COLUMN modifications_json TO modifications;

ALTER TABLE gangvehicles DROP COLUMN IF EXISTS persistentposition;
ALTER TABLE gangvehicles RENAME COLUMN persistentposition_json TO persistentposition;

-- ============================================
-- Houses 表
-- ============================================

ALTER TABLE houses DROP COLUMN IF EXISTS inventory;
ALTER TABLE houses RENAME COLUMN inventory_json TO inventory;

ALTER TABLE houses DROP COLUMN IF EXISTS player_keys;
ALTER TABLE houses RENAME COLUMN player_keys_json TO player_keys;

ALTER TABLE houses DROP COLUMN IF EXISTS physical_inventory;
ALTER TABLE houses RENAME COLUMN physical_inventory_json TO physical_inventory;

ALTER TABLE houses DROP COLUMN IF EXISTS phys_comp;
ALTER TABLE houses RENAME COLUMN phys_comp_json TO phys_comp;

ALTER TABLE houses DROP COLUMN IF EXISTS virt_comp;
ALTER TABLE houses RENAME COLUMN virt_comp_json TO virt_comp;

-- ============================================
-- Gang Buildings 表
-- ============================================

ALTER TABLE gangbldgs DROP COLUMN IF EXISTS inventory;
ALTER TABLE gangbldgs RENAME COLUMN inventory_json TO inventory;

ALTER TABLE gangbldgs DROP COLUMN IF EXISTS physical_inventory;
ALTER TABLE gangbldgs RENAME COLUMN physical_inventory_json TO physical_inventory;

COMMIT;

-- ============================================
-- 验证迁移结果
-- ============================================

-- 检查 players 表列类型
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'players'
AND column_name IN ('civ_licenses', 'cop_licenses', 'med_licenses', 'civ_gear', 'cop_gear', 'med_gear', 'coordinates', 'aliases', 'player_stats', 'wanted', 'arrested');

-- 检查 vehicles 表列类型
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'vehicles'
AND column_name IN ('color', 'inventory', 'modifications', 'persistentposition');

SELECT '迁移完成！所有列现在都是 JSONB 类型。' AS status;
