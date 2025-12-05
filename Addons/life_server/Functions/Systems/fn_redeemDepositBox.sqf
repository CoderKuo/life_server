//	File: fn_redeemDepositBox.sqf
//	Author: Zahzi
//	Description: Redeem's player's deposit box balance to their bank balance

params [
	["_player",objNull,[objNull]]
];
private ["_queryResult","_query"];

_query = format["SELECT `deposit_box` FROM `players` WHERE `playerid`='%1'", getPlayerUID _player];
_queryResult = [_query,2] call OES_fnc_asyncCall;
// this should never occur
if (count _queryResult != 1) exitWith {
  [false,0,"发生了一个错误."] remoteExec ["OEC_fnc_depositBoxRedeemed",remoteExecutedOwner,false];
};
private _amount = _queryResult select 0;
if (_amount == 0) exitWith {
  [false,0,"你的储蓄箱里没有钱可以兑换."] remoteExec ["OEC_fnc_depositBoxRedeemed",remoteExecutedOwner,false];
};

_query = format["UPDATE `players` SET `deposit_box`=0 WHERE `playerid`='%1'", getPlayerUID _player];
_queryResult = [_query,1] call OES_fnc_asyncCall;

[true,_amount,"您已成功从您的存款箱中兑换$%1!"] remoteExec ["OEC_fnc_depositBoxRedeemed",remoteExecutedOwner,false];
