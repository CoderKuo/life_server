//	File: fn_buyLicenseServer.sqf
//	Author: Security Fix
//	Description: 服务端许可证购买验证 - 防止客户端金钱作弊
//  服务端从数据库查询实际余额，防止客户端伪造

params [
	["_player",objNull,[objNull]],
	["_type","",[""]],
	["_price",0,[0]]
];

if (isNull _player || _type isEqualTo "" || _price <= 0) exitWith {
	format ["-LICENSE- Invalid params: player=%1, type=%2, price=%3", _player, _type, _price] call OES_fnc_diagLog;
	false
};

private _ownerID = owner _player;
private _uid = getPlayerUID _player;

// 从数据库查询玩家实际余额
private _dbResult = ["exists", [_uid]] call DB_fnc_playerMapper;
if (count _dbResult < 2) exitWith {
	format ["-LICENSE- Player %1 not found in database", _uid] call OES_fnc_diagLog;
	false
};

// 查询现金和银行余额
private _fundsResult = [1, "player_get_funds", "SELECT cash, bankacc FROM players WHERE playerid='%1'", [_uid]] call DB_fnc_dbExecute;
if (count _fundsResult < 2) exitWith {
	format ["-LICENSE- Failed to get funds for player %1", _uid] call OES_fnc_diagLog;
	false
};

private _cash = _fundsResult select 0;
private _bank = _fundsResult select 1;

// 服务端重新计算价格，防止客户端伪造价格
private _serverPrice = switch (_type) do {
	case "driver": {250};
	case "boat": {500};
	case "pilot": {5000};
	case "gun": {2500};
	case "wpl": {5000};
	case "dive": {3000};
	case "oil": {1000};
	case "cair": {15000};
	case "swat": {3500};
	case "cg": {8000};
	case "mcg": {8000};
	case "heroin": {2500};
	case "marijuana": {1750};
	case "medmarijuana": {1500};
	case "gang": {0};
	case "rebel": {75000};
	case "truck": {20000};
	case "diamond": {35000};
	case "salt": {12000};
	case "cocaine": {30000};
	case "sand": {14500};
	case "iron": {9500};
	case "copper": {8000};
	case "cement": {6500};
	case "mair": {15000};
	case "home": {25000};
	case "frog": {24000};
	case "crystalmeth": {55000};
	case "methu": {30000};
	case "moonshine": {54000};
	case "mashu": {29000};
	case "platinum": {10000};
	case "silver": {9000};
	case "vigilante": {60000};  // 基础价格，叛军加倍在客户端处理
	case "mushroom": {35000};
	case "ccocaine": {40000};
	case "lumber": {15000};
	case "bananap": {25000};
	case "topaz": {30000};
	case "cocoap": {25000};
	case "bananaSplit": {35000};
	case "sugarp": {25000};
	default {-1};
};

// 检查价格是否被篡改（允许小幅度误差用于vigilante的叛军加倍）
if (_serverPrice isEqualTo -1) exitWith {
	format ["-LICENSE- Unknown license type: %1 from player %2", _type, name _player] call OES_fnc_diagLog;
	[[1,"未知的许可证类型!"],"OEC_fnc_broadcast",_ownerID,false] spawn OEC_fnc_MP;
	false
};

// 允许客户端价格在服务端价格的范围内（用于vigilante的特殊处理）
if (_price < _serverPrice || _price > (_serverPrice * 2.1)) exitWith {
	format ["-LICENSE- Price mismatch! Client: %1, Server: %2, Type: %3, Player: %4", _price, _serverPrice, _type, name _player] call OES_fnc_diagLog;
	[[profileName,format["许可证价格异常! 客户端: %1, 服务端: %2",_price,_serverPrice]],"OEC_fnc_notifyAdmins",-2,false] spawn OEC_fnc_MP;
	false
};

// 验证金钱 - 现金或银行任一足够即可
if (_cash < _price && _bank < _price) exitWith {
	format ["-LICENSE- Player %1 has insufficient funds for %2 license (cash=%3, bank=%4, price=%5)", name _player, _type, _cash, _bank, _price] call OES_fnc_diagLog;
	[[1,"您的资金不足!"],"OEC_fnc_broadcast",_ownerID,false] spawn OEC_fnc_MP;
	false
};

// 扣除金钱 - 优先使用现金，不足则使用银行
// 同时更新数据库和客户端变量
if (_cash >= _price) then {
	private _newCash = _cash - _price;
	// 更新数据库 - 使用安全数字函数
	private _newCashStr = ["format", _newCash] call OES_fnc_safeNumber;
	["updatecash", [_uid, _newCashStr]] call DB_fnc_playerMapper;
	// 同步到客户端
	["oev_cash", _newCash] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
	["oev_cache_cash", _newCash] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
	format ["-LICENSE- Deducted $%1 from cash. New balance: $%2", _price, _newCash] call OES_fnc_diagLog;
} else {
	private _newBank = _bank - _price;
	// 更新数据库 - 使用安全数字函数
	private _newBankStr = ["format", _newBank] call OES_fnc_safeNumber;
	["updatebank", [_uid, _newBankStr]] call DB_fnc_playerMapper;
	// 同步到客户端
	["oev_bankacc", _newBank] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
	["oev_cache_bankacc", _newBank] remoteExec ["OEC_fnc_netSetVar", _ownerID, false];
	format ["-LICENSE- Deducted $%1 from bank. New balance: $%2", _price, _newBank] call OES_fnc_diagLog;
};

// 通知客户端购买成功
[["life_license_bought",true],"OEC_fnc_netSetVar",_ownerID,false] spawn OEC_fnc_MP;

format ["-LICENSE- Player %1 (%2) bought %3 license for $%4", name _player, _uid, _type, _price] call OES_fnc_diagLog;
true
