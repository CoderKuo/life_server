//	File: fn_queryRequest.sqf
//	Author: Bryan "Tonic" Boardwine

//	Description:
//	Handles the incoming request and sends an asynchronous query
//	request to the database.

//	Return:
//	ARRAY - If array has 0 elements it should be handled as an error in client-side files.
//	STRING - The request had invalid handles or an unknown error and is logged to the RPT.

private["_houseArr","_houseKeysArr","_gangArr","_uid","_side","_query","_return","_queryResult","_qResult","_handler","_thread","_tickTime","_loops","_returnCount","_warkills","_player"];
_uid = param [0,"",[""]];
_side = param [1,sideUnknown,[civilian]];
_ownerID = param [2,ObjNull,[ObjNull]];
_isDeadCiv = _this param [3,false,[false]];

if(isNull _ownerID) exitWith {};

if(getPlayerUID _ownerID != _uid) exitWith {//spoofed player id?
	if(getPlayerUID _ownerID != "") then {
		[[name _ownerID,getPlayerUID _ownerID,"-- HACKER PROBABLY -- Player UID provided does not match the server fetched version: Provided version:" + _uid],"OEC_fnc_cookieJar",false,false] spawn OEC_fnc_MP;
		[[name _ownerID,format["-- SpyGlass -- HACKER PROBABLY -- Player UID provided does not match the server fetched version: Provided: %1 -- Server: %2",_uid, (getPlayerUID _ownerID)]],"OEC_fnc_notifyAdmins",-2,false] spawn OEC_fnc_MP;
		// [2,_ownerID,[_uid]] spawn OES_fnc_handleDisc;
		format["-- SpyGlass -- HACKLOG -- Player UID provided does not match the server fetched version: Provided: %1 -- Server: %2",_uid, (getPlayerUID _ownerID)] call OES_fnc_diagLog;
	};
};

_player = _ownerID;
private _ownerObj = _ownerID;
_ownerID = owner _ownerID;

private["_cooldownQuery","_cooldownQueryResult","_cooldownRequired","_cooldown2Required","_sideString","_cooldownTimeOld","_cooldownTimeNow","_lastSeconds","_currentSeconds","_timeDiff"];
// PostgreSQL: 使用 last_active::timestamp 替代 TIMESTAMP(last_active)
_cooldownQuery = format["SELECT last_server, last_side, last_active::timestamp, NOW(), adminlevel, warkills, current_title, developer_level, hex_icon, hex_icon_redemptions, designer_level FROM players WHERE playerid='%1'",_uid];
_cooldownQueryResult = ["getsessioninfo", [_uid]] call DB_fnc_playerMapper;
_cooldownRequired = false;
_cooldown2Required = false;

_warkills = 0;
_title = "";
_hexIcon = "";
_hexRedemptions = 0;
_sideString = switch (_side) do {
	case civilian: {"civ"};
	case west: {"cop"};
	case independent: {"med"};
	default {"civ"};
};

if(count _cooldownQueryResult > 0) then {
	_warkills = _cooldownQueryResult select 5;
	_title = _cooldownQueryResult select 6;
	_hexIcon = _cooldownQueryResult select 8;
	_hexRedemptions = _cooldownQueryResult select 9;
	if !(playerSide isEqualTo west) then {
		_player setVariable["hexIconName",_hexIcon,true];
	} else {
		_player setVariable["hexIconName","",true];
	};
	[5,_hexRedemptions] remoteExec["OEC_fnc_hexIconMaster",_player];
	if((_cooldownQueryResult select 4) >= 2 || (_cooldownQueryResult select 7) >= 2 || (_cooldownQueryResult select 10) >= 3) exitWith {};//admins no need for cooldown

	// 5 minute Cooldown for joining different server
	if ((_cooldownQueryResult select 0) != olympus_server) then {
		_cooldownTimeOld = (_cooldownQueryResult select 2);
		_cooldownTimeNow = (_cooldownQueryResult select 3);

		if((_cooldownTimeOld select 0) == (_cooldownTimeNow select 0)) then {
			if((_cooldownTimeOld select 1) == (_cooldownTimeNow select 1)) then {
				if((_cooldownTimeOld select 2) == (_cooldownTimeNow select 2)) then {
					_lastSeconds = (((_cooldownTimeOld select 3) * 60) * 60) + ((_cooldownTimeOld select 4) * 60) + (_cooldownTimeOld select 5);
					_currentSeconds = (((_cooldownTimeNow select 3) * 60) * 60) + ((_cooldownTimeNow select 4) * 60) + (_cooldownTimeNow select 5);

					_timeDiff = _currentSeconds - _lastSeconds;

					if(_timeDiff < 300) then {
						_cooldownRequired = true;
					};
				};
			};
		};
	} else {
		// 15 minute Cooldown for joining same server but different side
		if (((_cooldownQueryResult select 0) == olympus_server) && ((_cooldownQueryResult select 1) != _sideString)) then {
			_cooldownTimeOld = (_cooldownQueryResult select 2);
			_cooldownTimeNow = (_cooldownQueryResult select 3);

			if((_cooldownTimeOld select 0) == (_cooldownTimeNow select 0)) then {
				if((_cooldownTimeOld select 1) == (_cooldownTimeNow select 1)) then {
					if((_cooldownTimeOld select 2) == (_cooldownTimeNow select 2)) then {
						_lastSeconds = (((_cooldownTimeOld select 3) * 60) * 60) + ((_cooldownTimeOld select 4) * 60) + (_cooldownTimeOld select 5);
						_currentSeconds = (((_cooldownTimeNow select 3) * 60) * 60) + ((_cooldownTimeNow select 4) * 60) + (_cooldownTimeNow select 5);

						_timeDiff = _currentSeconds - _lastSeconds;

						if(_timeDiff < 900) then {
							_cooldown2Required = true;
						};
					};
				};
			};
		};
	};
};

if(_cooldownRequired) exitWith {
	[["cooldown", _timeDiff, (_cooldownQueryResult select 0),_cooldownTimeNow],"OEC_fnc_requestReceived",_ownerID,false] spawn OEC_fnc_MP;
};
if(_cooldown2Required) exitWith {
	[["cooldown2", _timeDiff, (_cooldownQueryResult select 0),_cooldownTimeNow],"OEC_fnc_requestReceived",_ownerID,false] spawn OEC_fnc_MP;
};

["updatelastserver", [_uid, str olympus_server, _sideString]] call DB_fnc_playerMapper;

if (_side isEqualTo west) then {
	_gangData = _uid spawn OES_fnc_queryPlayerGang;
	waitUntil {scriptDone _gangData};
	_gangArr = missionNamespace getVariable [format ["gang_%1",_uid],[]];
	missionNamespace setVariable [format ["gang_%1", _uid], nil];
};

if(_side isEqualTo civilian) then {
	_gangData = _uid spawn OES_fnc_queryPlayerGang;
	waitUntil{scriptDone _gangData};
	_gangArr = missionNamespace getVariable[format["gang_%1",_uid],[]];
	if ((count _gangArr) isEqualTo 4) then {
		// 使用 gangMapper 统计帮派成员数量
		private _countResultArr = ["countmembers", [str (_gangArr select 0), (_gangArr select 1)]] call DB_fnc_gangMapper;
		private _countResult = if (!isNil "_countResultArr" && {count _countResultArr > 0}) then { _countResultArr select 0 } else { 0 };
		if (_countResult < 8) then {
			[[1],"OEC_fnc_gangNotifyMember",_ownerID,false] spawn OEC_fnc_MP;
			//[(_gangArr select 0),(_gangArr select 1)] spawn OES_fnc_lockGangBldg;
		};
	};
	_houseData = _uid spawn OES_fnc_fetchPlayerHouses;
	waitUntil {scriptDone _houseData};
	_houseKeyData = _uid spawn OES_fnc_fetchPlayerHouseKeys;
	waitUntil {scriptDone _houseKeyData};
	_houseArr = missionNamespace getVariable[format["houses_%1",_uid],[]];
	_houseKeysArr = missionNamespace getVariable[format["house_keys_%1",_uid],[]];
};
_keyArr = missionNamespace getVariable [format["%1_KEYS_%2",_uid,_side],[]];

/*
	_returnCount is the count of entries we are expecting back from the async call.
	The other part is well the SQL statement.
*/
/*
_query = switch(_side) do {
	case west: {_returnCount = 14; format["SELECT playerid, name, cash, bankacc, adminlevel, newdonor, cop_licenses, coplevel, %2, aliases, player_stats, wanted, blacklist, supportteam FROM players WHERE playerid='%1'",_uid,dbColumnGearCop];};
	case civilian: {_returnCount = 15; format["SELECT playerid, name, cash, bankacc, adminlevel, newdonor, civ_licenses, arrested, %2, aliases, player_stats, wanted, %3, supportteam, vigiarrests FROM players WHERE playerid='%1'",_uid,dbColumnGearCiv,dbColumnPosition];};
	case independent: {_returnCount = 13; format["SELECT playerid, name, cash, bankacc, adminlevel, newdonor, med_licenses, mediclevel, %2, aliases, player_stats, wanted, newslevel, supportteam FROM players WHERE playerid='%1'",_uid,dbColumnGearMed];};
};
*/
//												0					1				2				3					4							5									6										7										8											9						10					11						12			13					14							15				16					17						18							19				20		    21
private _queryIndex = ["playerid", "name", "cash", "bankacc", "adminlevel", "designer_level", "developer_level", "civcouncil_level", "restrictions_level", "newdonor", "licenses", "rankarrest", "gear", "aliases", "player_stats", "wanted", "blposnews", "supportteam", "vigiarrests", "vigiarrests_stored", "deposit_box", "gangarr", "housearr","housekeysarr", "vehkeys"];
// PostgreSQL: 使用 playerid::text 确保 playerid 作为字符串返回，避免科学计数法
private _startStr = "SELECT playerid::text, name, cash, bankacc, adminlevel, designer_level, developer_level, civcouncil_level, restrictions_level, newdonor, %2, %3, %4, aliases, player_stats, wanted, %5, supportteam, vigiarrests, vigiarrests_stored, deposit_box FROM players WHERE playerid='%1'";
_query = switch (_side) do {
	case west: {format [_startStr, _uid, "cop_licenses", "coplevel", dbColumnGearCop, "blacklist"]};
	case independent: {format [_startStr, _uid, "med_licenses", "mediclevel", dbColumnGearMed, "newslevel"]};
	case civilian: {format [_startStr, _uid, "civ_licenses", "arrested", dbColumnGearCiv, dbColumnPosition]};
};
/*
_query = switch (_side) do {
	case west: {_returnCount = 17; format["SELECT playerid, name, cash, bankacc, adminlevel, designer_level, developer_level, restrictions_level, newdonor, cop_licenses, coplevel, %2, aliases, player_stats, wanted, blacklist, supportteam FROM players WHERE playerid='%1'",_uid,dbColumnGearCop];};
	case civilian: {_returnCount = 18; format["SELECT playerid, name, cash, bankacc, adminlevel, designer_level, developer_level, restrictions_level, newdonor, civ_licenses, arrested, %2, aliases, player_stats, wanted, %3, supportteam, vigiarrests FROM players WHERE playerid='%1'",_uid,dbColumnGearCiv,dbColumnPosition];};
	case independent: {_returnCount = 16; format["SELECT playerid, name, cash, bankacc, adminlevel, designer_level, developer_level, restrictions_level, newdonor, med_licenses, mediclevel, %2, aliases, player_stats, wanted, newslevel, supportteam FROM players WHERE playerid='%1'",_uid,dbColumnGearMed];};
};
*/

// 使用 Mapper 层获取数据，定义变量
private _sideStr = switch (_side) do {
	case west: { "cop" };
	case independent: { "med" };
	default { "civ" };
};
private _gearCol = switch (_side) do {
	case west: { dbColumnGearCop };
	case independent: { dbColumnGearMed };
	default { dbColumnGearCiv };
};
private _posCol = switch (_side) do {
	case west: { "blacklist" };
	case independent: { "newslevel" };
	default { dbColumnPosition };
};
_tickTime = diag_tickTime;
_queryResult = ["getfulldata", [_uid, _sideStr, _gearCol, _posCol]] call DB_fnc_playerMapper;

if(_queryResult isEqualType "") exitWith {
	[[],"OEC_fnc_insertPlayerInfo",_ownerID,false,true] spawn OEC_fnc_MP;
};

if(count _queryResult == 0) exitWith {
	[[],"OEC_fnc_insertPlayerInfo",_ownerID,false,true] spawn OEC_fnc_MP;
};

//Blah conversion thing from a2net->extdb
private["_tmp"];
_tmp = _queryResult select (_queryIndex find "cash");
_queryResult set [(_queryIndex find "cash"), [_tmp] call OES_fnc_numberToString];
_tmp = _queryResult select (_queryIndex find "bankacc");
_queryResult set [(_queryIndex find "bankacc"), [_tmp] call OES_fnc_numberToString];
// Donor Shit
_tmp = _queryResult select (_queryIndex find "newdonor");
_queryResult set [(_queryIndex find "newdonor"), [_tmp] call OES_fnc_numberToString];

//Parse licenses - 从 JSONB 返回 SQF 格式字符串
private _licensesData = _queryResult select (_queryIndex find "licenses");
private _new = [_licensesData, []] call DB_fnc_parseJsonb;
_queryResult set [(_queryIndex find "licenses"), _new];

//Convert tinyint to boolean
_old = _queryResult select (_queryIndex find "licenses");
for "_i" from 0 to (count _old)-1 do {
	_data = _old select _i;
	_old set[_i,[_data select 0, ([_data select 1,1] call OES_fnc_bool)]];
};

_queryResult set [(_queryIndex find "licenses"), _old];

// Gear 解析 - 从 JSONB 返回 SQF 格式字符串
private _gearData = _queryResult select (_queryIndex find "gear");
_new = [_gearData, []] call DB_fnc_parseJsonb;
_queryResult set [(_queryIndex find "gear"), _new];

// Aliases 解析 - 从 JSONB 返回 SQF 格式字符串
private _aliasesData = _queryResult select (_queryIndex find "aliases");
_new = [_aliasesData, []] call DB_fnc_parseJsonb;
_queryResult set [(_queryIndex find "aliases"), _new];

// Player stats 解析 - 从 JSONB 返回 SQF 格式字符串
private _statsData = _queryResult select (_queryIndex find "player_stats");
if (!isNil "_statsData" && {_statsData isEqualType ""} && {(count toArray(_statsData)) <= 15}) then {
	_statsData = "[0,0,0,0,0,0,0,0,0,0]";
};
_new = [_statsData, [0,0,0,0,0,0,0,0,0,0]] call DB_fnc_parseJsonb;
_queryResult set [(_queryIndex find "player_stats"), _new];

// Wanted 解析 - 从 JSONB 返回 SQF 格式字符串
private _wantedData = _queryResult select (_queryIndex find "wanted");
_new = [_wantedData, []] call DB_fnc_parseJsonb;
_queryResult set [(_queryIndex find "wanted"), _new];

//Parse data for specific side.
switch (_side) do {
	case west: {
		_queryResult set [(_queryIndex find "blposnews"), ([_queryResult select (_queryIndex find "blposnews"),1] call OES_fnc_bool)];
		_queryResult pushBack _gangArr;
	};

	case civilian: {
		// rankarrest 解析 - 从 JSONB 返回 SQF 格式字符串
		private _rankarrestData = _queryResult select (_queryIndex find "rankarrest");
		_new = [_rankarrestData, [0, 0, 0]] call DB_fnc_parseJsonb;
		_queryResult set [(_queryIndex find "rankarrest"), _new];

		// blposnews (position) 解析 - 从 JSONB 返回 SQF 格式字符串
		private _blposnewsData = _queryResult select (_queryIndex find "blposnews");
		_new = [_blposnewsData, []] call DB_fnc_parseJsonb;
		_queryResult set [(_queryIndex find "blposnews"), _new];

		if(_isDeadCiv) then {
			_queryResult set [(_queryIndex find "cash"),"0"];//wipe cash on hand
			_queryResult set [(_queryIndex find "gear"),[]];
			_queryResult set [(_queryIndex find "blposnews"),[]];
		};

		_queryResult pushBack _gangArr;
		_queryResult pushBack _houseArr;
		_queryResult pushBack _houseKeysArr;
	};
};
private _statsArray = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
//Stats
// 0 - Civilian kills, 1 - Cop kills, 2 - Epipens used, 3 - Lockpicked vehicles, 4 - Players robbed, 5 - Prison time spent, 6 - Suicide vests used, 7 - Armed plane kills, 8 - Drugs sold, 9 - Bombs planted, 10 - AA Hacked, 11 - Cop lethals, 12 - Pardons issued, 13 - Cop arrests, 14 - Tickets issued that were paid, 15 - Bombs defused, 16 - Donuts eaten, 17 - Drugs seized (currency), 18 - Warkills, 19 - Vigilante arrests, 20 - Gokart time (time trial), 21 - Toolkits used on medic, 22 - AA Repairs, 23 - Medic Impounds (not windows key), 24 - titan hits, 25 - Hit_claimed, 26 - Hit_placed, 27 - bets_won, 28 - bets_lost, 29 - bets_won_value, 30 - bets_lost_value
private _statsQuery = format["SELECT civ_kills, cop_kills, epipen, lockpick_suc, robberies, prison_time, sui_vest, plane_kills, (marijuana + heroinp + cocainep + crystalmeth + mmushroom + frogp + moonshine), (blastfed + blastjail + blastbw + blastbank), AA_hacked, cop_lethals, pardons, cop_arrests, tickets_issued_paid, defuses, donuts, drugs_seized_currency, vigiarrests, gokart_time, med_toolkits, AA_repaired, med_impounds, titan_hits, hits_claimed, hits_placed, bets_won, bets_lost, bets_won_value, bets_lost_value, vehicles_chopped, cops_robbed, jail_escapes, money_spent, events_won, kills_1km, conq_kills, conq_deaths, conq_captures, casino_winnings, casino_losses, casino_uses, lethal_injections FROM stats WHERE playerid='%1'",_uid];
private _statsReturn = ["getstats", [_uid]] call DB_fnc_playerMapper;

if !(count _statsReturn isEqualTo 0) then {
	private _index = 0;
	{
		switch(true) do {
			case (_forEachIndex isEqualTo 18): {_statsArray set [_forEachIndex,_warkills];};
			default {_statsArray set [_forEachIndex,_statsReturn select _index];_index = _index + 1;};
		};
	} forEach _statsArray;
};

"------------- Client Query Request -------------" call OES_fnc_diagLog;
format["QUERY: %1", _query] call OES_fnc_diagLog;
format["Time to complete: %1 (in seconds)", (diag_tickTime - _tickTime)] call OES_fnc_diagLog;
format["Player Query Result: %1", _queryResult] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

_queryResult set [(_queryIndex find "vehkeys"), _keyArr];

if (isNull _ownerObj || remoteExecutedOwner isEqualTo 0) exitWith {};

[_queryResult,"OEC_fnc_requestReceived",remoteExecutedOwner,false] spawn OEC_fnc_MP;
["oev_statsTable",_statsArray] remoteExecCall ["OEC_fnc_netSetVar",remoteExecutedOwner];

//Faction specific title checks
if ((_side isEqualTo civilian || _side isEqualTo independent) && _title in ["Deputy","Patrol Officer","Corporal","Sergeant","Lieutenant","Deputy Chief of Police","Chief of Police"]) then {
	["oev_currentTitle",""] remoteExecCall ["OEC_fnc_netSetVar",remoteExecutedOwner];
	_ownerObj setVariable ["currentTitle","",true];
} else {
	["oev_currentTitle",_title] remoteExecCall ["OEC_fnc_netSetVar",remoteExecutedOwner];
	_ownerObj setVariable ["currentTitle",_title,true];
};

//Server best title checks
private _serverBest = missionConfigFile >> "CfgTitleServerBest";
for "_i" from 0 to ((count(missionConfigFile >> "CfgTitleServerBest")) - 1) do {
	if ((_title isEqualTo (getText((_serverBest select _i) >> "title"))) && ((getPlayerUID player) in oev_title_pid)) then {
		["oev_currentTitle",""] remoteExecCall ["OEC_fnc_netSetVar",remoteExecutedOwner];
		_ownerObj setVariable ["currentTitle","",true];
	};
};
