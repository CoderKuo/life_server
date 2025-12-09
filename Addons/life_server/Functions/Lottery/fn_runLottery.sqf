/*
    File: fn_runLottery.sqf
    Description: 彩票系统 - 支持累积奖池和多等级奖项
*/

params [["_lotteryType", "normal"]];

private _isFlash = _lotteryType == "flash";
private _ticketPrice = if (_isFlash) then { 10000 } else { 50000 };
private _duration = if (_isFlash) then { 300 } else { 1800 }; // 5分钟 或 30分钟
private _taxRate = if (_isFlash) then { 0.10 } else { 0.05 }; // 10% 或 5%
private _maxTickets = if (_isFlash) then { 5 } else { 10 };
private _lotteryList = if (_isFlash) then { life_flash_lottery_list } else { life_lottery_list };
private _lotteryName = if (_isFlash) then { "闪电彩" } else { "福利彩票" };

// 检查服务器重启时间
private _restartTime = round((serverCycleLength - (serverTime - serverStartTime)) / 60);
if (_restartTime < 35 && !_isFlash) exitWith {};
if (_restartTime < 10 && _isFlash) exitWith {};

// 检查是否已在运行
if (!_isFlash && life_runningLottery) exitWith {};
if (_isFlash && life_flash_lottery_running) exitWith {};

// 防止重复启动
uiSleep floor random 3;
if (!_isFlash && life_runningLottery) exitWith {};
if (_isFlash && life_flash_lottery_running) exitWith {};

// 设置运行状态
if (_isFlash) then {
    life_flash_lottery_running = true;
    publicVariable "life_flash_lottery_running";
} else {
    life_runningLottery = true;
    publicVariable "life_runningLottery";
};

// 增加期号
if (_isFlash) then {
    life_flash_lottery_round = life_flash_lottery_round + 1;
    publicVariable "life_flash_lottery_round";
} else {
    life_lottery_round = life_lottery_round + 1;
    publicVariable "life_lottery_round";
};

private _roundNumber = if (_isFlash) then { life_flash_lottery_round } else { life_lottery_round };

// 获取累积奖池
private _jackpotKey = if (_isFlash) then { "jackpot_flash" } else { "jackpot_normal" };
private _jackpotResult = ["lottery_get_config", [_jackpotKey]] call DB_fnc_miscMapper;
private _jackpotVal = if (isNil "_jackpotResult" || {!(_jackpotResult isEqualType [])} || {count _jackpotResult == 0}) then { 0 } else { _jackpotResult select 0 };
private _jackpot = if (_jackpotVal isEqualType 0) then { _jackpotVal } else { parseNumber _jackpotVal };
if (_jackpot < 0) then { _jackpot = 0 };

// 广播开始
private _jackpotText = if (_jackpot > 0) then {
    format ["<br/><t color='#ff9900'>累积奖池: $%1</t>", [_jackpot] call OEC_fnc_numberText]
} else { "" };

[3, format ["<t color='#ffdd00'><t size='2'><t align='center'>%1 第%2期<br/><t color='#eeeeff'><t align='center'><t size='1.2'>%1开卖了，快到附近的加油站买一张碰碰运气吧！%3<br /><br /><t color='#ffdd00'><t size='1.1'>%4分钟后开奖.",
    _lotteryName, _roundNumber, _jackpotText, _duration / 60], false, [], "life_lottery"] remoteExec ["OEC_fnc_broadcast", -2, false];

// 倒计时
private _time = _duration;
private _announcements = if (_isFlash) then { [240, 180, 120, 60, 30] } else { [1500, 1200, 900, 600, 300, 60] };

for "_i" from 0 to 1 step 0 do {
    if (_time <= 0) exitWith {};

    _lotteryList = if (_isFlash) then { life_flash_lottery_list } else { life_lottery_list };

    if (_time in _announcements) then {
        private _currentPool = (count _lotteryList) * _ticketPrice + _jackpot;
        private _poolAfterTax = _currentPool * (1 - _taxRate);

        [3, format ["<t color='#ffdd00'><t size='2'><t align='center'>%1 第%2期<br/><t color='#eeeeff'><t align='center'><t size='1.2'>当前奖池: $%3<br/>已售: %4张票<br/><br/><t color='#ffdd00'><t size='1.1'>%5后开奖",
            _lotteryName, _roundNumber, [_poolAfterTax] call OEC_fnc_numberText, count _lotteryList,
            if (_time >= 60) then { format ["%1分钟", _time / 60] } else { format ["%1秒", _time] }
        ], false, [], "life_lottery"] remoteExec ["OEC_fnc_broadcast", -2, false];
    };

    _time = _time - (if (_isFlash) then { 30 } else { 60 });
    uiSleep (if (_isFlash) then { 30 } else { 60 });
};

// 开奖
_lotteryList = if (_isFlash) then { life_flash_lottery_list } else { life_lottery_list };

if (count _lotteryList == 0) exitWith {
    [3, format ["<t color='#ffdd00'><t size='2'><t align='center'>%1 第%2期<br/><t color='#eeeeff'><t align='center'><t size='1.2'>本期无人购买彩票，彩票取消。", _lotteryName, _roundNumber], false, [], "life_lottery"] remoteExec ["OEC_fnc_broadcast", -2, false];

    // 重置状态
    if (_isFlash) then {
        life_flash_lottery_list = [];
        life_flash_lottery_running = false;
        publicVariable "life_flash_lottery_running";
    } else {
        life_lottery_list = [];
        life_runningLottery = false;
        publicVariable "life_runningLottery";
        life_lotteryCooldown = false;
        publicVariable "life_lotteryCooldown";
    };
};

// 计算奖池
private _totalPool = (count _lotteryList) * _ticketPrice + _jackpot;
private _poolAfterTax = _totalPool * (1 - _taxRate);
private _uniquePlayers = [];
{ _uniquePlayers pushBackUnique (_x select 1) } forEach _lotteryList;
private _playerCount = count _uniquePlayers;

// 抽奖函数
private _fnc_pickWinner = {
    params ["_list", "_excludeUIDs"];
    private _winner = [];
    private _picked = false;
    private _attempts = 0;

    while { !_picked && _attempts < 20 } do {
        private _candidate = _list select (floor random (count _list));
        if !(_candidate select 1 in _excludeUIDs) then {
            if ([_candidate select 1] call OEC_fnc_isUIDActive) then {
                _winner = _candidate;
                _picked = true;
            };
        };
        _attempts = _attempts + 1;
    };

    // 如果随机没找到，遍历查找
    if (!_picked) then {
        {
            if !(_x select 1 in _excludeUIDs) then {
                if ([_x select 1] call OEC_fnc_isUIDActive) exitWith {
                    _winner = _x;
                    _picked = true;
                };
            };
        } forEach _list;
    };

    [_winner, _picked]
};

private _winners = [];
private _excludeUIDs = [];

if (_isFlash) then {
    // 闪电彩：只有一个中奖者，100%奖池
    private _result = [_lotteryList, []] call _fnc_pickWinner;
    if (_result select 1) then {
        private _winner = _result select 0;
        _winners pushBack [_winner select 0, _winner select 1, _poolAfterTax, "特等奖"];
    };
} else {
    // 普通彩票：多等级奖项
    // 特等奖：50%
    private _result = [_lotteryList, _excludeUIDs] call _fnc_pickWinner;
    if (_result select 1) then {
        private _winner = _result select 0;
        private _prize = _poolAfterTax * 0.50;
        _winners pushBack [_winner select 0, _winner select 1, _prize, "特等奖"];
        _excludeUIDs pushBack (_winner select 1);
    };

    // 一等奖：2人，各12.5%
    for "_i" from 1 to 2 do {
        _result = [_lotteryList, _excludeUIDs] call _fnc_pickWinner;
        if (_result select 1) then {
            private _winner = _result select 0;
            private _prize = _poolAfterTax * 0.125;
            _winners pushBack [_winner select 0, _winner select 1, _prize, "一等奖"];
            _excludeUIDs pushBack (_winner select 1);
        };
    };

    // 二等奖：5人，各4%
    for "_i" from 1 to 5 do {
        _result = [_lotteryList, _excludeUIDs] call _fnc_pickWinner;
        if (_result select 1) then {
            private _winner = _result select 0;
            private _prize = _poolAfterTax * 0.04;
            _winners pushBack [_winner select 0, _winner select 1, _prize, "二等奖"];
            _excludeUIDs pushBack (_winner select 1);
        };
    };
};

// 处理结果
if (count _winners == 0) then {
    // 无人中奖，累积奖池
    private _newJackpot = _jackpot + (_totalPool * (1 - _taxRate));
    ["lottery_set_config", [_jackpotKey, str _newJackpot]] call DB_fnc_miscMapper;

    [3, format ["<t color='#ffdd00'><t size='2'><t align='center'>%1 第%2期<br/><t color='#eeeeff'><t align='center'><t size='1.2'>所有购买者均已离线，本期无人中奖！<br/><t color='#ff9900'>奖池累积至下期: $%3",
        _lotteryName, _roundNumber, [_newJackpot] call OEC_fnc_numberText], false, [], "life_lottery"] remoteExec ["OEC_fnc_broadcast", -2, false];

    // 保存历史记录
    ["lottery_add_history", [str _roundNumber, _lotteryType, str _totalPool, str (count _lotteryList), str _playerCount, str _newJackpot, "[]"]] call DB_fnc_miscMapper;
} else {
    // 有人中奖
    // 清空累积奖池
    ["lottery_set_config", [_jackpotKey, "0"]] call DB_fnc_miscMapper;

    // 发放奖金
    {
        _x params ["_name", "_uid", "_prize", "_prizeType"];
        private _playerNetID = [_uid] call OES_fnc_getPlayer;
        if !(_playerNetID isEqualTo 0) then {
            [1, _prize] remoteExec ["OEC_fnc_payPlayer", _playerNetID, false];
        };

        // 更新玩家统计
        private _historyJson = format ["[{""round"":%1,""type"":""%2"",""prize"":%3,""prizeType"":""%4""}]", _roundNumber, _lotteryType, round _prize, _prizeType];
        ["lottery_update_player_won", [_uid, _name, str (round _prize), _historyJson]] call DB_fnc_miscMapper;

        format ["-彩票- %1 (%2) 中了%3 %4 奖金: $%5", _name, _uid, _lotteryName, _prizeType, [_prize] call OEC_fnc_numberText] call OES_fnc_diagLog;
    } forEach _winners;

    // 广播结果
    private _winnerText = "";
    {
        _x params ["_name", "_uid", "_prize", "_prizeType"];
        _winnerText = _winnerText + format ["<br/>%1 %2: $%3",
            switch (_prizeType) do {
                case "特等奖": { "🏆" };
                case "一等奖": { "🥇" };
                case "二等奖": { "🥈" };
                default { "🎉" };
            },
            _name, [_prize] call OEC_fnc_numberText];
    } forEach _winners;

    for "_i" from 0 to 2 do {
        [3, format ["<t color='#ffdd00'><t size='2'><t align='center'>%1 第%2期 开奖结果<br/><t color='#eeeeff'><t align='center'><t size='1.2'>总奖池: $%3%4",
            _lotteryName, _roundNumber, [_poolAfterTax] call OEC_fnc_numberText, _winnerText], false, [], "life_lottery"] remoteExec ["OEC_fnc_broadcast", -2, false];
        uiSleep 1;
    };

    // 保存历史记录
    private _winnersJson = "[";
    {
        _x params ["_name", "_uid", "_prize", "_prizeType"];
        if (_forEachIndex > 0) then { _winnersJson = _winnersJson + "," };
        _winnersJson = _winnersJson + format ["{""name"":""%1"",""uid"":""%2"",""prize"":%3,""prizeType"":""%4""}", _name, _uid, round _prize, _prizeType];
    } forEach _winners;
    _winnersJson = _winnersJson + "]";

    ["lottery_add_history", [str _roundNumber, _lotteryType, str _totalPool, str (count _lotteryList), str _playerCount, str _jackpot, _winnersJson]] call DB_fnc_miscMapper;
};

// 冷却和重置
if (_isFlash) then {
    life_flash_lottery_cooldown = true;
    publicVariable "life_flash_lottery_cooldown";
    uiSleep 30;
    life_flash_lottery_list = [];
    life_flash_lottery_running = false;
    publicVariable "life_flash_lottery_running";
    life_flash_lottery_cooldown = false;
    publicVariable "life_flash_lottery_cooldown";
} else {
    life_lotteryCooldown = true;
    publicVariable "life_lotteryCooldown";
    uiSleep 60;
    life_lottery_list = [];
    life_runningLottery = false;
    publicVariable "life_runningLottery";
    life_lotteryCooldown = false;
    publicVariable "life_lotteryCooldown";
};
