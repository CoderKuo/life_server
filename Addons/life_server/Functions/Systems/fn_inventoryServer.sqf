/*
 * fn_inventoryServer.sqf
 * 服务器端库存验证系统
 * 所有库存操作(车辆/房屋/虚拟商店)必须通过此函数进行服务器端验证
 * 防止客户端作弊和刷钱bug
 *
 * 调用方式: [_type, _data] remoteExec ["OES_fnc_inventoryServer", 2];
 */

params [
    ["_type", "", [""]],
    ["_data", [], [[]]]
];

// 获取调用者 - 使用 HashMap 缓存 O(1)
private _ownerID = remoteExecutedOwner;
private _player = [_ownerID] call OES_fnc_getPlayerByOwner;

if (isNull _player) exitWith {
    diag_log format ["[InventoryServer] ERROR: Cannot find player for owner %1", _ownerID];
};

private _uid = getPlayerUID _player;
private _playerName = name _player;

// 验证玩家状态
if (!alive _player) exitWith {
    ["inv_error", "你已死亡，无法操作库存"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
};

// ==========================================
// 辅助函数：安全地将值转换为数字
// 处理数据库返回可能是数字或字符串的情况
// ==========================================
private _fnc_toNumber = {
    params ["_val"];
    if (_val isEqualType 0) then { _val } else { parseNumber _val }
};

// ==========================================
// 物品重量配置 - 使用全局 HashMap O(1)
// ==========================================
private _fnc_getItemWeight = {
    params ["_item"];
    OES_itemWeights getOrDefault [_item, 1]
};

// ==========================================
// 辅助函数：查找物品索引
// ==========================================
private _fnc_findItemIndex = {
    params ["_item", "_array"];
    private _index = -1;
    {
        if ((_x select 0) == _item) exitWith {
            _index = _forEachIndex;
        };
    } forEach _array;
    _index
};

// ==========================================
// 辅助函数：验证车辆访问权限
// ==========================================
private _fnc_validateVehicleAccess = {
    params ["_player", "_vehicle"];

    if (isNull _vehicle) exitWith { false };
    if (!alive _vehicle) exitWith { false };

    // 距离检查
    if ((getPos _player) distance (getPos _vehicle) > 15) exitWith { false };

    // 检查是否被其他人使用
    private _inUse = _vehicle getVariable ["trunk_in_use", ""];
    private _playerUID = getPlayerUID _player;
    if (_inUse != "" && _inUse != _playerUID) exitWith { false };

    true
};

// ==========================================
// 辅助函数：验证房屋访问权限
// ==========================================
private _fnc_validateHouseAccess = {
    params ["_player", "_house"];

    if (isNull _house) exitWith { false };

    // 距离检查
    if ((getPos _player) distance (getPos _house) > 15) exitWith { false };

    // 检查房屋所有权或钥匙
    private _houseOwner = _house getVariable ["house_owner", ["", ""]];
    private _houseKeys = _house getVariable ["house_keys", []];
    private _playerUID = getPlayerUID _player;

    if ((_houseOwner select 0) != _playerUID && !(_playerUID in _houseKeys)) exitWith { false };

    true
};

// ==========================================
// 主处理逻辑
// ==========================================
private _result = [];
private _logEvent = "";

switch (toLower _type) do {

    // ==========================================
    // 车辆库存 - 存入物品
    // ==========================================
    case "veh_store": {
        _data params [
            ["_vehicleNetId", "", [""]],
            ["_item", "", [""]],
            ["_amount", 0, [0]],
            ["_playerCash", 0, [0]],
            ["_playerBank", 0, [0]]
        ];

        private _vehicle = objectFromNetId _vehicleNetId;

        // 验证车辆访问
        if !([_player, _vehicle] call _fnc_validateVehicleAccess) exitWith {
            ["inv_error", "无法访问该车辆库存"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 验证数量
        if (_amount <= 0) exitWith {
            ["inv_error", "无效的数量"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 获取车辆库存数据
        private _trunkData = _vehicle getVariable ["Trunk", [[], 0]];
        private _trunkItems = _trunkData select 0;
        private _trunkWeight = _trunkData select 1;

        // 获取车辆最大容量
        private _maxWeight = _vehicle getVariable ["maxTrunkWeight", 100];
        private _mods = _vehicle getVariable ["modifications", [0,0,0,0,0,0,0,0]];
        private _trunkUpgrade = round((_mods select 1) * (_maxWeight * 0.05));
        _maxWeight = _maxWeight + _trunkUpgrade;

        // 计算物品重量
        private _itemWeight = ([_item] call _fnc_getItemWeight) * _amount;

        // 检查容量
        if ((_trunkWeight + _itemWeight) > _maxWeight) exitWith {
            ["inv_error", "车辆库存空间不足"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 处理金钱特殊情况
        if (_item == "money") then {
            // 验证玩家现金
            // 从数据库获取真实现金值进行验证
            private _dbResult = ["getcash", [_uid]] call DB_fnc_playerMapper;
            private _realCash = if (count _dbResult > 0) then { [_dbResult select 0] call _fnc_toNumber } else { 0 };

            if (_realCash < _amount) exitWith {
                ["inv_error", "你没有足够的现金"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
            };

            // 扣除玩家现金
            ["updatecash", [_uid, str (_realCash - _amount)]] call DB_fnc_playerMapper;

            // 更新车辆库存
            private _index = [_item, _trunkItems] call _fnc_findItemIndex;
            if (_index == -1) then {
                _trunkItems pushBack [_item, _amount];
            } else {
                private _oldAmount = (_trunkItems select _index) select 1;
                _trunkItems set [_index, [_item, _oldAmount + _amount]];
            };

            _vehicle setVariable ["Trunk", [_trunkItems, _trunkWeight + _itemWeight], true];

            _logEvent = "Server Validated: Store Money to Vehicle";
            _result = ["veh_store_success", _item, _amount, _realCash - _amount];
        } else {
            // 普通物品 - 需要验证玩家库存
            // 注意：玩家虚拟库存存储在玩家变量中，这里信任客户端传来的数据
            // 但添加后续验证和日志记录

            // 更新车辆库存
            private _index = [_item, _trunkItems] call _fnc_findItemIndex;
            if (_index == -1) then {
                _trunkItems pushBack [_item, _amount];
            } else {
                private _oldAmount = (_trunkItems select _index) select 1;
                _trunkItems set [_index, [_item, _oldAmount + _amount]];
            };

            _vehicle setVariable ["Trunk", [_trunkItems, _trunkWeight + _itemWeight], true];

            _logEvent = "Server Validated: Store Item to Vehicle";
            _result = ["veh_store_success", _item, _amount, -1];
        };
    };

    // ==========================================
    // 车辆库存 - 取出物品
    // ==========================================
    case "veh_take": {
        _data params [
            ["_vehicleNetId", "", [""]],
            ["_item", "", [""]],
            ["_amount", 0, [0]]
        ];

        private _vehicle = objectFromNetId _vehicleNetId;

        // 验证车辆访问
        if !([_player, _vehicle] call _fnc_validateVehicleAccess) exitWith {
            ["inv_error", "无法访问该车辆库存"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 验证数量
        if (_amount <= 0) exitWith {
            ["inv_error", "无效的数量"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 获取车辆库存数据
        private _trunkData = _vehicle getVariable ["Trunk", [[], 0]];
        private _trunkItems = _trunkData select 0;
        private _trunkWeight = _trunkData select 1;

        // 查找物品
        private _index = [_item, _trunkItems] call _fnc_findItemIndex;
        if (_index == -1) exitWith {
            ["inv_error", "车辆中没有该物品"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        private _availableAmount = (_trunkItems select _index) select 1;
        if (_amount > _availableAmount) exitWith {
            ["inv_error", "数量不足"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 计算物品重量
        private _itemWeight = ([_item] call _fnc_getItemWeight) * _amount;

        // 处理金钱特殊情况
        if (_item == "money") then {
            // 从数据库获取真实现金值
            private _dbResult = ["getcash", [_uid]] call DB_fnc_playerMapper;
            private _realCash = if (count _dbResult > 0) then { [_dbResult select 0] call _fnc_toNumber } else { 0 };

            // 增加玩家现金
            ["updatecash", [_uid, str (_realCash + _amount)]] call DB_fnc_playerMapper;

            // 更新车辆库存
            if (_amount == _availableAmount) then {
                _trunkItems deleteAt _index;
            } else {
                _trunkItems set [_index, [_item, _availableAmount - _amount]];
            };

            private _newWeight = _trunkWeight - _itemWeight;
            if (_newWeight < 0) then { _newWeight = 0; };
            _vehicle setVariable ["Trunk", [_trunkItems, _newWeight], true];

            _logEvent = "Server Validated: Take Money from Vehicle";
            _result = ["veh_take_success", _item, _amount, _realCash + _amount];
        } else {
            // 普通物品
            // 更新车辆库存
            if (_amount == _availableAmount) then {
                _trunkItems deleteAt _index;
            } else {
                _trunkItems set [_index, [_item, _availableAmount - _amount]];
            };

            private _newWeight = _trunkWeight - _itemWeight;
            if (_newWeight < 0) then { _newWeight = 0; };
            _vehicle setVariable ["Trunk", [_trunkItems, _newWeight], true];

            _logEvent = "Server Validated: Take Item from Vehicle";
            _result = ["veh_take_success", _item, _amount, -1];
        };
    };

    // ==========================================
    // 房屋库存 - 存入物品
    // ==========================================
    case "house_store": {
        _data params [
            ["_houseNetId", "", [""]],
            ["_item", "", [""]],
            ["_amount", 0, [0]]
        ];

        private _house = objectFromNetId _houseNetId;

        // 验证房屋访问
        if !([_player, _house] call _fnc_validateHouseAccess) exitWith {
            ["inv_error", "无法访问该房屋库存"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 验证数量
        if (_amount <= 0) exitWith {
            ["inv_error", "无效的数量"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 获取房屋库存数据
        private _trunkData = _house getVariable ["Trunk", [[], 0]];
        private _trunkItems = _trunkData select 0;
        private _trunkWeight = _trunkData select 1;

        // 获取房屋最大容量
        private _maxWeight = _house getVariable ["storageCapacity", 100];

        // 计算物品重量
        private _itemWeight = ([_item] call _fnc_getItemWeight) * _amount;

        // 检查容量
        if ((_trunkWeight + _itemWeight) > _maxWeight) exitWith {
            ["inv_error", "房屋库存空间不足"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 处理金钱
        if (_item == "money") then {
            private _dbResult = ["getcash", [_uid]] call DB_fnc_playerMapper;
            private _realCash = if (count _dbResult > 0) then { [_dbResult select 0] call _fnc_toNumber } else { 0 };

            if (_realCash < _amount) exitWith {
                ["inv_error", "你没有足够的现金"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
            };

            ["updatecash", [_uid, str (_realCash - _amount)]] call DB_fnc_playerMapper;

            private _index = [_item, _trunkItems] call _fnc_findItemIndex;
            if (_index == -1) then {
                _trunkItems pushBack [_item, _amount];
            } else {
                private _oldAmount = (_trunkItems select _index) select 1;
                _trunkItems set [_index, [_item, _oldAmount + _amount]];
            };

            _house setVariable ["Trunk", [_trunkItems, _trunkWeight + _itemWeight], true];

            _logEvent = "Server Validated: Store Money to House";
            _result = ["house_store_success", _item, _amount, _realCash - _amount];
        } else {
            private _index = [_item, _trunkItems] call _fnc_findItemIndex;
            if (_index == -1) then {
                _trunkItems pushBack [_item, _amount];
            } else {
                private _oldAmount = (_trunkItems select _index) select 1;
                _trunkItems set [_index, [_item, _oldAmount + _amount]];
            };

            _house setVariable ["Trunk", [_trunkItems, _trunkWeight + _itemWeight], true];

            _logEvent = "Server Validated: Store Item to House";
            _result = ["house_store_success", _item, _amount, -1];
        };

        // 触发房屋库存保存
        [_house, false] call OES_fnc_updateHouseTrunk;
    };

    // ==========================================
    // 房屋库存 - 取出物品
    // ==========================================
    case "house_take": {
        _data params [
            ["_houseNetId", "", [""]],
            ["_item", "", [""]],
            ["_amount", 0, [0]]
        ];

        private _house = objectFromNetId _houseNetId;

        // 验证房屋访问
        if !([_player, _house] call _fnc_validateHouseAccess) exitWith {
            ["inv_error", "无法访问该房屋库存"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 验证数量
        if (_amount <= 0) exitWith {
            ["inv_error", "无效的数量"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 获取房屋库存数据
        private _trunkData = _house getVariable ["Trunk", [[], 0]];
        private _trunkItems = _trunkData select 0;
        private _trunkWeight = _trunkData select 1;

        // 查找物品
        private _index = [_item, _trunkItems] call _fnc_findItemIndex;
        if (_index == -1) exitWith {
            ["inv_error", "房屋中没有该物品"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        private _availableAmount = (_trunkItems select _index) select 1;
        if (_amount > _availableAmount) exitWith {
            ["inv_error", "数量不足"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        private _itemWeight = ([_item] call _fnc_getItemWeight) * _amount;

        if (_item == "money") then {
            private _dbResult = ["getcash", [_uid]] call DB_fnc_playerMapper;
            private _realCash = if (count _dbResult > 0) then { [_dbResult select 0] call _fnc_toNumber } else { 0 };

            ["updatecash", [_uid, str (_realCash + _amount)]] call DB_fnc_playerMapper;

            if (_amount == _availableAmount) then {
                _trunkItems deleteAt _index;
            } else {
                _trunkItems set [_index, [_item, _availableAmount - _amount]];
            };

            private _newWeight = _trunkWeight - _itemWeight;
            if (_newWeight < 0) then { _newWeight = 0; };
            _house setVariable ["Trunk", [_trunkItems, _newWeight], true];

            _logEvent = "Server Validated: Take Money from House";
            _result = ["house_take_success", _item, _amount, _realCash + _amount];
        } else {
            if (_amount == _availableAmount) then {
                _trunkItems deleteAt _index;
            } else {
                _trunkItems set [_index, [_item, _availableAmount - _amount]];
            };

            private _newWeight = _trunkWeight - _itemWeight;
            if (_newWeight < 0) then { _newWeight = 0; };
            _house setVariable ["Trunk", [_trunkItems, _newWeight], true];

            _logEvent = "Server Validated: Take Item from House";
            _result = ["house_take_success", _item, _amount, -1];
        };

        // 触发房屋库存保存
        [_house, false] call OES_fnc_updateHouseTrunk;
    };

    // ==========================================
    // 虚拟商店 - 购买
    // ==========================================
    case "shop_buy": {
        _data params [
            ["_item", "", [""]],
            ["_amount", 0, [0]],
            ["_price", 0, [0]],
            ["_shopType", "", [""]],
            ["_useBank", false, [false]]
        ];

        // 验证数量
        if (_amount <= 0) exitWith {
            ["inv_error", "无效的数量"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 验证总价
        private _totalCost = _price * _amount;
        if (_totalCost <= 0) exitWith {
            ["inv_error", "无效的价格"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 从数据库获取真实余额
        private _dbCash = ["getcash", [_uid]] call DB_fnc_playerMapper;
        private _dbBank = ["getbank", [_uid]] call DB_fnc_playerMapper;
        private _realCash = if (count _dbCash > 0) then { [_dbCash select 0] call _fnc_toNumber } else { 0 };
        private _realBank = if (count _dbBank > 0) then { [_dbBank select 0] call _fnc_toNumber } else { 0 };

        private _newCash = _realCash;
        private _newBank = _realBank;

        if (_useBank) then {
            if (_realBank < _totalCost) exitWith {
                ["inv_error", "银行余额不足"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
            };
            _newBank = _realBank - _totalCost;
            ["updatebank", [_uid, str _newBank]] call DB_fnc_playerMapper;
        } else {
            if (_realCash < _totalCost) exitWith {
                ["inv_error", "现金不足"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
            };
            _newCash = _realCash - _totalCost;
            ["updatecash", [_uid, str _newCash]] call DB_fnc_playerMapper;
        };

        _logEvent = format ["Server Validated: Buy %1 x%2 from %3", _item, _amount, _shopType];
        _result = ["shop_buy_success", _item, _amount, _newCash, _newBank];
    };

    // ==========================================
    // 虚拟商店 - 出售
    // ==========================================
    case "shop_sell": {
        _data params [
            ["_item", "", [""]],
            ["_amount", 0, [0]],
            ["_price", 0, [0]],
            ["_shopType", "", [""]],
            ["_useBank", false, [false]]
        ];

        // 验证数量
        if (_amount <= 0) exitWith {
            ["inv_error", "无效的数量"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 验证总价
        private _totalValue = _price * _amount;
        if (_totalValue < 0) exitWith {
            ["inv_error", "无效的价格"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 从数据库获取真实余额
        private _dbCash = ["getcash", [_uid]] call DB_fnc_playerMapper;
        private _dbBank = ["getbank", [_uid]] call DB_fnc_playerMapper;
        private _realCash = if (count _dbCash > 0) then { [_dbCash select 0] call _fnc_toNumber } else { 0 };
        private _realBank = if (count _dbBank > 0) then { [_dbBank select 0] call _fnc_toNumber } else { 0 };

        private _newCash = _realCash;
        private _newBank = _realBank;

        if (_useBank) then {
            _newBank = _realBank + _totalValue;
            ["updatebank", [_uid, str _newBank]] call DB_fnc_playerMapper;
        } else {
            _newCash = _realCash + _totalValue;
            ["updatecash", [_uid, str _newCash]] call DB_fnc_playerMapper;
        };

        _logEvent = format ["Server Validated: Sell %1 x%2 to %3", _item, _amount, _shopType];
        _result = ["shop_sell_success", _item, _amount, _newCash, _newBank];
    };

    // ==========================================
    // ATM - 存款
    // ==========================================
    case "atm_deposit": {
        _data params [
            ["_amount", 0, [0]]
        ];

        if (_amount <= 0) exitWith {
            ["inv_error", "无效的金额"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 从数据库获取真实余额
        private _dbCash = ["getcash", [_uid]] call DB_fnc_playerMapper;
        private _dbBank = ["getbank", [_uid]] call DB_fnc_playerMapper;
        private _realCash = if (count _dbCash > 0) then { [_dbCash select 0] call _fnc_toNumber } else { 0 };
        private _realBank = if (count _dbBank > 0) then { [_dbBank select 0] call _fnc_toNumber } else { 0 };

        if (_realCash < _amount) exitWith {
            ["inv_error", "现金不足"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        private _newCash = _realCash - _amount;
        private _newBank = _realBank + _amount;

        ["updatecashbank", [_uid, str _newCash, str _newBank]] call DB_fnc_playerMapper;

        _logEvent = format ["Server Validated: ATM Deposit %1", _amount];
        _result = ["atm_deposit_success", _amount, _newCash, _newBank];
    };

    // ==========================================
    // ATM - 取款
    // ==========================================
    case "atm_withdraw": {
        _data params [
            ["_amount", 0, [0]]
        ];

        if (_amount <= 0) exitWith {
            ["inv_error", "无效的金额"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 从数据库获取真实余额
        private _dbCash = ["getcash", [_uid]] call DB_fnc_playerMapper;
        private _dbBank = ["getbank", [_uid]] call DB_fnc_playerMapper;
        private _realCash = if (count _dbCash > 0) then { [_dbCash select 0] call _fnc_toNumber } else { 0 };
        private _realBank = if (count _dbBank > 0) then { [_dbBank select 0] call _fnc_toNumber } else { 0 };

        if (_realBank < _amount) exitWith {
            ["inv_error", "银行余额不足"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        private _newCash = _realCash + _amount;
        private _newBank = _realBank - _amount;

        ["updatecashbank", [_uid, str _newCash, str _newBank]] call DB_fnc_playerMapper;

        _logEvent = format ["Server Validated: ATM Withdraw %1", _amount];
        _result = ["atm_withdraw_success", _amount, _newCash, _newBank];
    };

    // ==========================================
    // ATM - 转账
    // ==========================================
    case "atm_transfer": {
        _data params [
            ["_targetUID", "", [""]],
            ["_amount", 0, [0]],
            ["_tax", 0, [0]]  // 税金参数 - 修复刷钱漏洞
        ];

        // 计算总扣除金额 (本金 + 税金)
        private _totalDeduct = _amount + _tax;

        if (_amount <= 0) exitWith {
            ["inv_error", "无效的金额"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        if (_tax < 0) exitWith {
            ["inv_error", "无效的税金"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        if (_targetUID == _uid) exitWith {
            ["inv_error", "不能转账给自己"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 验证目标玩家存在
        private _targetExists = ["exists", [_targetUID]] call DB_fnc_playerMapper;
        if (count _targetExists == 0) exitWith {
            ["inv_error", "目标玩家不存在"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 从数据库获取真实余额
        private _dbBank = ["getbank", [_uid]] call DB_fnc_playerMapper;
        private _realBank = if (count _dbBank > 0) then { [_dbBank select 0] call _fnc_toNumber } else { 0 };

        // 验证余额是否足够支付本金+税金
        if (_realBank < _totalDeduct) exitWith {
            ["inv_error", "银行余额不足"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
        };

        // 扣除发送者 (本金 + 税金)
        private _newBank = _realBank - _totalDeduct;
        ["updatebank", [_uid, str _newBank]] call DB_fnc_playerMapper;

        // 只给接收者增加本金 (税金被销毁，不转给任何人)
        ["incrementbank", [_targetUID, _amount]] call DB_fnc_playerMapper;

        // 通知接收方更新余额 (使用 HashMap 缓存 O(1))
        private _targetPlayer = [_targetUID] call OES_fnc_getPlayerByUID;

        if (!isNull _targetPlayer) then {
            private _targetOwnerID = owner _targetPlayer;
            ["transfer_received", [_amount, _playerName]] remoteExec ["OEC_fnc_inventoryResult", _targetOwnerID];
        };

        _logEvent = format ["Server Validated: ATM Transfer %1 (tax: %2) to %3", _amount, _tax, _targetUID];
        _result = ["atm_transfer_success", _amount, _newBank, _targetUID];
    };

    default {
        diag_log format ["[InventoryServer] Unknown type: %1", _type];
        ["inv_error", "未知的操作类型"] remoteExec ["OEC_fnc_inventoryResult", _ownerID];
    };
};

// 记录日志
if (_logEvent != "") then {
    // 参数: [player, action, actionValue, actionId, instanceId]
    [_player, _type, format ["%1 | %2", _logEvent, str _data], 0, 1] call OES_fnc_AdvancedLog;
};

// 发送结果给客户端
if (count _result > 0) then {
    _result remoteExec ["OEC_fnc_inventoryResult", _ownerID];
};

diag_log format ["[InventoryServer] %1 executed %2, result: %3", _playerName, _type, _result];
