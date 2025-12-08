//	File: fn_rentPay.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Pays the rent for a gang building
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_player",objNull,[objNull]],
	["_building",objNull,[objNull]],
	["_classname","",[""]],
	["_payStatus",-1,[0]],
	["_payAmount",-1,[0]],
	["_gangId",-1,[0]],
	["_gangName","",[""]]
];
if (isNull _player || isNull _building) exitWith {};
if (_classname isEqualTo "" || _gangName isEqualTo "") exitWith {};
if (_payAmount isEqualTo -1 || _payStatus isEqualTo -1 || _gangId isEqualTo -1) exitWith {};

private _check = (_gangName find "'" != -1);
if (_check) exitWith {};
private _check = (_classname find "'" != -1);
if (_check) exitWith {};

private _uid = getPlayerUID _player;

// 使用 Mapper 获取帮派银行余额
private _queryResult = (["getgangbank", [str _gangId]] call DB_fnc_gangMapper) select 0;

if (_queryResult < _payAmount) exitWith {
	[1,"Payment failed! Your gang doesnt have the required gang funds to make the payment!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
};

private _bldgPayment = _building getVariable ["bldg_payment",[0]];
if (_payStatus < 2) then {
    _building setVariable ["bldg_payment",[(_bldgPayment select 0) + 31, _payStatus + 1],true];
	[2,_gangId,_player,-(_payAmount)] call OES_fnc_gangBank;
    // 使用 Mapper 更新支付状态
    ["updatebuildingpayment", [str _gangId, _gangName, str olympus_server]] call DB_fnc_gangMapper;
};

// 记录历史
["addbankhistory", [name _player, getPlayerUID _player, "6", str _payAmount, str _gangId]] call DB_fnc_gangMapper;

[1,"Rent payment succeeded!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
