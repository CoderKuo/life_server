/*
 * fn_casinoServer.sqf
 * 服务器端赌场结算系统
 * 所有赌博结果由服务器生成，防止客户端作弊
 */

params [
    ["_type", "", [""]],
    ["_game", "", [""]],
    ["_betAmount", 0, [0]],
    ["_extraData", [], [[]]]
];

// 获取调用者 - 使用 HashMap 缓存 O(1)
private _ownerID = remoteExecutedOwner;
private _player = [_ownerID] call OES_fnc_getPlayerByOwner;

if (isNull _player) exitWith {
    diag_log format ["[CasinoServer] ERROR: Cannot find player for owner %1", _ownerID];
};

private _uid = getPlayerUID _player;
private _playerName = name _player;

// 验证玩家状态
if (!alive _player) exitWith {
    ["casino_error", "你已死亡"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
};

// 验证下注金额 (只对需要下注的操作)
private _requiresBet = toLower _type in ["slots", "roulette", "blackjack_deal"];
if (_requiresBet && _betAmount <= 0) exitWith {
    ["casino_error", "无效的下注金额"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
};

// 从数据库获取玩家当前银行余额 (只在需要时)
private _currentBank = 0;
if (_requiresBet) then {
    private _bankResult = ["getbank", [_uid]] call DB_fnc_playerMapper;
    _currentBank = if (count _bankResult > 0) then { _bankResult select 0 } else { 0 };

    // 验证玩家是否有足够资金
    if (_currentBank < _betAmount) exitWith {
        ["casino_error", "银行余额不足"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
    };
} else {
    // 对于继续游戏的操作，从游戏状态获取余额
    private _bankResult = ["getbank", [_uid]] call DB_fnc_playerMapper;
    _currentBank = if (count _bankResult > 0) then { _bankResult select 0 } else { 0 };
};

private _result = [];
private _winAmount = 0;
private _logEvent = "";

switch (toLower _type) do {
    // ==========================================
    // 老虎机 (Slots)
    // ==========================================
    case "slots": {
        // 验证下注限制
        if (_betAmount < 10000) exitWith {
            ["casino_error", "老虎机最少下注 10,000"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };
        if (_betAmount > 100000) exitWith {
            ["casino_error", "老虎机最大赌注 100,000"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };

        // 服务器端生成随机结果
        private _symbol1Odds = [1, 7, 10, 30, 3, 10, 10, 10, 9, 6, 4];
        private _symbol2Odds = [7, 2, 10, 30, 3, 6, 12, 10, 10, 6, 4];
        private _symbol3Odds = [1, 6, 13, 30, 3, 10, 9, 10, 11, 3, 4];

        private _fnc_getSymbolIndex = {
            params ["_odds", "_roll"];
            private _index = 0;
            private _count = 1;
            {
                if (_roll >= _count && _roll < _count + _x) exitWith {
                    _index = _forEachIndex;
                };
                _count = _count + _x;
            } forEach _odds;
            _index
        };

        private _roll1 = ceil (random 99);
        private _roll2 = ceil (random 99);
        private _roll3 = ceil (random 99);

        private _sym1 = [_symbol1Odds, _roll1] call _fnc_getSymbolIndex;
        private _sym2 = [_symbol2Odds, _roll2] call _fnc_getSymbolIndex;
        private _sym3 = [_symbol3Odds, _roll3] call _fnc_getSymbolIndex;

        private _symbols = [_sym1, _sym2, _sym3];

        // 计算赔率
        private _multiply = 0;
        private _countArray = [];
        for "_i" from 0 to 10 do {
            private _cnt = {_x == _i} count _symbols;
            _countArray pushBack _cnt;
        };

        // 中奖规则
        if ((_countArray select 0) == 3) then { _multiply = 2; }; // 3个Olympus
        if ((_countArray select 1) >= 2) then { _multiply = 2; }; // 2+个Money
        if ((_countArray select 2) >= 1) then { _multiply = 2; }; // 1+个Redgull
        if ((_countArray select 3) == 3) then { _multiply = 2; }; // 3个Apple
        if ((_countArray select 4) >= 2) then { _multiply = 2; }; // 2+个Goldbar
        if ((_countArray select 5) >= 2) then { _multiply = 2; }; // 2+个Blasting Charge
        if ((_countArray select 6) == 3) then { _multiply = 2; }; // 3个Meth
        if ((_countArray select 7) >= 2) then { _multiply = 2; }; // 2+个Epipen
        if ((_countArray select 8) >= 2) then { _multiply = 2; }; // 2+个Dope shot
        if ((_countArray select 9) == 3) then { _multiply = 2; }; // 3个Emerald
        if ((_countArray select 10) == 3) then { _multiply = 2; }; // 3个Frog
        // 特殊组合
        if (_sym1 == 5 && _sym2 == 4 && _sym3 == 4) then { _multiply = 2; };

        _winAmount = _betAmount * _multiply;
        _result = ["slots_result", _symbols, _multiply, _winAmount];
        _logEvent = if (_multiply > 0) then { "Player Won Slots" } else { "Player Lost Slots" };
    };

    // ==========================================
    // 轮盘赌 (Roulette)
    // ==========================================
    case "roulette": {
        // 验证下注限制
        if (_betAmount < 1000) exitWith {
            ["casino_error", "轮盘赌最少下注 1,000"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };
        if (_betAmount > 10000000) exitWith {
            ["casino_error", "轮盘赌最大赌注 10,000,000"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };

        // 获取玩家选择的颜色 (0=红, 1=黑, 2=绿)
        private _playerChoice = _extraData param [0, -1, [0]];
        if (_playerChoice < 0 || _playerChoice > 2) exitWith {
            ["casino_error", "无效的颜色选择"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };

        // 服务器端生成随机结果 (0-37, 0和37为绿色)
        private _num = floor (random 38);
        private _resultColor = -1;

        if (_num == 0 || _num == 37) then {
            _resultColor = 2; // 绿色
        } else {
            if ((_num >= 1 && _num <= 10) || (_num >= 19 && _num <= 28)) then {
                if (_num % 2 == 0) then {
                    _resultColor = 1; // 黑色
                } else {
                    _resultColor = 0; // 红色
                };
            } else {
                if (_num % 2 == 0) then {
                    _resultColor = 0; // 红色
                } else {
                    _resultColor = 1; // 黑色
                };
            };
        };

        // 计算赢取金额
        private _multiply = 0;
        if (_playerChoice == _resultColor) then {
            if (_resultColor == 2) then {
                _multiply = 14; // 绿色 14倍
                _logEvent = "Player Won Roulette Green";
            } else {
                _multiply = 2; // 红/黑 2倍
                _logEvent = "Player Won Roulette";
            };
        } else {
            _logEvent = "Player Lost Roulette";
        };

        _winAmount = _betAmount * _multiply;
        _result = ["roulette_result", _num, _resultColor, _playerChoice, _multiply, _winAmount];
    };

    // ==========================================
    // 21点 (Blackjack) - 发牌
    // ==========================================
    case "blackjack_deal": {
        // 验证下注限制
        if (_betAmount < 1000) exitWith {
            ["casino_error", "21点最少下注 1,000"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };
        if (_betAmount > 10000000) exitWith {
            ["casino_error", "21点最大赌注 10,000,000"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };

        // 创建3副牌
        private _cards = [];
        for "_deck" from 1 to 3 do {
            for "_suite" from 0 to 3 do {
                for "_num" from 2 to 14 do {
                    _cards pushBack [_num, _suite];
                };
            };
        };

        // 洗牌函数
        private _fnc_drawCard = {
            params ["_deck"];
            private _pick = floor (random (count _deck));
            private _card = _deck select _pick;
            _deck deleteAt _pick;
            _card
        };

        // 发4张牌
        private _dealerCard1 = [_cards] call _fnc_drawCard; // 庄家暗牌
        private _playerCard1 = [_cards] call _fnc_drawCard;
        private _dealerCard2 = [_cards] call _fnc_drawCard; // 庄家明牌
        private _playerCard2 = [_cards] call _fnc_drawCard;

        private _playerDeck = [_playerCard1, _playerCard2];
        private _dealerDeck = [_dealerCard1, _dealerCard2];

        // 计算牌值
        private _fnc_getDeckValue = {
            params ["_deck"];
            private _value = 0;
            private _aces = 0;
            {
                private _cardNum = _x select 0;
                switch (_cardNum) do {
                    case 11: { _aces = _aces + 1; }; // Ace
                    case 12;
                    case 13;
                    case 14: { _value = _value + 10; }; // J/Q/K
                    default { _value = _value + _cardNum; };
                };
            } forEach _deck;
            for "_i" from 1 to _aces do {
                if (_value + 11 > 21) then {
                    _value = _value + 1;
                } else {
                    _value = _value + 11;
                };
            };
            _value
        };

        private _playerValue = [_playerDeck] call _fnc_getDeckValue;
        private _dealerValue = [_dealerDeck] call _fnc_getDeckValue;

        // 生成会话ID用于后续操作
        private _sessionId = format ["%1_%2_%3", _uid, floor time, floor (random 10000)];

        // 存储游戏状态到服务器
        private _gameState = [_betAmount, _cards, _playerDeck, _dealerDeck, _playerValue, _dealerValue];
        missionNamespace setVariable [format ["blackjack_%1", _uid], _gameState];

        // 检查自然21点
        private _gameOver = false;
        private _multiply = 0;

        if (_playerValue == 21 && _dealerValue == 21) then {
            // 平局
            _multiply = 1;
            _winAmount = _betAmount;
            _gameOver = true;
            _logEvent = "Player Push Blackjack Natural";
        } else {
            if (_playerValue == 21) then {
                // 玩家自然21点
                _multiply = 2.5;
                _winAmount = _betAmount * 2.5;
                _gameOver = true;
                _logEvent = "Player Won Blackjack Natural";
            } else {
                if (_dealerValue == 21) then {
                    // 庄家自然21点
                    _multiply = 0;
                    _winAmount = 0;
                    _gameOver = true;
                    _logEvent = "Player Lost Blackjack Natural";
                };
            };
        };

        _result = ["blackjack_deal_result", _playerDeck, [[-1,-1], _dealerCard2], _playerValue, _dealerCard2, _gameOver, _multiply, _winAmount, _sessionId];
    };

    // ==========================================
    // 21点 - 要牌 (Hit)
    // ==========================================
    case "blackjack_hit": {
        private _gameState = missionNamespace getVariable [format ["blackjack_%1", _uid], []];
        if (count _gameState == 0) exitWith {
            ["casino_error", "无效的游戏状态"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };

        _gameState params ["_bet", "_cards", "_playerDeck", "_dealerDeck", "_playerValue", "_dealerValue"];
        _betAmount = _bet;

        // 发一张牌给玩家
        private _pick = floor (random (count _cards));
        private _newCard = _cards select _pick;
        _cards deleteAt _pick;
        _playerDeck pushBack _newCard;

        // 重新计算
        private _fnc_getDeckValue = {
            params ["_deck"];
            private _value = 0;
            private _aces = 0;
            {
                private _cardNum = _x select 0;
                switch (_cardNum) do {
                    case 11: { _aces = _aces + 1; };
                    case 12;
                    case 13;
                    case 14: { _value = _value + 10; };
                    default { _value = _value + _cardNum; };
                };
            } forEach _deck;
            for "_i" from 1 to _aces do {
                if (_value + 11 > 21) then { _value = _value + 1; } else { _value = _value + 11; };
            };
            _value
        };

        _playerValue = [_playerDeck] call _fnc_getDeckValue;

        // 更新游戏状态
        _gameState = [_bet, _cards, _playerDeck, _dealerDeck, _playerValue, _dealerValue];
        missionNamespace setVariable [format ["blackjack_%1", _uid], _gameState];

        private _bust = _playerValue > 21;
        _result = ["blackjack_hit_result", _newCard, _playerValue, _bust];

        if (_bust) then {
            _winAmount = 0;
            _logEvent = "Player Lost Blackjack Bust";
            missionNamespace setVariable [format ["blackjack_%1", _uid], nil];
        };
    };

    // ==========================================
    // 21点 - 停牌 (Stand)
    // ==========================================
    case "blackjack_stand": {
        private _gameState = missionNamespace getVariable [format ["blackjack_%1", _uid], []];
        if (count _gameState == 0) exitWith {
            ["casino_error", "无效的游戏状态"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };

        _gameState params ["_bet", "_cards", "_playerDeck", "_dealerDeck", "_playerValue", "_dealerValue"];
        _betAmount = _bet;

        private _fnc_getDeckValue = {
            params ["_deck"];
            private _value = 0;
            private _aces = 0;
            {
                private _cardNum = _x select 0;
                switch (_cardNum) do {
                    case 11: { _aces = _aces + 1; };
                    case 12;
                    case 13;
                    case 14: { _value = _value + 10; };
                    default { _value = _value + _cardNum; };
                };
            } forEach _deck;
            for "_i" from 1 to _aces do {
                if (_value + 11 > 21) then { _value = _value + 1; } else { _value = _value + 11; };
            };
            _value
        };

        // 庄家AI - 站在17点或更高
        private _dealerDrawnCards = [];
        while {_dealerValue < 17 || (_dealerValue < _playerValue && _dealerValue < 21)} do {
            private _pick = floor (random (count _cards));
            private _newCard = _cards select _pick;
            _cards deleteAt _pick;
            _dealerDeck pushBack _newCard;
            _dealerDrawnCards pushBack _newCard;
            _dealerValue = [_dealerDeck] call _fnc_getDeckValue;
        };

        // 判断结果
        private _multiply = 0;
        if (_playerValue > 21) then {
            _multiply = 0;
            _logEvent = "Player Lost Blackjack Bust";
        } else {
            if (_dealerValue > 21) then {
                _multiply = 2;
                _logEvent = "Player Won Blackjack Dealer Bust";
            } else {
                if (_playerValue > _dealerValue) then {
                    _multiply = 2;
                    _logEvent = "Player Won Blackjack";
                } else {
                    if (_playerValue == _dealerValue) then {
                        _multiply = 1;
                        _logEvent = "Player Push Blackjack";
                    } else {
                        _multiply = 0;
                        _logEvent = "Player Lost Blackjack";
                    };
                };
            };
        };

        _winAmount = _betAmount * _multiply;
        _result = ["blackjack_stand_result", _dealerDeck, _dealerDrawnCards, _dealerValue, _multiply, _winAmount];

        // 清理游戏状态
        missionNamespace setVariable [format ["blackjack_%1", _uid], nil];
    };

    // ==========================================
    // 21点 - 加倍 (Double Down)
    // ==========================================
    case "blackjack_double": {
        private _gameState = missionNamespace getVariable [format ["blackjack_%1", _uid], []];
        if (count _gameState == 0) exitWith {
            ["casino_error", "无效的游戏状态"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };

        _gameState params ["_bet", "_cards", "_playerDeck", "_dealerDeck", "_playerValue", "_dealerValue"];

        // 验证玩家有足够资金加倍
        if (_currentBank < _bet * 2) exitWith {
            ["casino_error", "银行余额不足以加倍"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };

        // 验证只能在9/10/11点时加倍
        if !(_playerValue in [9, 10, 11]) exitWith {
            ["casino_error", "只能在9、10、11点时加倍"] remoteExec ["OEC_fnc_casinoResult", _ownerID];
        };

        _betAmount = _bet * 2;

        // 发一张牌给玩家
        private _pick = floor (random (count _cards));
        private _newCard = _cards select _pick;
        _cards deleteAt _pick;
        _playerDeck pushBack _newCard;

        private _fnc_getDeckValue = {
            params ["_deck"];
            private _value = 0;
            private _aces = 0;
            {
                private _cardNum = _x select 0;
                switch (_cardNum) do {
                    case 11: { _aces = _aces + 1; };
                    case 12;
                    case 13;
                    case 14: { _value = _value + 10; };
                    default { _value = _value + _cardNum; };
                };
            } forEach _deck;
            for "_i" from 1 to _aces do {
                if (_value + 11 > 21) then { _value = _value + 1; } else { _value = _value + 11; };
            };
            _value
        };

        _playerValue = [_playerDeck] call _fnc_getDeckValue;

        // 更新游戏状态
        _gameState = [_betAmount, _cards, _playerDeck, _dealerDeck, _playerValue, _dealerValue];
        missionNamespace setVariable [format ["blackjack_%1", _uid], _gameState];

        // 返回新牌，然后自动执行stand
        _result = ["blackjack_double_result", _newCard, _playerValue];
    };
};

// 处理资金变化
if (count _result > 0 && !(_result select 0 in ["blackjack_deal_result", "blackjack_hit_result", "blackjack_double_result"])) then {
    // 检查是否为21点结算（已在发牌时扣款）
    private _isBlackjackSettle = (_result select 0) in ["blackjack_stand_result"];

    // 对于21点：发牌时已扣款，结算时只需返还赢取金额
    // 对于其他游戏：正常计算 netChange
    private _netChange = 0;
    if (_isBlackjackSettle) then {
        // 21点结算：只返还赢取金额（输了=0，平局=本金，赢了=本金*2）
        _netChange = _winAmount;
    } else {
        // 其他游戏（老虎机、轮盘）：正常计算差额
        _netChange = _winAmount - _betAmount;
    };

    // 更新数据库
    if (_netChange != 0) then {
        ["incrementbank", [_uid, _netChange]] call DB_fnc_playerMapper;
    };

    // 记录日志
    private _profit = if (_isBlackjackSettle) then { _winAmount - _betAmount } else { _netChange };
    [_player, "casino", format ["%1 | bet:%2 win:%3 net:%4", _logEvent, _betAmount, _winAmount, _profit], 0, 1] call OES_fnc_AdvancedLog;

    // 更新统计 - 使用安全数字函数避免科学计数法
    if (_winAmount > _betAmount) then {
        // 更新赌场赢取统计
        private _statWin = ["format", _winAmount - _betAmount] call OES_fnc_safeNumber;
        [format ["UPDATE stats SET casino_winnings = casino_winnings + %1, casino_uses = casino_uses + 1 WHERE playerid='%2'", _statWin, _uid], 2] call OES_fnc_asyncCall;
    } else {
        if (_winAmount < _betAmount) then {
            // 更新赌场损失统计
            private _statLoss = ["format", _betAmount - _winAmount] call OES_fnc_safeNumber;
            [format ["UPDATE stats SET casino_losses = casino_losses + %1, casino_uses = casino_uses + 1 WHERE playerid='%2'", _statLoss, _uid], 2] call OES_fnc_asyncCall;
        } else {
            // 平局，只更新使用次数
            [format ["UPDATE stats SET casino_uses = casino_uses + 1 WHERE playerid='%1'", _uid], 2] call OES_fnc_asyncCall;
        };
    };

    // 发送新的银行余额给客户端
    private _newBank = _currentBank + _netChange;
    _result pushBack _newBank;
};

// 如果是21点发牌，扣除下注金额
if (_result select 0 == "blackjack_deal_result") then {
    ["incrementbank", [_uid, -_betAmount]] call DB_fnc_playerMapper;

    // 检查是否游戏结束（自然21点等）
    if (_result select 5) then { // _gameOver
        private _mult = _result select 6;
        if (_mult > 0) then {
            ["incrementbank", [_uid, _betAmount * _mult]] call DB_fnc_playerMapper;
        };

        // 记录日志
        // 参数: [player, action, actionValue, actionId, instanceId]
        [_player, "casino_blackjack", format ["%1 | bet:%2 win:%3", _logEvent, _betAmount, _winAmount], 0, 1] call OES_fnc_AdvancedLog;
    };

    private _newBank = _currentBank - _betAmount + _winAmount;
    _result pushBack _newBank;
};

// 21点加倍时扣除额外下注
if (_result select 0 == "blackjack_double_result") then {
    private _gameState = missionNamespace getVariable [format ["blackjack_%1", _uid], []];
    private _originalBet = (_gameState select 0) / 2;
    ["incrementbank", [_uid, -_originalBet]] call DB_fnc_playerMapper;
};

// 发送结果给客户端
_result remoteExec ["OEC_fnc_casinoResult", _ownerID];

diag_log format ["[CasinoServer] %1 played %2, bet: %3, win: %4", _playerName, _type, _betAmount, _winAmount];
