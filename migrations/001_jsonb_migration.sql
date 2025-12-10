-- ============================================
-- JSONB Migration Script for Arma 3 Life Server
-- PostgreSQL Version: 12+
-- ============================================

-- 开始事务
BEGIN;

-- ============================================
-- 阶段 1: 创建备份表
-- ============================================

DROP TABLE IF EXISTS players_backup_jsonb;
DROP TABLE IF EXISTS vehicles_backup_jsonb;
DROP TABLE IF EXISTS gangvehicles_backup_jsonb;
DROP TABLE IF EXISTS houses_backup_jsonb;
DROP TABLE IF EXISTS gangbldgs_backup_jsonb;

CREATE TABLE players_backup_jsonb AS SELECT * FROM players;
CREATE TABLE vehicles_backup_jsonb AS SELECT * FROM vehicles;
CREATE TABLE gangvehicles_backup_jsonb AS SELECT * FROM gangvehicles;
CREATE TABLE houses_backup_jsonb AS SELECT * FROM houses;
CREATE TABLE gangbldgs_backup_jsonb AS SELECT * FROM gangbldgs;

-- ============================================
-- 阶段 2: 创建 SQF 到 JSON 转换函数
-- ============================================

-- 函数: 将 SQF 数组字符串转换为 JSONB
-- SQF str() 输出: ["a","b"] 会变成 [""a"",""b""]
-- 我们需要: ["a","b"]
CREATE OR REPLACE FUNCTION sqf_to_jsonb(sqf_text TEXT)
RETURNS JSONB AS $$
DECLARE
    cleaned TEXT;
BEGIN
    -- 空值或空字符串处理
    IF sqf_text IS NULL OR sqf_text = '' OR sqf_text = '[]' OR sqf_text = '""[]""' THEN
        RETURN '[]'::jsonb;
    END IF;

    -- 移除可能存在的外层引号包裹 (如 "[]")
    cleaned := sqf_text;

    -- 处理 SQF 特殊的双引号转义
    -- SQF: [""name""] -> JSON: ["name"]
    -- 首先替换 "" 为临时占位符，然后替换为 "
    cleaned := REPLACE(cleaned, '""', '"');

    -- 如果字符串以单引号开始（SQF 格式），转换为双引号
    -- SQF: ['name'] -> JSON: ["name"]
    cleaned := REPLACE(cleaned, '''', '"');

    -- 尝试解析为 JSONB
    BEGIN
        RETURN cleaned::jsonb;
    EXCEPTION WHEN OTHERS THEN
        -- 如果解析失败，返回空数组
        RAISE NOTICE 'Failed to parse SQF to JSONB: %', sqf_text;
        RETURN '[]'::jsonb;
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 函数: 将 JSONB 转换为 SQF 兼容的字符串
-- 这个函数用于向后兼容，当需要输出旧格式时使用
CREATE OR REPLACE FUNCTION jsonb_to_sqf(json_data JSONB)
RETURNS TEXT AS $$
BEGIN
    IF json_data IS NULL THEN
        RETURN '[]';
    END IF;

    -- JSONB 转为文本后，将 " 替换为 ""（SQF 格式）
    RETURN REPLACE(json_data::text, '"', '""');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- 阶段 3: 添加 JSONB 列到 players 表
-- ============================================

-- 检查并添加列（避免重复添加）
DO $$
BEGIN
    -- civ_gear_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'civ_gear_json') THEN
        ALTER TABLE players ADD COLUMN civ_gear_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- cop_gear_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'cop_gear_json') THEN
        ALTER TABLE players ADD COLUMN cop_gear_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- med_gear_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'med_gear_json') THEN
        ALTER TABLE players ADD COLUMN med_gear_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- civ_licenses_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'civ_licenses_json') THEN
        ALTER TABLE players ADD COLUMN civ_licenses_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- cop_licenses_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'cop_licenses_json') THEN
        ALTER TABLE players ADD COLUMN cop_licenses_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- med_licenses_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'med_licenses_json') THEN
        ALTER TABLE players ADD COLUMN med_licenses_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- coordinates_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'coordinates_json') THEN
        ALTER TABLE players ADD COLUMN coordinates_json JSONB DEFAULT '[0,0,0]'::jsonb;
    END IF;

    -- player_stats_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'player_stats_json') THEN
        ALTER TABLE players ADD COLUMN player_stats_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- wanted_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'wanted_json') THEN
        ALTER TABLE players ADD COLUMN wanted_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- aliases_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'aliases_json') THEN
        ALTER TABLE players ADD COLUMN aliases_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- arrested_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'players' AND column_name = 'arrested_json') THEN
        ALTER TABLE players ADD COLUMN arrested_json JSONB DEFAULT '[0,0,0]'::jsonb;
    END IF;
END $$;

-- ============================================
-- 阶段 4: 添加 JSONB 列到 vehicles 表
-- ============================================

DO $$
BEGIN
    -- color_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'vehicles' AND column_name = 'color_json') THEN
        ALTER TABLE vehicles ADD COLUMN color_json JSONB DEFAULT '[-1,0]'::jsonb;
    END IF;

    -- inventory_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'vehicles' AND column_name = 'inventory_json') THEN
        ALTER TABLE vehicles ADD COLUMN inventory_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- modifications_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'vehicles' AND column_name = 'modifications_json') THEN
        ALTER TABLE vehicles ADD COLUMN modifications_json JSONB DEFAULT '[0,0,0,0,0,0,0,0]'::jsonb;
    END IF;

    -- persistentposition_json
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'vehicles' AND column_name = 'persistentposition_json') THEN
        ALTER TABLE vehicles ADD COLUMN persistentposition_json JSONB DEFAULT '[0,0,0]'::jsonb;
    END IF;
END $$;

-- ============================================
-- 阶段 5: 添加 JSONB 列到 gangvehicles 表
-- ============================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'gangvehicles' AND column_name = 'color_json') THEN
        ALTER TABLE gangvehicles ADD COLUMN color_json JSONB DEFAULT '[-1,0]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'gangvehicles' AND column_name = 'inventory_json') THEN
        ALTER TABLE gangvehicles ADD COLUMN inventory_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'gangvehicles' AND column_name = 'modifications_json') THEN
        ALTER TABLE gangvehicles ADD COLUMN modifications_json JSONB DEFAULT '[0,0,0,0,0,0,0,0]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'gangvehicles' AND column_name = 'persistentposition_json') THEN
        ALTER TABLE gangvehicles ADD COLUMN persistentposition_json JSONB DEFAULT '[0,0,0]'::jsonb;
    END IF;
END $$;

-- ============================================
-- 阶段 6: 添加 JSONB 列到 houses 表
-- ============================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'houses' AND column_name = 'inventory_json') THEN
        ALTER TABLE houses ADD COLUMN inventory_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'houses' AND column_name = 'physical_inventory_json') THEN
        ALTER TABLE houses ADD COLUMN physical_inventory_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'houses' AND column_name = 'player_keys_json') THEN
        ALTER TABLE houses ADD COLUMN player_keys_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'houses' AND column_name = 'phys_comp_json') THEN
        ALTER TABLE houses ADD COLUMN phys_comp_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'houses' AND column_name = 'virt_comp_json') THEN
        ALTER TABLE houses ADD COLUMN virt_comp_json JSONB DEFAULT '[]'::jsonb;
    END IF;
END $$;

-- ============================================
-- 阶段 7: 添加 JSONB 列到 gangbldgs 表
-- ============================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'gangbldgs' AND column_name = 'inventory_json') THEN
        ALTER TABLE gangbldgs ADD COLUMN inventory_json JSONB DEFAULT '[]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'gangbldgs' AND column_name = 'physical_inventory_json') THEN
        ALTER TABLE gangbldgs ADD COLUMN physical_inventory_json JSONB DEFAULT '[]'::jsonb;
    END IF;
END $$;

COMMIT;

-- ============================================
-- 数据迁移（在单独的事务中执行）
-- ============================================

-- 注意：这部分需要单独执行，以便控制批量大小

-- Players 表数据迁移
UPDATE players SET
    civ_gear_json = sqf_to_jsonb(civ_gear),
    cop_gear_json = sqf_to_jsonb(cop_gear),
    med_gear_json = sqf_to_jsonb(med_gear),
    civ_licenses_json = sqf_to_jsonb(civ_licenses),
    cop_licenses_json = sqf_to_jsonb(cop_licenses),
    med_licenses_json = sqf_to_jsonb(med_licenses),
    coordinates_json = sqf_to_jsonb(coordinates),
    player_stats_json = sqf_to_jsonb(player_stats),
    wanted_json = sqf_to_jsonb(wanted),
    aliases_json = sqf_to_jsonb(aliases),
    arrested_json = sqf_to_jsonb(arrested)
WHERE civ_gear_json = '[]'::jsonb OR civ_gear_json IS NULL;

-- Vehicles 表数据迁移
UPDATE vehicles SET
    color_json = sqf_to_jsonb(color),
    inventory_json = sqf_to_jsonb(inventory),
    modifications_json = sqf_to_jsonb(modifications),
    persistentposition_json = sqf_to_jsonb(persistentposition)
WHERE color_json = '[-1,0]'::jsonb OR color_json IS NULL;

-- Gangvehicles 表数据迁移
UPDATE gangvehicles SET
    color_json = sqf_to_jsonb(color),
    inventory_json = sqf_to_jsonb(inventory),
    modifications_json = sqf_to_jsonb(modifications),
    persistentposition_json = sqf_to_jsonb(persistentposition)
WHERE color_json = '[-1,0]'::jsonb OR color_json IS NULL;

-- Houses 表数据迁移
UPDATE houses SET
    inventory_json = sqf_to_jsonb(inventory),
    physical_inventory_json = sqf_to_jsonb(physical_inventory),
    player_keys_json = sqf_to_jsonb(player_keys),
    phys_comp_json = sqf_to_jsonb(phys_comp),
    virt_comp_json = sqf_to_jsonb(virt_comp)
WHERE inventory_json = '[]'::jsonb OR inventory_json IS NULL;

-- Gangbldgs 表数据迁移
UPDATE gangbldgs SET
    inventory_json = sqf_to_jsonb(inventory),
    physical_inventory_json = sqf_to_jsonb(physical_inventory)
WHERE inventory_json = '[]'::jsonb OR inventory_json IS NULL;

-- ============================================
-- 验证迁移结果
-- ============================================

-- 检查 players 表
SELECT
    'players' as table_name,
    COUNT(*) as total_rows,
    COUNT(CASE WHEN civ_gear_json != '[]'::jsonb THEN 1 END) as migrated_gear,
    COUNT(CASE WHEN civ_licenses_json != '[]'::jsonb THEN 1 END) as migrated_licenses
FROM players;

-- 检查 vehicles 表
SELECT
    'vehicles' as table_name,
    COUNT(*) as total_rows,
    COUNT(CASE WHEN color_json != '[-1,0]'::jsonb THEN 1 END) as migrated_color,
    COUNT(CASE WHEN modifications_json != '[0,0,0,0,0,0,0,0]'::jsonb THEN 1 END) as migrated_mods
FROM vehicles;

-- 检查 houses 表
SELECT
    'houses' as table_name,
    COUNT(*) as total_rows,
    COUNT(CASE WHEN inventory_json != '[]'::jsonb THEN 1 END) as migrated_inventory
FROM houses;

-- 查看示例数据对比
SELECT
    playerid,
    LEFT(civ_gear, 50) as old_gear,
    LEFT(civ_gear_json::text, 50) as new_gear_json
FROM players
WHERE civ_gear IS NOT NULL AND civ_gear != ''
LIMIT 5;
