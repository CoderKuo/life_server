/*
 * CfgFunctions.hpp
 * Database Mapper 层函数配置
 *
 * 使用方法:
 *   在主 CfgFunctions.hpp 中添加: #include "Functions\Database\CfgFunctions.hpp"
 */

class DB {
    // 核心函数
    class Core {
        file = "Functions\Database\Core";
        class dbExecute {};      // 数据库执行核心 (PostgreSQL)
        class dbConfig {};       // 数据库配置
    };

    // Mapper 函数
    class Mappers {
        file = "Functions\Database\Mappers";
        class playerMapper {};   // 玩家数据 Mapper
        class vehicleMapper {};  // 车辆数据 Mapper
        class houseMapper {};    // 房屋数据 Mapper
        class gangMapper {};     // 帮派数据 Mapper
        class miscMapper {};     // 杂项数据 Mapper
    };
};
