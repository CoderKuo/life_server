//	File: fn_rentPay.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Pays the rent for a gang building

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
private _query = format["SELECT bank FROM gangs WHERE id='%1'",_gangId];
private _queryResult = (([_query,2] call OES_fnc_asyncCall) select 0);

if (_queryResult < _payAmount) exitWith {
	[1,"Payment failed! Your gang doesn't have the required gang funds to make the payment!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
};

private _bldgPayment = _building getVariable ["bldg_payment",[0]];
if (_payStatus < 2) then {
    _building setVariable ["bldg_payment",[(_bldgPayment select 0) + 31, _payStatus + 1],true];
		[2,_gangId,_player,-(_payAmount)] call OES_fnc_gangBank;
    _query = format ["UPDATE gangbldgs SET lastpayment=NOW(), paystatus=paystatus+1 WHERE gang_id='%1' AND gang_name='%2' AND server='%3' AND owned='1' AND paystatus<2",_gangId,_gangName,olympus_server];
};
//_building setVariable ["bldg_payment",[31,1],true];

//_query = format ["UPDATE gangbldgs SET lastpayment=NOW(), paystatus='1' WHERE gang_id='%1' AND gang_name='%2' AND server='%3' AND owned='1'",_gangId,_gangName,olympus_server];
_queryResult = [_query,1] call OES_fnc_asyncCall;

private _logHistory = format ["INSERT INTO gangbankhistory (name,playerid,type,amount,gangid) VALUES('%1','%2','6','%3','%4')",name _player,getPlayerUID _player,_payAmount,_gangId];
[_logHistory,1] call OES_fnc_asyncCall;

[1,"Rent payment succeeded!"] remoteExec ["OEC_fnc_broadcast",(owner _player),false];
