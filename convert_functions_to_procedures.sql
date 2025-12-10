-- 将所有 FUNCTION 转换为 PROCEDURE
-- PostgreSQL 中 CALL 语法只能用于 PROCEDURE

-- ============================================
-- 第一步：删除所有旧的 FUNCTION
-- ============================================

DROP FUNCTION IF EXISTS deletecontracts();
DROP FUNCTION IF EXISTS deletedeadvehicles();
DROP FUNCTION IF EXISTS deleteoldgangs();
DROP FUNCTION IF EXISTS deleteoldhouses1();
DROP FUNCTION IF EXISTS deleteoldhouses2();
DROP FUNCTION IF EXISTS deleteoldhouses3();
DROP FUNCTION IF EXISTS gangbuildingcleanup();
DROP FUNCTION IF EXISTS givecash();
DROP FUNCTION IF EXISTS housecleanup1();
DROP FUNCTION IF EXISTS housecleanup2();
DROP FUNCTION IF EXISTS housecleanup3();
DROP FUNCTION IF EXISTS resetlifevehicles1();
DROP FUNCTION IF EXISTS resetlifevehicles2();
DROP FUNCTION IF EXISTS resetlifevehicles3();
DROP FUNCTION IF EXISTS updatemembernames();
DROP FUNCTION IF EXISTS setzonekill(character varying, character varying);
DROP FUNCTION IF EXISTS setwarstats(character varying, character varying, integer, integer, integer, integer, smallint);
DROP FUNCTION IF EXISTS itworkslol();
-- insertstatm 和 selectmax 保留为 FUNCTION，因为它们有参数或返回值

-- ============================================
-- 第二步：创建新的 PROCEDURE
-- ============================================

-- 1. deleteContracts
CREATE OR REPLACE PROCEDURE deleteContracts()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM hitman WHERE active = 0;
END;
$$;

-- 2. deleteDeadVehicles
CREATE OR REPLACE PROCEDURE deleteDeadVehicles()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM vehicles WHERE alive = 0;
END;
$$;

-- 3. deleteOldGangs
CREATE OR REPLACE PROCEDURE deleteOldGangs()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM gangs WHERE active = 0;
    DELETE FROM gangmembers WHERE gangid = -1 AND rank = -1;
END;
$$;

-- 4. deleteOldHouses1
CREATE OR REPLACE PROCEDURE deleteOldHouses1()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM houses
    WHERE server = 1
      AND EXTRACT(DAY FROM (CURRENT_TIMESTAMP - last_active)) > 45;
END;
$$;

-- 5. deleteOldHouses2
CREATE OR REPLACE PROCEDURE deleteOldHouses2()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM houses
    WHERE server = 2
      AND EXTRACT(DAY FROM (CURRENT_TIMESTAMP - last_active)) > 45;
END;
$$;

-- 6. deleteOldHouses3
CREATE OR REPLACE PROCEDURE deleteOldHouses3()
LANGUAGE plpgsql AS $$
BEGIN
    -- 空操作
END;
$$;

-- 7. gangBuildingCleanup
CREATE OR REPLACE PROCEDURE gangBuildingCleanup()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE gangbldgs
    SET owned = 0
    WHERE nextpayment < CURRENT_TIMESTAMP
      AND paystatus = 0
      AND server != 3;

    UPDATE gangbldgs
    SET paystatus = paystatus - 1,
        nextpayment = CURRENT_TIMESTAMP + INTERVAL '31 days'
    WHERE nextpayment < CURRENT_TIMESTAMP
      AND paystatus > 0;
END;
$$;

-- 8. giveCash
CREATE OR REPLACE PROCEDURE giveCash()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE players
    SET bankacc = 24699
    WHERE bankacc < 10000 AND cash < 5000;
END;
$$;

-- 9. houseCleanup1
CREATE OR REPLACE PROCEDURE houseCleanup1()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM houses WHERE server = 1 AND owned = 0;
    DELETE FROM gangbldgs WHERE owned = 0 AND server = 1;
END;
$$;

-- 10. houseCleanup2
CREATE OR REPLACE PROCEDURE houseCleanup2()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM houses WHERE server = 2 AND owned = 0;
    DELETE FROM gangbldgs WHERE owned = 0 AND server = 2;
END;
$$;

-- 11. houseCleanup3
CREATE OR REPLACE PROCEDURE houseCleanup3()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM houses WHERE server = 3 AND owned = 0;
    DELETE FROM gangbldgs WHERE owned = 0 AND server = 3;
END;
$$;

-- 12. resetLifeVehicles1
CREATE OR REPLACE PROCEDURE resetLifeVehicles1()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE vehicles SET active = 0 WHERE active = 1 AND alive = 1;
END;
$$;

-- 13. resetLifeVehicles2
CREATE OR REPLACE PROCEDURE resetLifeVehicles2()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE vehicles SET active = 0 WHERE active = 2 AND alive = 1;
END;
$$;

-- 14. resetLifeVehicles3
CREATE OR REPLACE PROCEDURE resetLifeVehicles3()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE vehicles SET active = 0 WHERE active = 3 AND alive = 1;
END;
$$;

-- 15. updateMemberNames
CREATE OR REPLACE PROCEDURE updateMemberNames()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE gangmembers gm
    SET name = p.name
    FROM players p
    WHERE gm.playerid = p.playerid;
END;
$$;

-- 16. setZoneKill
CREATE OR REPLACE PROCEDURE setZoneKill(killerUID VARCHAR, victimUID VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE players SET warpts = warpts + 1 WHERE playerid = killerUID;
    UPDATE players SET warpts = warpts - 1 WHERE playerid = victimUID AND warpts >= 1;
END;
$$;

-- 17. setWarStats
CREATE OR REPLACE PROCEDURE setWarStats(
    killerUID VARCHAR,
    victimUID VARCHAR,
    killerGID INTEGER,
    victimGID INTEGER,
    killerFinal INTEGER,
    victimFinal INTEGER,
    initGang SMALLINT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE players
    SET warpts = warpts + killerFinal,
        warkills = warkills + 1
    WHERE playerid = killerUID;

    UPDATE players
    SET warpts = warpts - victimFinal,
        wardeaths = wardeaths + 1
    WHERE playerid = victimUID AND warpts >= victimFinal;

    IF initGang = 1 THEN
        UPDATE gangwars
        SET ikills = ikills + 1, adeaths = adeaths + 1
        WHERE init_gangid = killerGID
          AND acpt_gangid = victimGID
          AND active = 1;
    ELSE
        UPDATE gangwars
        SET akills = akills + 1, ideaths = ideaths + 1
        WHERE acpt_gangid = killerGID
          AND init_gangid = victimGID
          AND active = 1;
    END IF;

    UPDATE gangs SET kills = kills + 1 WHERE id = killerGID;
    UPDATE gangs SET deaths = deaths + 1 WHERE id = victimGID;
END;
$$;

-- 18. itWorkslol (测试用)
CREATE OR REPLACE PROCEDURE itWorkslol()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE players
    SET warpts = warpts + 10
    WHERE playerid = '76561198064919358';
END;
$$;

-- ============================================
-- 完成！现在可以使用 CALL xxx() 调用这些存储过程
-- ============================================
