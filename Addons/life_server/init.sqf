/* Version: 1.0.0 */
#include <macro.h>
#define DB_FAILED(MESSAGE) \
	life_server_extDB_notLoaded = ##MESSAGE; \
	publicVariable "life_server_extDB_notLoaded";

/*
 * ============================================
 * 数据库后端配置
 * ============================================
 * 使用 PostgreSQL (arma3_pgsql) 作为数据库后端
 */
life_pgsql_protocol = "SQL_MAIN"; // PostgreSQL 协议名称

DB_Async_Active = false;
life_server_extDB_notLoaded = "";
DB_Async_ExtraLock = false;
life_server_isReady = false;
life_hc_error = false;
life_HC_isActive = false;
publicVariable "life_HC_isActive";
life_serv_vehicles = [];
life_server_eventVehicles = [];
life_server_eventCrates = [];
life_server_eventObjects = [];
life_server_online_gangs = [];
olympusVehiclesSaved = false;
olympusVehiclesLoaded = false;
olympusGangVehiclesSaved = false;
olympusGangVehiclesLoaded = false;
publicVariable "life_server_isReady";

dbColumnGearCiv = "civ_gear";
dbColumnGearMed = "med_gear";
dbColumnGearCop = "cop_gear";
dbColumnPosition = "coordinates";
dbColumVehicle = "vehicles";
dbColumGangVehicle = "gangvehicles";

olympus_server = switch (profileName) do {
	case "OlympusServer1": {1};
	case "OlympusServer2": {2};
	case "OlympusServer3": {3};
	case "OlympusServer4": {4};
	case "OlympusServer5": {5};
	case "OlympusServer6": {6};
	default {1};
};
publicVariable "olympus_server";

if (profileName == format ["OlympusServer%1",olympus_server]) then {
	format ["这是地球都市服务器 %1",olympus_server] call OES_fnc_diagLog;
} else {
	"!!- Something went wrong and profilename was incorrect -!!" call OES_fnc_diagLog;
};

olympus_deleteOldHouses = format ["deleteOldHouses%1",olympus_server];
olympus_market = olympus_server;
olympus_resetVehicles = format ["resetLifeVehicles%1",olympus_server];
olympus_houseCleanup = format ["houseCleanup%1",olympus_server];

mc_phone_groups =
[
[radioChannelCreate [[0.8,0,0.6,0.9], "电话频道", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "电话频道", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "电话频道", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "电话频道", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "电话频道", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "电话频道", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "电话频道", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "电话频道", "%UNIT_NAME", []], []]
];
publicVariable "mc_phone_groups";

[] spawn OES_fnc_initHC;

/*
 * ============================================
 * 数据库初始化
 * ============================================
 * 使用 PostgreSQL (arma3_pgsql)
 */

// ==========================================
// PostgreSQL 初始化 (arma3_pgsql)
// ==========================================
"[PGSQL] 正在初始化 PostgreSQL 数据库连接..." call OES_fnc_diagLog;

if(isNil {uiNamespace getVariable "life_pgsql_initialized"}) then {
	// 检查扩展是否加载
	if !([] call PGSQL_fnc_isLoaded) exitWith {
		DB_FAILED("arma3-pgsql 扩展未加载，请检查服务器配置");
	};

	// 获取版本
	private _version = [] call PGSQL_fnc_version;
	format["[PGSQL] arma3-pgsql Version: %1", _version] call OES_fnc_diagLog;

	// 添加数据库连接 (使用 ini 文件中的 [Database2] 配置节)
	private _dbResult = ["Database2"] call PGSQL_fnc_addDatabase;
	if ((_dbResult select 0) != 1) exitWith {
		DB_FAILED(format["arma3-pgsql: 数据库连接失败 - %1", _dbResult select 1]);
	};
	"[PGSQL] 数据库连接成功" call OES_fnc_diagLog;

	// 添加 SQL 协议 (参数: 数据库ID, 协议类型, 协议名称, 初始化选项)
	// TEXT 选项: 让 VARCHAR/TEXT 类型的值加上引号，避免大数字被解析为科学计数法
	private _protoResult = ["Database2", "SQL", life_pgsql_protocol, "TEXT"] call PGSQL_fnc_addProtocol;
	if ((_protoResult select 0) != 1) exitWith {
		DB_FAILED(format["arma3-pgsql: 协议添加失败 - %1", _protoResult select 1]);
	};
	format["[PGSQL] SQL 协议 '%1' 已添加 (TEXT模式)", life_pgsql_protocol] call OES_fnc_diagLog;

	// 锁定扩展
	["LOCK"] call PGSQL_fnc_lock;
	"[PGSQL] 扩展已锁定" call OES_fnc_diagLog;

	uiNamespace setVariable ["life_pgsql_initialized", true];
	"[PGSQL] PostgreSQL 初始化完成!" call OES_fnc_diagLog;
} else {
	"[PGSQL] 已存在初始化的 PostgreSQL 连接" call OES_fnc_diagLog;
};

// 为兼容性设置一个假的 life_sql_id
life_sql_id = {life_pgsql_protocol};
__CONST__(life_sql_id,life_sql_id);

// ==========================================
// Create DB_fnc_* aliases for backward compatibility
// Functions are now compiled as OES_fnc_* but many files reference DB_fnc_*
// ==========================================
DB_fnc_dbExecute = OES_fnc_dbExecute;
DB_fnc_dbConfig = OES_fnc_dbConfig;
DB_fnc_parseJsonb = OES_fnc_parseJsonb;
DB_fnc_playerMapper = OES_fnc_playerMapper;
DB_fnc_vehicleMapper = OES_fnc_vehicleMapper;
DB_fnc_houseMapper = OES_fnc_houseMapper;
DB_fnc_gangMapper = OES_fnc_gangMapper;
DB_fnc_bankMapper = OES_fnc_bankMapper;
DB_fnc_miscMapper = OES_fnc_miscMapper;
DB_fnc_conquestMapper = OES_fnc_conquestMapper;
DB_fnc_marketMapper = OES_fnc_marketMapper;
DB_fnc_messageMapper = OES_fnc_messageMapper;
DB_fnc_logMapper = OES_fnc_logMapper;
"[PGSQL] DB_fnc_* aliases created for backward compatibility" call OES_fnc_diagLog;

// Initialize Database Mapper layer
[] call DB_fnc_dbConfig;
"[PGSQL] Database Mapper layer initialized" call OES_fnc_diagLog;

if(!(life_server_extDB_notLoaded isEqualTo "")) exitWith {};

// Lock server between 2AM - 2PM on Saturday/Sunday. Lock the server always on weekdays

/* if (profilename == "OlympusServer3") then {
	private _day = ((["SELECT DAYNAME(NOW())",2] call OES_fnc_asyncCall) select 0);
	if (_day in ["Saturday","Sunday"]) then {
		private _time = ((["SELECT TIME_TO_SEC(CURTIME())",2] call OES_fnc_asyncCall) select 0);
		if ((_time > (6 * 3600)) && (_time < (18 * 3600))) then {
			"fdFPXGkYrxwdaxf5kiE" serverCommand "#lock";
			[] spawn{
				while {true} do {
					uiSleep random(30);
					[3,"<t color='#ff2222'><t size='2.2'><t align='center'>WARNING!<br/><t color='#FFC966'><t align='center'><t size='1.2'>You are on server 3 during non-peak hours. The server will be kicking you in 1 minute. Please move to server 1 or 2 at this time. Thank you.",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
					uiSleep 90;
					[3,"<t color='#ff2222'><t size='2.2'><t align='center'>WARNING!<br/><t color='#FFC966'><t align='center'><t size='1.2'>You are on server 3 during non-peak hours. The server will be kicking now. Please move to server 1 or 2 at this time. Thank you.",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
					uiSleep random(15);

					{
						"fdFPXGkYrxwdaxf5kiE" serverCommand format ["#kick %1", getPlayerUID _x];
						uiSleep 0.2;
					} forEach (allPlayers - entities "HeadlessClient_F");
					uiSleep (2 * 60);
				};
			};
		};
	} else {
		"fdFPXGkYrxwdaxf5kiE" serverCommand "#lock";
		[] spawn{
			while {true} do {
				uiSleep random(30);
				[3,"<t color='#ff2222'><t size='2.2'><t align='center'>WARNING!<br/><t color='#FFC966'><t align='center'><t size='1.2'>You are on server 3 during non-peak hours. The server will be kicking you in 1 minute. Please move to server 1 or 2 at this time. Thank you.",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
				uiSleep 90;
				[3,"<t color='#ff2222'><t size='2.2'><t align='center'>WARNING!<br/><t color='#FFC966'><t align='center'><t size='1.2'>You are on server 3 during non-peak hours. The server will be kicking now. Please move to server 1 or 2 at this time. Thank you.",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
				uiSleep random(15);

				{
					"fdFPXGkYrxwdaxf5kiE" serverCommand format ["#kick %1", getPlayerUID _x];
					uiSleep 0.2;
				} forEach (allPlayers - entities "HeadlessClient_F");
				uiSleep (2 * 60);
			};
		};
	};
}; */

// 使用 Mapper 层调用存储过程 (异步执行，无需返回值)
[] spawn {
	// 房屋清理
	["callhousecleanup", []] call DB_fnc_miscMapper;
	// 重置车辆
	["callresetlifevehicles", []] call DB_fnc_miscMapper;
	// 删除已损毁车辆
	["calldeletedeadvehicles", []] call DB_fnc_miscMapper;
	// 删除旧房屋
	["calldeleteoldhouses", []] call DB_fnc_miscMapper;
	// 删除旧帮派
	["calldeleteoldgangs", []] call DB_fnc_miscMapper;
	// 发放现金
	["callgivecash", []] call DB_fnc_miscMapper;
	// 删除合同
	["calldeletecontracts", []] call DB_fnc_miscMapper;
	// 帮派建筑清理
	["callgangbuildingcleanup", []] call DB_fnc_miscMapper;
	// 更新成员名称
	["callupdatemembernames", []] call DB_fnc_miscMapper;
};
//[] call OES_fnc_finalizeAuctions; //uncomment in live environment

[] spawn OES_fnc_getMaxTitles;

oev_designerlevel = {0};
oev_developerlevel = {0};
oev_civcouncil = {0};
oev_restrictions = {false};
life_adminlevel = {0};
life_medicLevel = {0};
life_coplevel = {0};
life_supportlevel = {0};
life_newslevel = {0};
oev_donator = {0};
oev_gang_data = [];
oev_hqtakeover = [[false, 0],[false, 0],[false, 0],[false, 0],[false, 0],[false, 0],[false, 0]]; //Kavala - Pyrgos - Athira - Sofia - Neochori - Blackwater - Air
publicVariable "oev_hqtakeover";
oev_lastTakeoverTime = -1;
publicVariable "oev_lastTakeoverTime";
life_eventPlayers = 0;
oev_bankDeaths = 0;
oev_drug_sellers = [[], [], [], [], []];
//publicVariable "oev_bankDeaths";
//Null out harmful things for the server.
__CONST__(JxMxE_PublishVehicle,"No");

life_radio_west = radioChannelCreate [[0, 0.95, 1, 0.8], "侧通道", "%UNIT_NAME", []];
life_radio_admin = radioChannelCreate [[0.8, 0, 0, 0.8], "管理员沟通频道", "%UNIT_NAME", []];
life_radio_gang = radioChannelCreate [[0.87, 0.52, 0, 0.8], "帮派谈话", "%UNIT_NAME", []];
life_radio_civ = radioChannelCreate [[255, 244, 0, 0.23], "平民频道", "%UNIT_NAME", []];


serv_sv_use = [];

// ==========================================
// 服务器 HashMap 缓存初始化 (性能优化)
// ==========================================
OES_playerByUID = createHashMap;     // UID -> 玩家对象
OES_playerByOwner = createHashMap;   // ownerID -> 玩家对象
OES_itemWeights = createHashMapFromArray [
	["lethalinjector", 10], ["oilu", 3], ["oilp", 2], ["heroinu", 2], ["heroinp", 1],
	["pheroin", 1], ["painkillers", 1], ["cannabis", 2], ["fireworks", 1], ["marijuana", 1],
	["hash", 1], ["apple", 1], ["water", 1], ["yakult", 2], ["salema", 2], ["ornate", 2],
	["mackerel", 3], ["tuna", 4], ["mullet", 3], ["catshark", 4], ["turtle", 3],
	["fishing", 2], ["turtlesoup", 2], ["donuts", 1], ["coffee", 1], ["fuelE", 2],
	["fuelF", 5], ["money", 0], ["pickaxe", 2], ["copperore", 2], ["ironore", 2],
	["copperr", 1], ["ironr", 1], ["sand", 2], ["salt", 2], ["saltr", 1], ["glass", 1],
	["diamond", 2], ["diamondc", 1], ["cocaine", 2], ["cocainep", 1], ["crack", 1],
	["spikeStrip", 10], ["rock", 3], ["cement", 2], ["goldbar", 6], ["moneybag", 6],
	["blastingcharge", 15], ["hackingterminal", 7], ["takeoverterminal", 7],
	["boltcutter", 5], ["fireaxe", 5], ["defusekit", 2], ["storagesmall", 5],
	["oilbarrel", 5], ["storagebig", 10], ["frog", 2], ["frogp", 1], ["acid", 1],
	["crystalmeth", 3], ["methu", 3], ["phosphorous", 2], ["ephedra", 2], ["lithium", 2],
	["moonshine", 3], ["rum", 3], ["mashu", 3], ["corn", 2], ["sugar", 2], ["yeast", 2],
	["platinum", 2], ["platinumr", 1], ["silver", 2], ["silverr", 1], ["beer", 1],
	["cupcake", 1], ["pepsi", 1], ["burger", 1], ["mushroom", 2], ["mmushroom", 1],
	["mmushroomp", 1], ["mushroomu", 1], ["gpstracker", 2], ["egpstracker", 2],
	["gpsjammer", 3], ["ccocaine", 1], ["kidney", 25], ["scalpel", 4], ["barrier", 20],
	["speedbomb", 10], ["potato", 1], ["cream", 1], ["bloodbag", 5], ["epiPen", 10],
	["dopeShot", 10], ["baitcar", 1], ["vehAmmo", 5], ["woodLog", 3], ["lumber", 2],
	["bananau", 2], ["bananap", 1], ["topaz", 2], ["topazr", 1], ["scrap", 1],
	["emearld", 2], ["amethyst", 2], ["coin", 2], ["wpearl", 1], ["bpearl", 1],
	["cocoau", 2], ["cocoap", 1], ["bananaSplit", 2], ["sugarp", 1], ["blindfold", 1],
	["panicButton", 1], ["wplPanicButton", 15], ["roadKit", 1], ["excavationtools", 1],
	["stire", 1], ["rubber", 1], ["alumore", 1], ["coal", 1], ["ltire", 1], ["fibers", 1],
	["window", 1], ["rglass", 1], ["vdoor", 1], ["electronics", 1], ["smetal", 1],
	["splating", 1], ["alumalloy", 1], ["bcremote", 0], ["paintingSm", 33],
	["paintingLg", 50], ["gokart", 25], ["wildfruit", 2]
];
diag_log "[HashMap] 服务器 HashMap 配置初始化完成";

// ==========================================
// 玩家缓存辅助函数
// ==========================================
// 通过 UID 获取玩家对象 (O(1) 缓存 + 验证)
OES_fnc_getPlayerByUID = {
	params ["_uid"];
	if (_uid == "") exitWith { objNull };
	private _cached = OES_playerByUID getOrDefault [_uid, objNull];
	if (!isNull _cached && {alive _cached} && {getPlayerUID _cached == _uid}) exitWith { _cached };
	// 缓存无效，遍历查找并更新
	private _player = objNull;
	{ if (getPlayerUID _x == _uid) exitWith { _player = _x; OES_playerByUID set [_uid, _x]; }; } forEach allPlayers;
	_player
};

// 通过 ownerID 获取玩家对象 (O(1) 缓存 + 验证)
OES_fnc_getPlayerByOwner = {
	params ["_ownerID"];
	if (_ownerID == 0) exitWith { objNull };
	private _cached = OES_playerByOwner getOrDefault [_ownerID, objNull];
	if (!isNull _cached && {alive _cached} && {owner _cached == _ownerID}) exitWith { _cached };
	// 缓存无效，遍历查找并更新
	private _player = objNull;
	{ if (owner _x == _ownerID) exitWith { _player = _x; OES_playerByOwner set [_ownerID, _x]; }; } forEach allPlayers;
	_player
};

// ==========================================
// 玩家连接/断开事件处理 (更新缓存)
// ==========================================
addMissionEventHandler ["PlayerConnected", {
	params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
	// 验证参数有效性
	if (_uid == "" || _owner <= 0) exitWith {};
	// 延迟执行确保玩家对象已创建 (不依赖 CBA)
	[_uid, _owner] spawn {
		params ["_uid", "_owner"];
		sleep 0.5;
		private _idx = allPlayers findIf {getPlayerUID _x == _uid};
		if (_idx != -1) then {
			private _playerObj = allPlayers select _idx;
			OES_playerByUID set [_uid, _playerObj];
			OES_playerByOwner set [_owner, _playerObj];
			diag_log format ["[HashMap] 玩家缓存已更新: UID=%1, Owner=%2", _uid, _owner];
		};
	};
}];

addMissionEventHandler ["PlayerDisconnected", {
	params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
	// 验证参数有效性，避免删除无效键
	if (_uid != "") then {
		OES_playerByUID deleteAt _uid;
	};
	if (_owner > 0) then {
		OES_playerByOwner deleteAt _owner;
	};
	// 只在有有效数据时输出日志
	if (_uid != "" || _owner > 0) then {
		diag_log format ["[HashMap] 玩家缓存已移除: UID=%1, Owner=%2", _uid, _owner];
	};
}];

addMissionEventHandler ["HandleDisconnect",{_this call OES_fnc_clientDisconnect; false;}]; //Do not second guess this, this can be stacked this way.

"mpid_log" addPublicVariableEventHandler {
	// Add MPID logs to database and log
	_mpids = _this select 1;

	// validate pid to prevent sqli
	_exit = false;
	if (count _mpids < 2) exitWith {};

	{
	    if (_x isEqualType "" && count _x != 17) exitWith {
				_exit = true;
			};
			{
			    if (str(parseNumber _x) != _x) exitWith {
						_exit = true;
					};
			} forEach (_x splitString "");
	} forEach _mpids;
	if (_exit) exitWith {};

	// 构建搜索条件
	private _searchConditions = format["pids LIKE '%1'", "%" + (_mpids select 0) + "%"];
	{
		if (_forEachIndex > 0) then {
			_searchConditions = _searchConditions + format[" OR pids LIKE '%1'", "%" + _x + "%"];
		};
	} forEach _mpids;

	// 使用 Mapper 层搜索 MPID
	private _queryResult = ["mpidsearch", [_searchConditions]] call DB_fnc_miscMapper;
	if (isNil "_queryResult") then { _queryResult = []; };

	if (count _queryResult == 0) then {
		// insert - 使用 Mapper 层
		["mpidinsert", [str _mpids]] call DB_fnc_miscMapper;
	} else {
		// update
		if (count _queryResult > 1) then {
			// eg ["a", "b"] and ["c", "d"] exist, then the player logs in with ["a", "c"]
			// merge all into one row and delete duplicates
			_deleteIds = [];
			{
				{ _mpids pushBackUnique _x; } forEach (_x select 1);
				if (_forEachIndex > 0) then {
					_deleteIds pushBackUnique (_x select 0);
				};
			} forEach _queryResult;
			// delete extra rows - 使用 Mapper 层
			["mpiddelete", [_deleteIds joinString ","]] call DB_fnc_miscMapper;
			// update single remaining row - 使用 Mapper 层
			["mpidupdate", [str _mpids, str ((_queryResult select 0) select 0)]] call DB_fnc_miscMapper;
		} else {
			// add db pids to _mpids (ie combine unique)
			{ _mpids pushBackUnique _x; } forEach ((_queryResult select 0) select 1);
			["mpidupdate", [str _mpids, str ((_queryResult select 0) select 0)]] call DB_fnc_miscMapper;
		};
	};
};


// [ Running-BOOL, [ "ZoneName", Zone-POLY[] ], [ GangIDs ], [ GangScores ], PrizePool-5secUpdate, [ GangNames], [ Top3Scores ] ]
oev_conquestData = [ false, ["", []], [], [], 0, [], [[],[],[]], 3000];
publicVariable "oev_conquestData";
oev_conqChop = "";
publicVariable "oev_conqChop";
oev_conquestVote = false;
publicVariable "oev_conquestVote";
oev_lastConquest = -1;
publicVariable "oev_lastConquest";
oev_secondConq = false;
oev_cancelConq = false;

oev_airdrop = false;
publicVariable "oev_airdrop";
oev_airdropCount = 0;

//空投计划程序，检查服务器是否应该以30-90分钟的间隔启动空投
//也就是说，最早的空投可以在重启后30分钟内启动，最晚可以在重启后90分钟启动
//两次空投可能至少相隔30分钟，但可能性不大
[] spawn {
	_exit = false;
	while{true} do {
		if(!oev_airdrop && [] call OEC_fnc_timeUntilRestart >= 30) then {
			uiSleep ((60*30)+(60*round(random 60)));
			if(count playableUnits > 79 && oev_airdropCount < 2) then {
				[objNull] spawn OES_fnc_airdropServer;
				oev_airdropCount = oev_airdropCount + 1;
			} else {
				if(oev_airdropCount > 1) exitWith {_exit = true;};
			};
			if(_exit) exitWith {};
		} else {
			if((call OEC_fnc_timeUntilRestart) < 30) then {
				_exit = true;
			};
		};
		if(_exit) exitWith {};
		uiSleep (60*5);
	};
};

oev_artgallery = false;
publicVariable "oev_artgallery";

//oev_conquestScores = [ [], [] ];

// [ Point Markers, Zone Lines, Cap Flags, PrizePool ]
oev_conquestServ = [ [], [], [], 0 ];

randomized_life_gang_list = [];
publicVariable "randomized_life_gang_list";
life_wanted_list = [];
life_lottery_list = [];
life_runningLottery = false;
publicVariable "life_runningLottery";
life_lotteryCooldown = false;
publicVariable "life_lotteryCooldown";
life_lottery_round = 0;
publicVariable "life_lottery_round";

// 闪电彩变量
life_flash_lottery_list = [];
life_flash_lottery_running = false;
publicVariable "life_flash_lottery_running";
life_flash_lottery_cooldown = false;
publicVariable "life_flash_lottery_cooldown";
life_flash_lottery_round = 0;
publicVariable "life_flash_lottery_round";

client_session_list = [];
life_terrorStatus = [false,"",0];
publicVariable "life_terrorStatus";

enableEnvironment false;
enableEngineArtillery false;
enableCaustics false;
disableRemoteSensors true;

[] spawn{
	private["_logic","_queue"];
	while {true} do	{
		uiSleep (30 * 60);
		_logic = missionnamespace getvariable ["bis_functions_mainscope",objnull];
		_queue = _logic getvariable "BIS_fnc_MP_queue";
		_logic setVariable["BIS_fnc_MP_queue",[],TRUE];
	};
};

//oev_pid_list = ["76561198087883648","76561198077764276","76561198195161302","76561198069421209","76561198255390839","76561198134085496","76561198287758055","76561198193595045","76561198327358879","76561198138030788","76561197990701283","76561198172179287","76561198093940692","76561198330295265","76561198018661500","76561198134575718","76561198319320440","76561198149414564","76561198182261686", "76561198285248767","76561198268918737","76561198063244128","76561198071602226","76561198141545080","76561198108381054","76561198251344246","76561198151973023","76561198344550311","76561198300648283","76561198073897409","76561198216100232","76561198075952564","76561198073621946","76561198079472428"];
//publicVariable "oev_pid_list";

oev_title_pid = [];
oev_max_raceTime = -1;

life_recently_robbed = [];

[] spawn OES_fnc_initMarket;
[] spawn OES_fnc_persistentVehiclesInit;
[] spawn OES_fnc_serverCycle;
[] spawn OES_fnc_SpyGlassMonitor;

east setFriend [west, 1];
west setFriend [east, 1];

[] spawn OES_fnc_vehicleManager;
[] spawn OES_fnc_initHouses;
[] spawn OES_fnc_initGangBldgs;
[] spawn OES_fnc_activeGangs;

[] spawn OES_fnc_initTerritories;

private _bank = nearestObject [[15406.05,16012.187,1.052],"CargoNet_01_box_F"]; //Update these coords!!!
private _dome = nearestObject [[16019.5,16952.9,0],"Land_Dome_Big_F"];
private _rsb = nearestObject [[16019.5,16952.9,0],"Land_Research_house_V1_F"];
private _blackwaterDome = nearestObject [[20898.6,19221.7,0.00143909],"Land_Dome_Big_F"];
private _blackwaterBigTower = nearestObject [[21050.3,19296.9,0.0485153],"Land_Cargo_Tower_V1_F"];
_blackwaterBigTower allowDamage false;

for "_i" from 1 to 3 do {_blackwaterDome setVariable[format["bis_disabled_Door_%1",_i],1,true]; _blackwaterDome animate [format["Door_%1_rot",_i],0];};

private _jailDome = nearestObject [[16709.8,13602,4.00142384],"Land_Dome_Big_F"];
for "_i" from 2 to 3 do {_jailDome setVariable[format["bis_disabled_Door_%1",_i],1,true]; _jailDome animate [format["Door_%1_rot",_i],0];};

for "_i" from 1 to 3 do {_dome setVariable[format["bis_disabled_Door_%1",_i],1,true]; _dome animate [format["Door_%1_rot",_i],0];};
_rsb setVariable["bis_disabled_Door_1",1,true];
_rsb allowDamage false;
_dome allowDamage false;
_blackwaterDome allowDamage false;

_bank setVariable ["bankCooldown",0,true];

_blackwaterDome setVariable ["chargeplaced",false,true];
_blackwaterDome setVariable ["safe_open",false,true];
_blackwaterDome setVariable ["bwcooldown",false,true];
_blackwaterDome setVariable ["robtime",0,true];


//[] spawn{
//	private _blackwaterDome = nearestObject [[20898.6,19221.7,0.00143909],"Land_Dome_Big_F"];
//	while {true} do {
//		uiSleep 1;
//		if ((_blackwaterDome getVariable "bis_disabled_Door_1") isEqualTo 1) then {
//			for "_i" from 1 to 3 do {_blackwaterDome animate [format["Door_%1_rot",_i],0];};
//		} else {
//			for "_i" from 1 to 3 do {_blackwaterDome animate [format["Door_%1_rot",_i],1];};
//		};
//	};
//};

fedAntiAir setVariable ["active",true,true];
fedAntiAir setVariable ["virus","",true];
jailAntiAir setVariable ["active",true,true];
jailAntiAir setVariable ["virus","",true];
bwAntiAir setVariable ["active",true,true];
bwAntiAir setVariable ["virus","",true];

//Helipads for Blackwater
"Land_HelipadCivil_F" createVehicle [20906.7,19220.9,0];
"Land_HelipadCivil_F" createVehicle [20887.7,19266.3,0];


oev_eventCooldown = 0;
publicVariable "oev_eventCooldown";

[] spawn{
	while{true} do {
		uiSleep (3 * 60);

		if((fogParams select 2) > 80 || (fogParams select 0) > 0.02) then {
			300 setFog [0, 0, 0];
		};
	};
};

[] spawn{
	while{true} do {
		uiSleep 300;
		if(!(oev_conquestData select 0) && !(oev_conquestVote) && !(oev_secondConq) && [] call OEC_fnc_timeUntilRestart >= 60) then {
			// 使用 Mapper 层查询待执行的征服活动
			private _result = ["getscheduled", [str olympus_server]] call DB_fnc_conquestMapper;
			if (!isNil "_result" && {_result isEqualType []} && {count _result != 0}) then {
				[_result] spawn OES_fnc_conquestVoteServ;
			};
		};
	};
};

[] spawn{
	uiSleep 60;
	if(!olympusVehiclesLoaded) then {
		"!!!!!!!!!!! 持久性车辆未能在60秒内装载" call OES_fnc_diagLog;
	};
	olympusVehiclesLoaded = true;
	if(!olympusGangVehiclesLoaded) then {
		"!!!!!!!!!!! 持续帮派车辆未能在60秒内装载" call OES_fnc_diagLog;
	};
	olympusGangVehiclesLoaded = true;
};

life_server_isReady = true;
publicVariable "life_server_isReady";

/****************************
* Timed discounts (Y, M, D)
****************************/
private ["_query","_goalActive","_dateOne","_dateTwo"];
// Vehicles Only
//_query = "SELECT DATEDIFF('2018-09-08',NOW())";
//_goalActive = (([_query,2] call OES_fnc_asyncCall) select 0);
//life_donation_vehicles = false;
//if (_goalActive >= 0) then {
//	life_donation_vehicles = true;
//};

life_donation_vehicles = false; //-- Remove when uncommenting above.
publicVariable "life_donation_vehicles";

/* Vehicles & Weapons */
//private _query = "SELECT DATEDIFF('2019-05-31',NOW())";
//private _goalActive = (([_query,2] call OES_fnc_asyncCall) select 0);
//life_donation_active = false;
//if (_goalActive >= 0) then {
//	life_donation_active = true;
//};

life_donation_active = false; //-- Remove when uncommenting above.
publicVariable "life_donation_active";

// REBEL Vehicles Only
//_query = "SELECT DATEDIFF('2019-03-16',NOW())";
//_goalActive = (([_query,2] call OES_fnc_asyncCall) select 0);
//life_donation_rebVehicles = false;
//if (_goalActive >= 0) then {
//	life_donation_rebVehicles = true;
//};

life_donation_rebVehicles = false; //-- Remove when uncommenting above.
publicVariable "life_donation_rebVehicles";

//BW战利品和联邦黄金只增加
// 使用 Mapper 层计算日期差
private _goalActiveResult = ["getdatediff", ["2021-7-15"]] call DB_fnc_miscMapper;
_goalActive = if (isNil "_goalActiveResult" || {!(_goalActiveResult isEqualType [])} || {count _goalActiveResult == 0}) then { -1 } else { _goalActiveResult select 0 };
life_donation_fedLoot = false;
if (_goalActive >= 0) then {
	life_donation_fedLoot = true;
};

//life_donation_fedLoot = false; //-- Remove when uncommenting above.
publicVariable "life_donation_fedLoot";

// Civ Rep Voting
//_query = "SELECT DATEDIFF('2018-09-01',NOW())";
//_goalActive = (([_query,2] call OES_fnc_asyncCall) select 0);
//life_voting_active = false;
//if (_goalActive > 0) then {
//	life_voting_active = true;
//};

life_voting_active = false; //-- Remove when uncommenting above.
publicVariable "life_voting_active";

// 15% on Houses and Sheds
//_query = "SELECT DATEDIFF('2018-04-09',NOW())";
//_goalActive = (([_query,2] call OES_fnc_asyncCall) select 0);
//life_donation_house = false;
//if (_goalActive > 0) then {
//	life_donation_house = true;
//};

life_donation_house = false; //-- Remove when uncommenting above.
publicVariable "life_donation_house";

// July 4th Perks
//_query = "SELECT DATEDIFF('2019-07-01',NOW())";
//_dateOne = (([_query,2] call OES_fnc_asyncCall) select 0);
//_query = "SELECT DATEDIFF('2019-07-31',NOW())";
//_dateTwo = (([_query,2] call OES_fnc_asyncCall) select 0);
//life_freedom = false;
//if (_dateOne <= 0 && _dateTwo >= 0) then {
//	life_freedom = true;
//};

life_freedom = false; //-- Remove when uncommenting above.
publicVariable "life_freedom";

// 使用 Mapper 层获取上月征服冠军
private _conquestWinnerResult = ["getmonthlywinner", []] call DB_fnc_conquestMapper;
_conquestWinnerID = if (isNil "_conquestWinnerResult" || {!(_conquestWinnerResult isEqualType [])} || {count _conquestWinnerResult == 0}) then { [] } else { _conquestWinnerResult };

life_conquestMonthly = if (_conquestWinnerID isEqualTo []) then [{0}, {_conquestWinnerID select 0}];
publicVariable "life_conquestMonthly";

life_martialLaw_active = true;
life_martialLaw_time = 0;
life_martialLaw_pv = [false,""];
publicVariable "life_martialLaw_pv";
serv_timeFucked = false;
serv_gangwar_kills = [];
serv_market_update = [];
serv_market_cache = false;
serv_mArmaTime = serverTime;
serv_mArmaCycle = ((6 * 60) * 60) - 360;
serv_mArmaReboot = 0;
serv_mArmaWebReboot = -1;
serv_gear_robberies = [];
serv_yinv_cleanup = [];
serv_weaponholder_cleanup = [];
serv_escortCooldown = 0;
serv_escortDriver = "";
serv_escortTruck = objNull;
serv_escortQilin = objNull;
serv_escortGroup = grpNull;
serv_escortPIDS = [];
serv_bonesBounty = [];
escort_status = [false,0];
serv_lethalTracker = [];
arms_cooldown = 0;
meth_cooldown = 0;
mush_cooldown = 0;
shine_cooldown = 0;
serv_apdEscortData = [];
serv_apdEscortCooldown = 0;
publicVariable "serv_apdEscortCooldown";

{
	_pos = _x select 0; _shed = createVehicle ["Land_i_Shed_Ind_F",_pos]; _shed setDir (_x select 1); _shed setPosASL _pos;
}forEach [[[10142.7,12787.1,17.2],340],[[8444.81,11189.7,24],225],[[10461.6,11970,15],328],[[11390.5,12385.8,32.35],211],[[10211.1,12360.1,16.2],45]];

publicVariable "arms_cooldown";
publicVariable "meth_cooldown";
publicVariable "mush_cooldown";
publicVariable "shine_cooldown";

publicVariable "escort_status";

[] spawn OES_fnc_clean1up;

[] spawn{
	private _pCount = count playableUnits;
	private _dCount = {(isPlayer _x) && !(alive _x)} count playableUnits;
	private _deadPids = [];
	private _alivePids = [];
	uiSleep 120; // Wait till server has time to log in at restarts
	scopeName "main";
	waitUntil {uiSleep 5; !serv_timeFucked};
	waitUntil {uiSleep 5; ((count playableUnits) > 15)};

	while {true} do {
		if ((count playableUnits) <= 15) then {breakTo "main";};
		_pCount = count playableUnits;
		_dCount = {(isPlayer _x) && (!(alive _x) || (_x distance2d (getMarkerPos "debug_island_marker") < 600))} count playableUnits;
		if !(_dCount isEqualTo 0) then {
			if ((_pCount / _dCount) < 2) then {
				//[3,"<t color='#ff2222'><t size='2.2'><t align='center'>Server Notification!<br/><t color='#FFC966'><t align='center'><t size='1.2'>The server has detected that over half the server population is dead. The event has been logged to server. You can make compensation requests if applicable at www.olympus-entertainment.com/support.",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
				{
					if ((alive _x) && (_x distance2d (getMarkerPos "debug_island_marker") > 600)) then {
						_alivePids pushBack (getPlayerUID _x);
					} else {
						if (_x distance2d (getMarkerPos "debug_island_marker") < 600) then {
							_deadPids pushBack (getPlayerUID _x);
						};
					};
				} forEach playableUnits;

				"------------------ MASS DEATH EVENT TRIGGERED ------------------" call A3LOG_fnc_log;
				format ["-MASSDEATH- Player Count: %1",(count playableUnits)] call A3LOG_fnc_log;
				format ["-MASSDEATH- Alive Count: %1",(count _alivePids)] call A3LOG_fnc_log;
				format ["-MASSDEATH- Dead Count: %1",(count _deadPids)] call A3LOG_fnc_log;
				format ["-MASSDEATH- Alive PIDS: %1",_alivePids] call A3LOG_fnc_log;
				format ["-MASSDEATH- Dead PIDS: %1",_deadPids] call A3LOG_fnc_log;
				"--------------------------------------------------------------" call A3LOG_fnc_log;
				// [4,objNull,[count _alivePids,count _deadPids]] spawn OES_fnc_handleDisc;

				uiSleep 120;
				breakTo "main";
			};
		};

		uiSleep 10;
	};
};

[] spawn{
	while{true} do {
		sleep 1;
		if(serv_mArmaWebReboot != -1) then {
			switch(serv_mArmaWebReboot) do {
				case 0: {//硬重新启动，以便进行更新
					serverHardReboot = true;
					serverUpdate = false;
					serv_mArmaReboot = 2;
				};

				case 1: {//硬重启，无更新
					serverUpdate = false;
					serverHardReboot = true;
					serv_mArmaReboot = 1;
				};

				case 2: {//软重启
					serverUpdate = false;
					serverHardReboot = true;
				};

				case 3: {//Restarts server in 60 minutes
					serverCycleLength = (((1 * 60) * 60) + 15) + (serverTime - serverStartTime);
					[3,format["<t color='#ff8000'><t size='2'><t align='center'>服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>管理员已调整重新启动时间。新的重新启动时间为60分钟。", round((serverCycleLength - serverStartTime) / 60)],false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
					sleep 10;
					publicVariable "serverCycleLength";//Broadcast length of time till next restart
					serv_mArmaCycle = serverCycleLength;
				};

				case 4: {//Restarts server in 30 minutes
					serverCycleLength = (((0.5 * 60) * 60) + 15) + (serverTime - serverStartTime);
					[3,format["<t color='#ff8000'><t size='2'><t align='center'>服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>管理员已调整重新启动时间。新的重新启动时间为30分钟。", round((serverCycleLength - serverStartTime) / 60)],false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
					sleep 10;
					publicVariable "serverCycleLength";//Broadcast length of time till next restart
					serv_mArmaCycle = serverCycleLength;
				};

				case 5: {//Restarts server in 15 minutes
					serverCycleLength = (((0.25 * 60) * 60) + 15) + (serverTime - serverStartTime);
					[3,format["<t color='#ff8000'><t size='2'><t align='center'>服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>管理员已调整重新启动时间。新的重新启动时间为15分钟。", round((serverCycleLength - serverStartTime) / 60)],false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
					sleep 10;
					publicVariable "serverCycleLength";//Broadcast length of time till next restart
					serv_mArmaCycle = serverCycleLength;
				};

				case 6: {//Restarts server in 1 minute
					serverCycleLength = (((0.01666 * 60) * 60) + 15) + (serverTime - serverStartTime);
					[3,format["<t color='#ff8000'><t size='2'><t align='center'>服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>管理员已调整重新启动时间。新的重新启动时间为1分钟。", round((serverCycleLength - serverStartTime) / 60)],false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
					sleep 10;
					publicVariable "serverCycleLength";//Broadcast length of time till next restart
					serv_mArmaCycle = serverCycleLength;
				};

				case 7: {//Force saves all vehicles -- this is only called in specific situations like if poseidon needs to terminate arma without doing proper restart
					[] call OES_fnc_persistentVehiclesSave;
					[] call OES_fnc_persistentGangVehiclesSave;
				};
			};
			serv_mArmaWebReboot = -1;
		};
	};
};