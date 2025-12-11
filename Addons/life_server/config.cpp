class ServerCycle {
  class server1 {
    offset = 30;
    hour = 4;
  };
  class server2 {
    offset = -90;
    hour = 5;
  };
  class server3 {
    offset = 0;
    hour = 4;
  };
};

class mARMADebug {
    class MapObjects {
        name = "Objects";
        code = "count allMissionObjects 'All'";
        interval = 60;
    };

	class LandVehicles {
        name = "Vehicles - Land";
        code = "{_x iskindof 'LandVehicle'} count vehicles";
        interval = 10;
    };

	class AirVehicles {
        name = "Vehicles - Air";
        code = "{_x iskindof 'Air'} count vehicles";
        interval = 10;
    };

	class WaterVehicles {
        name = "Vehicles - Water";
        code = "{_x iskindof 'Ship'} count vehicles";
        interval = 10;
    };

    class Players {
        name = "Players";
        code = "{isPlayer _x} count playableUnits";
        interval = 15;
    };

	class Civs {
		name = "Civilians";
		code = "{side _x isEqualTo civilian} count playableUnits";
		interval = 15;
	};
	class Cops {
		name = "Cops";
		code = "{side _x isEqualTo west} count playableUnits";
		interval = 15;
	};
	class Medics {
		name = "Medics";
		code = "{side _x isEqualTo independent} count playableUnits";
		interval = 15;
	};
	class RestartTime {
        name = "重新启动";
        code = "round((serv_mArmaCycle - (serverTime - serv_mArmaTime)) / 60)";
        interval = 60;
    };
	class RestartType {
		name = "Restart Type";
        code = "serv_mArmaReboot";
        interval = 300;
	};
};

class DefaultEventhandlers;
class CfgPatches {
	class life_server {
		units[] = {"C_man_1"};
		weapons[] = {};
		requiredAddons[] = {"A3_Data_F","A3_Soft_F","A3_Soft_F_Offroad_01","A3_Characters_F"};
		fileName = "life_server.pbo";
		author[]= {"TAW_Tonic"};
	};
};

class CfgFunctions {
	class BIS_Overwrite {
		tag = "BIS";
		class MP {
			file = "\life_server\Functions\MP";
			class initMultiplayer{};
			class call{};
			class spawn{};
			class execFSM{};
			class execVM{};
			class execRemote{};
			class addScore{};
			class setRespawnDelay{};
			class onPlayerConnected{};
			class initPlayable{};
			class missionTimeLeft{};
		};
	};

	class OlympusServer_Sys {
		tag = "OES";
		class Systems {
			file = "\life_server\Functions\Systems";
			class managesc {};
			class huntingZone {};
			class getID {};
			class getMaxTitles {};
			class createServVeh {};
			class createAdminVeh {};
            class clean1up {};
	        class managePhone {};
			class handleBombTimer {};
			class vehicleDead {};
			class spaw1nVehicle {};
			class getVehicles {};
			class vehicleStore {};
			class vehicleDelete {};
			class spikeStrip {};
			class hqTakeover {};
			class logIt {};
			class federalUpdate {};
			class chopShopSell {};
			class copSeizeVeh {};
			class clientDisconnect {};
			class handleAntiAir {};
			class handleLoadouts {};
			class handleDisc {};
			class handleTerror {};
			class cleanupRequest {};
			class setGetHit {};
			class setObjVar {};
			class keyManagement {};
			class adminInvis {};
			class zeusObject {};
			class simSerDisable {};
			class updateVehicleMods {};
			class jailCombatLogger {};
			class enableVehicleSling {};
			class generateShipwreck {};
			class getPlayer {};
			class diagLog {};
			class repairObject {};
			class pulloutDead {};
			class checkVehicleLimit {};
			class checkGangVehicleLimit {};
			class statTableUp {};
			class internetCheck {};
			class updateMarker {};
			class seizePlayerItemsCiv {};
			class handleComplexMarker {};
			class spwnUnownedVeh {};
			class adminInsertVeh {};
			class newPlayerVeh {};
			class spawnDopamineCrate {};
			class spawnMedicPlaceable {};
			class declareMartial {};
			class votingBoothServer {};
			class illegalClaim {};
			class gangClaim {};
			class spawnDeletedAmmoOnLoad {};
			class adminCreateComp {};
			class createItem {};
			class pickupHandler {};
			class updateTitle {};
			class droppedItemCleanupHandler {};
			class lethalPay {};
			class vigiGetSetArrests {};
			class owner2Player {};
			class jipRequestVar {};
			class payload {};
			class deletedVehStore {};
			class changeWeather {};
			class redeemDepositBox {};
			class bankDeaths {};
			class updateCarName {};
			class AdvancedLog {};  //日志
			class buyLicenseServer {};  // 许可证购买服务端验证
			class insertVehicle {};  // 从 MySQL 目录迁移
			class casinoServer {};  // 赌场服务器端验证
			class inventoryServer {};  // 库存服务器端验证
			class adminGiveMoney {};  // 管理员电汇服务端验证
			class dpFinishServer {};  // 快递任务完成服务端验证
		};

		class Wanted_Sys {
			file = "\life_server\Functions\WantedSystem";
			class wantedFetch {};
			class wantedPerson {};
			class wantedBounty {};
			class wantedTicket {};
			class wantedPardon {};
			class wantedRemove {};
			class wantedRemoveCharge {};
			class wantedAdd {};
			class wantedPunish {};
			class bulkAdd {};
		};

		class Pos_scripts {
			file = "\life_server\Functions\POS";
			class initHC {};
			class vehicleManager {};
			class serverCycle {};
			class manageCycle {};
			class SpyGlassMonitor {};
			class SpyGlassResponse {};
			class persistentVehiclesInit {};
			class persistentVehiclesSave {};
			class persistentVehiclesLoad {};
			class persistentGangVehiclesSave {};
			class persistentGangVehiclesLoad {};
			class saveAllHouses {};
			class voterStats {};
		};

		class MySQL {
			file = "\life_server\Functions\MySQL";
			class numberSafe {};
			class mresArray {};
			class queryRequest{};
			class asyncCall{};
			class asyncCall_pgsql {};   // PostgreSQL 实现
			class insertRequest{};
			class updateRequest{};
			class mresToArray {};
			class updateVehOwnership {};
			class bool{};
			class mresString {};
			class updatePartial {};
			class dateToArray {};
			class escapeString {};
			class escapeArray {};
			class numberToString {};
		};

		class Jail_Sys {
			file = "\life_server\Functions\Jail";
			class jailSys {};
		};

		class Client_Code {
			file = "\life_server\Functions\Client";
			class hexMasterServ {};
			class handleDrugSellers {};
		};

		class Lottery {
			file = "\life_server\Functions\Lottery";
			class handleLottery {};
			class runLottery {};
		};

		class Federal {
			file = "\life_server\Functions\Federal";
			class spawnBlackwaterLoot {};
			class startEscort {};
			class spawnEscortVeh {};
			class sellEscort {};
			class jipRequestTimer {};
			class selectRandomWeighted {};
		};

		class Market {
			file = "\life_server\Functions\Market";
			class initMarket {};
			class marketCache {};
			class marketSetOthers {};
			class marketUpdate {};
		};

		class Housing {
			file = "\life_server\Functions\Housing";
			class addHouse {};
			class fetchPlayerHouses {};
			class fetchPlayerHouseKeys {};
			class houseForSale {};
			class initHouses {};
			class sellHouse {};
			class realtorCash {};
			class propertyUpdateKeys {};
			class updateHouseTrunk {};
			class updateProperty {};
			class unlockHouses {};
			class convertStorage {};
			class convertSheds {};
			class houseComp {};
			class updateHouseDeed {};
			class getHouseSaleHistory {};
		};

		class Events {
			file = "\life_server\Functions\Events";
			class conquestServer {};
			class airdropServer {};
			class spawnEventVehicles {};
			class spawnEventCrates {};
			class executeEventAction {};
			class spawnEventObjects {};
			class getEventObjects {};
			class rouletteServer {};
			class eventPlayers {};
			class conquestVoteServ {};
			class artGallery {};
			class apdEscortServer {};
		};

		class Placeables {
			file = "\life_server\Functions\Placeables";
			class spawnPlaceable {};
			class removePlaceable {};
			class loadHousePlaceables {};
			class breweryGetStorage {};
			class breweryUpdateStorage {};
		};

		class Gangs {
			file = "\life_server\Functions\Gangs";
			class insertGang {};
			class activeGangs {};
			class queryPlayerGang {};
			class queryGangShedPos {};
			class removeGang {};
			class rentPay {};
			class updateGang {};
			class updateGangTrunk {};
			class updateGangBldg {};
			class updateGangOil {};
			class updateMember {};
			class getGangInfo {};
			class gangBank {};
			class gangRename {};
			class initGangBldgs {};
			class lockGangBldg {};
			class initTerritories {};
			class sellGangBldg {};
			class addGangBldg {};
			class gangBHistory {};
			class warGetEnemy {};
			class warInsertGang {};
			class warAwardPts {};
			class warRemoveGang {};
			class warGetData {};
			class warGetSetPts {};
			class zoneKillPts {};
			class copZoneKillPts {};
			class clearCap {};
		};

		class Smartphone {
			file = "\life_server\Functions\Smartphone";
			class handleMessages {};
			class msgRequest {};
		};

		// Database Mapper Layer - Moved inside OlympusServer_Sys
		class Database_Core {
			file = "\life_server\Functions\Database\Core";
			class dbExecute {};
			class dbConfig {};
			class arrayToJson {};
			class jsonToArray {};
			class parseJsonb {};
		};

		class Database_Utils {
			file = "\life_server\Functions\Database";
			class safeNumber {};
			class numberToString {};
		};

		class Database_Mappers {
			file = "\life_server\Functions\Database\Mappers";
			class playerMapper {};
			class vehicleMapper {};
			class houseMapper {};
			class gangMapper {};
			class placeableMapper {};
			class bankMapper {};
			class miscMapper {};
			class conquestMapper {};
			class marketMapper {};
			class messageMapper {};
			class logMapper {};
		};

	};
};

class CfgVehicles {
	class Car_F;
	class CAManBase;
	class Civilian;
	class Civilian_F : Civilian {
		class EventHandlers;
	};

	class C_man_1 : Civilian_F {
		class EventHandlers: EventHandlers {
			init = "(_this select 0) execVM ""\life_server\fix_headgear.sqf""";
		};
	};
};

class CfgJIPRequestVar {
	oev_cop_stolenVehicles = 1;
};
