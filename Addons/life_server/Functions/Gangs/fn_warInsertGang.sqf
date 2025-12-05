//	File: fn_warInsertGang.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Inserts an accepted war into the DB

params [
	["_instigator",objNull,[objNull]],
	["_invGangID",0,[0]],
	["_invGangName","",[""]],
	["_acptGangID",0,[0]],
	["_acptGangName","",[""]],
	["_acceptor",objNull,[objNull]]
];

if (isNull _instigator || isNull _acceptor) exitWith {};
if (_invGangID isEqualTo 0 || _acptGangID isEqualTo 0) exitWith {};
if (_invGangID isEqualTo _acptGangID) exitWith {};
if (_acptGangName isEqualTo "" || _invGangName isEqualTo "") exitWith {};

private _check = (_invGangName find "'" != -1);
if (_check) exitWith {};
private _check = (_acptGangName find "'" != -1);
if (_check) exitWith {};

private _instigUID = getPlayerUID _instigator;
private _acptUID = getPlayerUID _acceptor;

private _query = format ["SELECT id FROM gangwars WHERE active='1' AND ((init_gangid='%1' AND acpt_gangid='%2') OR (acpt_gangid='%1' AND init_gangid='%2'))",_invGangID,_acptGangID];
private _queryResult = [_query,2] call OES_fnc_asyncCall;

if !(count _queryResult isEqualTo 0) exitWith {};

_query = format ["INSERT INTO gangwars (instigator,init_gangid,init_gangname,acceptor,acpt_gangid,acpt_gangname,active) VALUES ('%1','%2','%3','%4','%5','%6','1')",_instigUID,_invGangID,_invGangName,_acptUID,_acptGangID,_acptGangName];
[_query,1] call OES_fnc_asyncCall;