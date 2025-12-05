//	File: fn_insertRequest.sqf
//	Author: Bryan "Tonic" Boardwine

//	Description:
//	Does something with inserting... Don't have time for
//	descriptions... Need to write it...

private["_uid","_name","_side","_money","_bank","_licenses","_handler","_thread","_queryResult","_query","_alias","_ownerID"];
_uid = param [0,"",[""]];
_name = param [1,"",[""]];
_money = param [2,0,[0]];
_bank = param [3,25000,[0]];
_returnToSender = param [4,ObjNull,[ObjNull]];

//Error checks
if((_uid == "") || (_name == "")) exitWith {systemChat "Bad UID or name";}; //Let the client be 'lost' in 'transaction'
if(isNull _returnToSender) exitWith {systemChat "ReturnToSender is Null!";}; //No one to send this to!

if(getPlayerUID _returnToSender != _uid) exitWith {//spoofed player id?
	if(getPlayerUID _returnToSender != "") then {
		[[name _returnToSender,getPlayerUID _returnToSender,"-- HACK MAYBE -- Player UID provided does not match the server fetched version: Provided version:" + _uid],"OEC_fnc_cookieJar",false,false] spawn OEC_fnc_MP;
		[[name _returnToSender,format["-- HACK MAYBE -- Player UID provided does not match the server fetched version: Provided: %1 -- Server: %2",_uid, (getPlayerUID _returnToSender)]],"OEC_fnc_notifyAdmins",-2,false] spawn OEC_fnc_MP;
		// [2,_returnToSender,[_uid]] spawn OES_fnc_handleDisc;
		format["-- SpyGlass -- HACKLOG -- Player UID provided does not match the server fetched version: Provided: %1 -- Server: %2",_uid, (getPlayerUID _returnToSender)] call OES_fnc_diagLog;
	};
};

_ownerID = owner _returnToSender;

_query = format["SELECT playerid, name FROM players WHERE playerid='%1'",_uid];

_tickTime = diag_tickTime;
_queryResult = [_query,2] call OES_fnc_asyncCall;

"------------- Insert Query Request -------------" call OES_fnc_diagLog;
format["QUERY: %1",_query] call OES_fnc_diagLog;
format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)] call OES_fnc_diagLog;
format["Insert Query Result: %1",_queryResult] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

//Double check to make sure the client isn't in the database...
if(_queryResult isEqualType "") exitWith {[[],"OEC_fnc_dataQuery",(owner _returnToSender),false] spawn OEC_fnc_MP;}; //There was an entry!
if(count _queryResult != 0) exitWith {[[],"OEC_fnc_dataQuery",(owner _returnToSender),false] spawn OEC_fnc_MP;};

//Clense and prepare some information.
_name = [_name] call OES_fnc_mresString; //Clense the name of bad chars.
_name = _name splitString " " joinString " "; //Remove any extra white space from mresString, one space is fine
_alias = [[_name]] call OES_fnc_mresArray;
_money = [_money] call OES_fnc_numberSafe;
_bank = [_bank] call OES_fnc_numberSafe;

//Prepare the query statement..
_query = format["INSERT INTO players (playerid, name, cash, bankacc, aliases, cop_licenses, med_licenses, civ_licenses, civ_gear, cop_gear, med_gear, coordinates, civ_gear_tanoa, cop_gear_tanoa, med_gear_tanoa, coordinates_tanoa, player_stats, wanted, arrested) VALUES('%1', '%2', '%3', '%4', '%5','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[]""','""[0,0,0,0,0,0,0,0,0,0]""','""[]""','""[0,0,0]""')",
	_uid,
	_name,
	_money,
	_bank,
	_alias
];

[_query,1] call OES_fnc_asyncCall;
[[],"OEC_fnc_dataQuery",(owner _returnToSender),false] spawn OEC_fnc_MP;
