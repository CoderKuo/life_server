/*
    File: fn_handleLottery.sqf
    Description: 彩票系统处理 - 支持普通彩票和闪电彩
*/

params ["_type", "_player", ["_amount", 1], ["_lotteryType", "normal"]];

if (typeName _type != "STRING") exitWith {};
if (isNull _player) exitWith {};

private _isFlash = _lotteryType == "flash";
private _ticketPrice = if (_isFlash) then { 10000 } else { 50000 };
private _maxTickets = if (_isFlash) then { 5 } else { 10 };
private _cooldown = if (_isFlash) then { life_flash_lottery_cooldown } else { life_lotteryCooldown };
private _lotteryList = if (_isFlash) then { life_flash_lottery_list } else { life_lottery_list };

if (_cooldown) exitWith {};

switch (_type) do {
    case "check": {
        private _uid = getPlayerUID _player;
        private _index = [_uid, _lotteryList] call OEC_fnc_index;

        // 计算玩家已购买的票数
        private _playerTickets = 0;
        { if ((_x select 1) == _uid) then { _playerTickets = _playerTickets + 1 } } forEach _lotteryList;

        if !(_index isEqualTo -1) then {
            [format ["oev_inLottery_%1", _lotteryType], true] remoteExec ["OEC_fnc_netSetVar", _player, false];
        } else {
            [format ["oev_inLottery_%1", _lotteryType], false] remoteExec ["OEC_fnc_netSetVar", _player, false];
        };

        // 发送玩家已购票数
        [format ["oev_lotteryTickets_%1", _lotteryType], _playerTickets] remoteExec ["OEC_fnc_netSetVar", _player, false];

        // 发送检查完成标记
        ["oev_lotteryCheckDone", true] remoteExec ["OEC_fnc_netSetVar", _player, false];
    };

    case "add": {
        if (_amount <= 0) exitWith {};
        if (_amount > _maxTickets) then { _amount = _maxTickets };

        // 检查玩家已购票数
        private _uid = getPlayerUID _player;
        private _playerTickets = 0;
        { if ((_x select 1) == _uid) then { _playerTickets = _playerTickets + 1 } } forEach _lotteryList;

        if (_playerTickets >= _maxTickets) exitWith {
            ["oev_lotteryBuyResult", "max"] remoteExec ["OEC_fnc_netSetVar", _player, false];
        };

        // 限制购买数量
        private _canBuy = _maxTickets - _playerTickets;
        if (_amount > _canBuy) then { _amount = _canBuy };

        // 检查是否是第一个购买者，启动彩票
        private _isRunning = if (_isFlash) then { life_flash_lottery_running } else { life_runningLottery };
        if (!_isRunning && count _lotteryList == 0) then {
            [_lotteryType] spawn OES_fnc_runLottery;
        };

        // 添加票
        for "_i" from 1 to _amount do {
            if (_isFlash) then {
                life_flash_lottery_list pushBack [name _player, _uid];
            } else {
                life_lottery_list pushBack [name _player, _uid];
            };
        };

        // 更新玩家购买统计
        ["lottery_update_player_bought", [_uid, name _player, str _amount, str (_amount * _ticketPrice)]] call DB_fnc_miscMapper;

        // 发送成功消息
        ["oev_lotteryBuyResult", "success"] remoteExec ["OEC_fnc_netSetVar", _player, false];
    };

    case "getInfo": {
        // 获取彩票信息
        private _running = if (_isFlash) then { life_flash_lottery_running } else { life_runningLottery };
        private _round = if (_isFlash) then { life_flash_lottery_round } else { life_lottery_round };

        // 获取累积奖池
        private _jackpotKey = if (_isFlash) then { "jackpot_flash" } else { "jackpot_normal" };
        private _jackpotResult = ["lottery_get_config", [_jackpotKey]] call DB_fnc_miscMapper;
        private _jackpotVal = if (isNil "_jackpotResult" || {!(_jackpotResult isEqualType [])} || {count _jackpotResult == 0}) then { 0 } else { _jackpotResult select 0 };
        private _jackpot = if (_jackpotVal isEqualType 0) then { _jackpotVal } else { parseNumber _jackpotVal };

        private _ticketCount = count _lotteryList;
        private _uniquePlayers = [];
        { _uniquePlayers pushBackUnique (_x select 1) } forEach _lotteryList;
        private _playerCount = count _uniquePlayers;

        // 计算当前奖池
        private _taxRate = if (_isFlash) then { 0.10 } else { 0.05 };
        private _currentPool = (_ticketCount * _ticketPrice + _jackpot) * (1 - _taxRate);

        // 玩家已购票数
        private _uid = getPlayerUID _player;
        private _playerTickets = 0;
        { if ((_x select 1) == _uid) then { _playerTickets = _playerTickets + 1 } } forEach _lotteryList;

        // 发送信息
        private _info = [_running, _round, _currentPool, _ticketCount, _playerCount, _jackpot, _playerTickets, _ticketPrice, _maxTickets];
        [format ["oev_lotteryInfo_%1", _lotteryType], _info] remoteExec ["OEC_fnc_netSetVar", _player, false];
    };

    case "getHistory": {
        // 获取历史记录
        private _history = ["lottery_get_history", [_lotteryType]] call DB_fnc_miscMapper;
        if (isNil "_history") then { _history = [] };
        ["oev_lotteryHistory", _history] remoteExec ["OEC_fnc_netSetVar", _player, false];
    };

    case "getPlayerStats": {
        // 获取玩家统计
        private _uid = getPlayerUID _player;
        private _stats = ["lottery_get_player_stats", [_uid]] call DB_fnc_miscMapper;
        if (isNil "_stats") then { _stats = [] };
        ["oev_lotteryPlayerStats", _stats] remoteExec ["OEC_fnc_netSetVar", _player, false];
    };
};
