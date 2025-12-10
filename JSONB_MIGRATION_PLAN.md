# PostgreSQL JSONB 迁移计划

## 1. 当前状态分析

### 1.1 问题描述
当前数据库使用 TEXT 类型存储 SQF 数组的字符串表示形式，例如：
```sql
-- 当前格式 (TEXT)
civ_gear = "['U_C_Man_casual_4_F',',',',',['ItemMap'],',',',[],[],[],[],[',',','],[',',','],[[],0]]"
civ_licenses = "[['license_civ_driver',1],['license_civ_air',0],...]"
coordinates = "[3669,13106,0]"
```

**存在的问题：**
1. **数据损坏风险**：SQF 字符串转义与 SQL 转义冲突，导致数据格式错误（如 `','` 替代了正确数据）
2. **无法查询内部数据**：无法在 SQL 层面查询数组内的特定元素
3. **转义复杂**：需要双重转义（`""` 转 `''`），容易出错
4. **调试困难**：字符串格式难以阅读和验证

### 1.2 受影响的表和字段

| 表名 | 字段名 | 当前类型 | 数据示例 |
|------|--------|----------|----------|
| **players** | civ_gear, cop_gear, med_gear | TEXT | SQF 装备数组 |
| | civ_licenses, cop_licenses, med_licenses | TEXT | 许可证数组 |
| | coordinates, coordinates_tanoa | TEXT | 坐标 [x,y,z] |
| | player_stats | TEXT | 统计数组 |
| | wanted | TEXT | 通缉犯罪数组 |
| | aliases | TEXT | 别名数组 |
| | arrested | TEXT | 逮捕状态 |
| **vehicles** | color | TEXT | 颜色数组 ["Red",0] |
| | inventory | TEXT | 库存数组 |
| | modifications | TEXT | 改装数组 |
| | persistentposition | TEXT | 位置坐标 |
| **gangvehicles** | (同 vehicles) | TEXT | |
| **houses** | inventory | TEXT | 虚拟库存 |
| | physical_inventory | TEXT | 物理库存 |
| | player_keys | VARCHAR(500) | 钥匙持有者数组 |
| | phys_comp, virt_comp | TEXT | 组件数据 |
| **gangbldgs** | inventory, physical_inventory | TEXT | 帮派建筑库存 |
| **gangs** | (无数组字段) | - | |
| **gangmembers** | (无数组字段) | - | |

---

## 2. JSONB 迁移方案

### 2.1 为什么选择 JSONB

| 特性 | TEXT (当前) | JSONB (目标) |
|------|-------------|--------------|
| 存储格式 | 原始字符串 | 二进制 JSON |
| 查询能力 | 仅全文匹配 | 支持路径查询、索引 |
| 数据验证 | 无 | 自动验证 JSON 语法 |
| 空间效率 | 一般 | 更紧凑 |
| 索引支持 | 无 | GIN 索引 |

### 2.2 SQF 数组与 JSON 的映射

```
SQF 格式                          JSON 格式
---------                         -----------
[1,2,3]                    →      [1,2,3]
["a","b"]                  →      ["a","b"]
[["key",1],["key2",0]]     →      [["key",1],["key2",0]]
                                  或 {"key":1,"key2":0}  (可选优化)
```

**关键发现：SQF 数组语法与 JSON 数组语法几乎相同！**
- 两者都使用 `[]` 表示数组
- 两者都使用 `,` 分隔元素
- 主要区别：SQF 字符串使用单引号 `'`，JSON 使用双引号 `"`

### 2.3 数据转换函数

需要创建转换函数将 SQF 格式转为 JSON：

```sql
-- 创建 SQF 到 JSON 的转换函数
CREATE OR REPLACE FUNCTION sqf_to_jsonb(sqf_text TEXT)
RETURNS JSONB AS $$
BEGIN
    IF sqf_text IS NULL OR sqf_text = '' OR sqf_text = '[]' THEN
        RETURN '[]'::jsonb;
    END IF;

    -- 将 SQF 单引号转换为 JSON 双引号
    -- 注意：需要处理嵌套引号
    RETURN sqf_text
        ::text
        -- 替换 SQF 单引号为 JSON 双引号
        -- 这是简化版，实际可能需要更复杂的正则
        REPLACE('''', '"')
        ::jsonb;
EXCEPTION WHEN OTHERS THEN
    -- 转换失败时返回空数组
    RETURN '[]'::jsonb;
END;
$$ LANGUAGE plpgsql;
```

---

## 3. 实施步骤

### 阶段 1: 数据库结构迁移 (DDL)

```sql
-- 1. 备份现有数据
CREATE TABLE players_backup AS SELECT * FROM players;
CREATE TABLE vehicles_backup AS SELECT * FROM vehicles;
CREATE TABLE houses_backup AS SELECT * FROM houses;
CREATE TABLE gangbldgs_backup AS SELECT * FROM gangbldgs;
CREATE TABLE gangvehicles_backup AS SELECT * FROM gangvehicles;

-- 2. 添加新的 JSONB 列
ALTER TABLE players
    ADD COLUMN civ_gear_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN cop_gear_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN med_gear_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN civ_licenses_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN cop_licenses_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN med_licenses_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN coordinates_json JSONB DEFAULT '[0,0,0]'::jsonb,
    ADD COLUMN player_stats_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN wanted_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN aliases_json JSONB DEFAULT '[]'::jsonb;

ALTER TABLE vehicles
    ADD COLUMN color_json JSONB DEFAULT '[-1,0]'::jsonb,
    ADD COLUMN inventory_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN modifications_json JSONB DEFAULT '[0,0,0,0,0,0,0,0]'::jsonb,
    ADD COLUMN persistentposition_json JSONB DEFAULT '[0,0,0]'::jsonb;

ALTER TABLE houses
    ADD COLUMN inventory_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN physical_inventory_json JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN player_keys_json JSONB DEFAULT '[]'::jsonb;

-- 3. 数据迁移 (使用转换函数)
UPDATE players SET
    civ_gear_json = sqf_to_jsonb(civ_gear),
    civ_licenses_json = sqf_to_jsonb(civ_licenses),
    coordinates_json = sqf_to_jsonb(coordinates),
    player_stats_json = sqf_to_jsonb(player_stats),
    wanted_json = sqf_to_jsonb(wanted),
    aliases_json = sqf_to_jsonb(aliases)
WHERE civ_gear IS NOT NULL AND civ_gear != '';

-- 4. 验证迁移结果
SELECT playerid,
       civ_gear,
       civ_gear_json,
       civ_gear_json IS NOT NULL AS valid_json
FROM players
WHERE civ_gear != ''
LIMIT 10;

-- 5. 切换列名 (可选，或在应用层处理)
-- ALTER TABLE players RENAME COLUMN civ_gear TO civ_gear_old;
-- ALTER TABLE players RENAME COLUMN civ_gear_json TO civ_gear;
```

### 阶段 2: SQF 代码适配

#### 2.1 创建 JSONB 序列化函数

```sqf
// fn_arrayToJson.sqf
// 将 SQF 数组转换为 JSON 字符串（用于存储）
params [["_array", [], [[]]]];

// SQF str 函数生成的格式: ["a","b"] (双引号)
// 这恰好就是 JSON 格式！
private _json = str _array;

// 返回 JSON 字符串
_json
```

#### 2.2 创建 JSONB 反序列化函数

```sqf
// fn_jsonToArray.sqf
// 将 JSON 字符串转换为 SQF 数组
params [["_json", "[]", [""]]];

// parseSimpleArray 可以直接解析 JSON 数组格式
private _array = parseSimpleArray _json;

if (isNil "_array") then {
    _array = [];
};

_array
```

#### 2.3 修改 Mapper 层

```sqf
// fn_playerMapper.sqf 示例修改

case "updatebank": {
    _params params [
        ["_pid", "", [""]],
        ["_value", "", [""]]
    ];
    // 使用参数化查询，无需转义
    private _sql = "UPDATE players SET bankacc=$1 WHERE playerid=$2";
    _result = [2, "player_update_bank", _sql, [_value, _pid]] call DB_fnc_dbExecute;
};

case "updategear": {
    _params params [
        ["_pid", "", [""]],
        ["_gear", [], [[]]]  // 直接接收数组
    ];
    // 将数组转为 JSON 字符串
    private _gearJson = str _gear;  // SQF str 生成的就是 JSON 格式
    private _sql = "UPDATE players SET civ_gear_json=$1::jsonb WHERE playerid=$2";
    _result = [2, "player_update_gear", _sql, [_gearJson, _pid]] call DB_fnc_dbExecute;
};
```

#### 2.4 修改 asyncCall 返回值处理

arma3_pgsql 扩展返回 JSONB 时，会返回 JSON 字符串，需要用 `parseSimpleArray` 解析：

```sqf
// fn_asyncCall_pgsql.sqf 修改
// 处理 JSONB 返回值
if (_queryResult isEqualType "") then {
    _queryResult = parseSimpleArray _queryResult;
};
```

### 阶段 3: 平滑过渡策略

为了最小化停机时间，建议采用以下策略：

1. **双写模式**：同时写入旧列和新列
2. **读取优先新列**：优先读取 JSONB 列，如果为空则回退到旧列
3. **完全切换**：验证无误后删除旧列

```sqf
// 示例：双写模式
case "updategear": {
    _params params [
        ["_pid", "", [""]],
        ["_gear", [], [[]]]
    ];
    private _gearJson = str _gear;
    private _gearOld = [_gear] call OES_fnc_escapeArray;  // 旧格式

    // 同时更新两个列
    private _sql = format [
        "UPDATE players SET civ_gear='%1', civ_gear_json='%2'::jsonb WHERE playerid='%3'",
        _gearOld, _gearJson, _pid
    ];
    _result = [2, "player_update_gear", _sql, []] call DB_fnc_dbExecute;
};
```

---

## 4. JSONB 查询示例

迁移后可以使用强大的 JSONB 查询功能：

```sql
-- 查询拥有特定许可证的玩家
SELECT playerid, name
FROM players
WHERE civ_licenses_json @> '[["license_civ_rebel", 1]]'::jsonb;

-- 查询在特定区域的玩家
SELECT playerid, name, coordinates_json
FROM players
WHERE (coordinates_json->0)::int BETWEEN 3000 AND 4000
  AND (coordinates_json->1)::int BETWEEN 13000 AND 14000;

-- 查询拥有特定装备的玩家
SELECT playerid, name
FROM players
WHERE civ_gear_json->0 = '"U_C_Poloshirt_redwhite"';

-- 统计各类许可证持有数量
SELECT
    license->0 as license_name,
    COUNT(*) as holders
FROM players, jsonb_array_elements(civ_licenses_json) as license
WHERE license->1 = '1'
GROUP BY license->0;
```

---

## 5. 创建 GIN 索引 (可选优化)

```sql
-- 为常用查询创建索引
CREATE INDEX idx_players_civ_licenses_gin ON players USING GIN (civ_licenses_json);
CREATE INDEX idx_players_coordinates_gin ON players USING GIN (coordinates_json);
CREATE INDEX idx_vehicles_inventory_gin ON vehicles USING GIN (inventory_json);
```

---

## 6. 风险与注意事项

### 6.1 风险
1. **数据丢失**：转换过程中格式错误的数据可能丢失
2. **性能影响**：大量数据迁移可能影响服务器性能
3. **兼容性**：需要同时更新客户端和服务器代码

### 6.2 缓解措施
1. **完整备份**：迁移前备份所有相关表
2. **分批迁移**：按玩家ID范围分批处理
3. **验证脚本**：编写验证脚本检查数据完整性
4. **回滚计划**：保留旧列直到确认无误

### 6.3 测试清单
- [ ] 单元测试：SQF 数组与 JSON 互转
- [ ] 集成测试：完整的登录->游戏->保存流程
- [ ] 性能测试：大数据量下的查询性能
- [ ] 回滚测试：验证可以恢复到旧格式

---

## 7. 时间线建议

| 阶段 | 任务 | 依赖 |
|------|------|------|
| 1 | 创建备份和转换函数 | - |
| 2 | 添加 JSONB 列 | 1 |
| 3 | 迁移现有数据 | 2 |
| 4 | 修改 SQF Mapper 层 | 3 |
| 5 | 测试双写模式 | 4 |
| 6 | 切换到仅读 JSONB | 5 |
| 7 | 删除旧 TEXT 列 | 6 验证通过后 |

---

## 8. 附录：SQF 与 JSON 格式对照表

| SQF 表达式 | str(_) 输出 | JSON 等效 | 需要转换 |
|------------|-------------|-----------|----------|
| `[]` | `"[]"` | `[]` | 否 |
| `[1,2,3]` | `"[1,2,3]"` | `[1,2,3]` | 否 |
| `["a","b"]` | `"[""a"",""b""]"` | `["a","b"]` | 是 (""→") |
| `[[1,2],[3,4]]` | `"[[1,2],[3,4]]"` | `[[1,2],[3,4]]` | 否 |
| `[["k",1]]` | `"[[""k"",1]]"` | `[["k",1]]` | 是 |

**结论**：SQF 的 `str` 函数对字符串使用双引号并转义，需要处理 `""` → `"` 的转换。
