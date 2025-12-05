//	File: fn_insertRequest.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description:
//	Does something with inserting... Don't have time for
//	descriptions... Need to write it...

private ["_queryResult","_query","_alias","_ownerID"];
params [
	["_uid", "", [""]],
	["_name", "", [""]],
	["_money", 0, [0]],
	["_bank", 25000, [0]],
	["_returnToSender", objNull, [objNull]]
];

//Error checks
if((_uid == "") || (_name == "")) exitWith {systemChat "Bad UID or name";}; //Let the client be 'lost' in 'transaction'
if(isNull _returnToSender) exitWith {systemChat "ReturnToSender is Null!";}; //No one to send this to!

if(getPlayerUID _returnToSender != _uid) exitWith {//spoofed player id?
	if(getPlayerUID _returnToSender != "") then {
		[name _returnToSender,getPlayerUID _returnToSender,"-- HACK MAYBE -- Player UID provided does not match the server fetched version: Provided version:" + _uid] spawn OEC_fnc_cookieJar;
		[name _returnToSender,format["-- HACK MAYBE -- Player UID provided does not match the server fetched version: Provided: %1 -- Server: %2",_uid, (getPlayerUID _returnToSender)]] remoteExec ["OEC_fnc_notifyAdmins", -2];
		[2,_returnToSender,[_uid]] spawn HC_fnc_handleDisc;
		format["-- SpyGlass -- HACKLOG -- Player UID provided does not match the server fetched version: Provided: %1 -- Server: %2",_uid, (getPlayerUID _returnToSender)] call HC_fnc_diagLog;
	};
};

_ownerID = owner _returnToSender;

_query = format["SELECT playerid, name FROM players WHERE playerid='%1'",_uid];

_tickTime = diag_tickTime;
_queryResult = [_query,2] call HC_fnc_asyncCall;

"------------- Insert Query Request -------------" call HC_fnc_diagLog;
format["QUERY: %1",_query] call HC_fnc_diagLog;
format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)] call HC_fnc_diagLog;
format["Insert Query Result: %1",_queryResult] call HC_fnc_diagLog;
"------------------------------------------------" call HC_fnc_diagLog;

//Double check to make sure the client isn't in the database...
if(_queryResult isEqualType "") exitWith {[] remoteExec ["OEC_fnc_dataQuery", (owner _returnToSender)];};
if(count _queryResult != 0) exitWith {[] remoteExec ["OEC_fnc_dataQuery", (owner _returnToSender)];};

//Clense and prepare some information.
_name = [_name] call HC_fnc_mresString; //Clense the name of bad chars.
_alias = [[_name]] call HC_fnc_mresArray;
_money = [_money] call HC_fnc_numberSafe;
_bank = [_bank] call HC_fnc_numberSafe;

//Prepare the query statement..
_query = format["INSERT INTO players (playerid, name, cash, bankacc, aliases, cop_licenses, med_licenses, civ_licenses, civ_gear, cop_gear, med_gear, coordinates, civ_gear_tanoa, cop_gear_tanoa, med_gear_tanoa, coordinates_tanoa, player_stats, wanted, arrested) VALUES('%1', '%2', '%3', '%4', '%5','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[0,0,0,0,0,0,0,0,0,0]""','""[]""','""[0,0,0]""')",
	_uid,
	_name,
	_money,
	_bank,
	_alias
];

[_query,1] call HC_fnc_asyncCall;
[] remoteExec ["OEC_fnc_dataQuery", (owner _returnToSender)];
