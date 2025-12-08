//	File: fn_redeemDepositBox.sqf
//	Author: Zahzi
//	Description: Redeem's player's deposit box balance to their bank balance
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_player",objNull,[objNull]]
];

// 使用 playerMapper 获取存款箱余额
private _queryResult = ["getdepositbox", [getPlayerUID _player]] call DB_fnc_playerMapper;

// this should never occur
if (count _queryResult != 1) exitWith {
  [false,0,"发生了一个错误."] remoteExec ["OEC_fnc_depositBoxRedeemed",remoteExecutedOwner,false];
};
private _amount = _queryResult select 0;
if (_amount == 0) exitWith {
  [false,0,"你的储蓄箱里没有钱可以兑换."] remoteExec ["OEC_fnc_depositBoxRedeemed",remoteExecutedOwner,false];
};

// 使用 playerMapper 重置存款箱余额
["resetdepositbox", [getPlayerUID _player]] call DB_fnc_playerMapper;

[true,_amount,"您已成功从您的存款箱中兑换$%1!"] remoteExec ["OEC_fnc_depositBoxRedeemed",remoteExecutedOwner,false];
