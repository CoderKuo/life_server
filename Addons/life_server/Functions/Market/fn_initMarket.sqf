// File: fn_initMarket.sqf
// Author: Jesse "tkcjesse" Schultz

// DB Array: [0,32,48,94,94,290,320,928,620,0,1229,1725,1164,1349,1280,1313,1441,2268,1630,0,1976,1837,2581,2115,2255,7980,8406,8820,55250] <- Contains dividers
// serv_market_current: [current price, price adjustments] <- change amount adjusts as sales occur, set to zero on reset enabled (dynamic)
// serv_market_varNames = ["foodDiv","apple","peach","salema","ornate","mackerel","mullet","catshark","tuna","legalDiv","saltr","cement","glass","ironr","copperr","silverr","platinumr","oilp","diamondc","illegalDiv","marijuana","frogp","mmushroom","heroinp","cocainep","turtle","moonshine","crystalmeth","moneybag","goldbar"] <- Variable Names that match up with the market_current and market_start. If adding/removing stuff make sure to adjust in client side configuration file. They must match! (Files: core\configuration and this file.. - )
// serv_market_storage: [variableName, current price] <- current price change as things are sold
// serv_market_config: [variable name, lowest possible, highest possible, legality, decrease percent, increase percent]

private _query = format ["SELECT market_array FROM market WHERE id='%1'",olympus_market];
private _queryResult = [_query,2,true] call OES_fnc_asyncCall;
private _priceArr = call compile format ["%1",((_queryResult select 0) select 0)];

_query = format ["SELECT reset FROM market WHERE id='%1'",olympus_market];
_queryResult = [_query,2] call OES_fnc_asyncCall;
private _reset = if ((_queryResult select 0) isEqualTo 1) then {true} else {false};

"------------- Market Query Request -------------" call OES_fnc_diagLog;
format ["Query: %1",_query] call OES_fnc_diagLog;
format ["Market Query Result: %1",_priceArr] call OES_fnc_diagLog;
format ["Market Reset Requested: %1",_reset] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

serv_market_current = [];
serv_market_storage = [];
serv_market_db = [];

/*
 * Item name 	=> The name of the item in-game. This is relative to core/config/fn_iconConfig.sqf items
 * Lowest		=> The lowest price the item can ever get to
 * Highest		=> The highest price the item can ever get to
 * Illegal		=> Whether the item is illegal or not, only takes effect if serv_market_changeAll = true
 * Decrease %	=> The % the items price drops by for every 1 of that item sold.
 * Increase %	=> The % this item increases when other items are sold.
 *
 * n = amount of that item sold / p = current price / i = % decrease / d = % decrease
 *
 * Price decrease when item is sold				price = p - (p * d * n)
 * Price increase when other items are sold		price = p + (p * i * n)
 *
 * Ultimately, what this allows is for us to set the decrease to 0 and the item price will never change,
 * as well as allow legal/illegal sales to influence eachother. (off when serv_market_changeAll = false).
 *
 * ALSO... The price will never drop below the lowest, if the calculation for the above maths is lower
 * than the lowest price for that item, the price will just be set to the lowest. Same when rising, if
 * the price goes above the highest, it'll just set it to the highest.
 *
 * Just because I know you secretly love my decently formatted comments, heres my last note:
 * If you would like to adjust the prices in the economy below, you MUST edit them here
 * then go into the admin menu and press "Reset Market" which will repopulate it with these values.
 * Those new values will then be sent to all of the clients.
 */
if !(olympus_server isEqualTo 4) then {
	serv_market_varNames = ["foodDiv","apple","peach","salema","ornate","mackerel","mullet","catshark","tuna","legalDiv","saltr","cement","glass","ironr","copperr","silverr","platinumr","oilp","diamondc","illegalDiv","marijuana","frogp","mmushroom","heroinp","cocainep","turtle","moonshine","crystalmeth","moneybag","goldbar"];
	serv_market_config = [
	  //ItemName      Lowest      Highest    	Flag  Decrease  Increase
		["foodDiv", 		0,					0,					-1,		0,				0],
		["apple", 			88,         160,        0,		0.003,		0.001],
		["peach", 			128,        248,        0,		0.003,		0.001],
		["salema", 			96,         183,        0,		0.003,		0.001],
		["ornate", 			96,         183,        0,		0.003,		0.001],
		["mackerel", 		303,        564,        0,		0.003,		0.001],
		["mullet", 			336,        624,        0,		0.003,		0.001],
		["catshark", 		972,        1809,       0,		0.003,		0.001],
		["tuna", 				651,        1209,       0,		0.002,		0.001],
		["legalDiv", 		0,					0,					-1,		0,				0],
		["saltr", 			860,        1915,       1,		0.003,		0.001],
		["cement", 			1206,       2690,       1,		0.003,		0.001],
		["glass", 			896,        1993,       1,		0.003,		0.001],
		["ironr", 			944,        1752,       1,		0.003,		0.001],
		["copperr", 		896,        1996,       1,		0.003,		0.001],
		["silverr", 		918,        2047,       1,		0.003,		0.001],
		["platinumr", 	1008,       1872,       1,		0.003,		0.001],
		["oilp", 				1586,       2948,       1,		0.003,		0.001],
		["diamondc", 		1140,       2118,       1,		0.0008,		0.0012],
		["illegalDiv",	0,					0,					-1,		0,				0],
		["marijuana", 	1382,       2568,       2,		0.0015,		0.001],
		["frogp", 			1984,       3388,       2,		0.0015,		0.001],
		["mmushroom",		1806,       3354,       2,		0.0019,		0.001],
		["heroinp",			1680,       3048,       2,		0.0015,		0.001],
		["cocainep",		1778,       3230,       2,		0.0008,		0.001],
		["turtle", 			5586,       10374,      2,		0.0006,		0.0012],
		["moonshine", 	5884,       10926,      2,		0.0006,		0.0004],
		["crystalmeth",	6174,       12466,      2,		0.0008,		0.0006],
		["moneybag", 		30000,      30000,      2,		0,				0],
		["goldbar",			69063,      69063,      3,		0,				0]
	];
} else {
	serv_market_varNames = ["foodDiv","apple","peach","salema","ornate","mackerel","mullet","catshark","tuna","legalDiv","cement","oilp","diamondc","illegalDiv","marijuana","mmushroom","cocainep","turtle","moonshine","goldbar"];
	serv_market_config = [
	    //ItemName      Lowest      Highest    Flag     Decrease    Increase
		["foodDiv", 	0,			0,			-1,		0,			0],
		["apple", 		22,         40,         0,		0.003,		0.001],
		["peach", 		32,         62,         0,		0.003,		0.001],
		["salema", 		64,         122,        0,		0.003,		0.001],
		["ornate", 		64,         122,        0,		0.003,		0.001],
		["mackerel", 	202,        376,        0,		0.003,		0.001],
		["mullet", 		224,        416,        0,		0.003,		0.001],
		["catshark", 	648,        1206,       0,		0.003,		0.001],
		["tuna", 		434,        806,        0,		0.002,		0.001],
		["legalDiv", 	0,			0,			-1,		0,			0],
		["cement", 		1206,       2242,       1,		0.003,		0.001],
		["oilp", 		3486,       4848,       1,		0.003,		0.001],
		["diamondc", 	2140,       3118,       1,		0.0008,		0.0012],
		["illegalDiv", 	0,			0,			-1,		0,			0],
		["marijuana", 	1382,       2568,       2,		0.0015,		0.001],
		["mmushroom",	1806,       3354,       2,		0.0019,		0.001],
		["cocainep",	2578,       4330,       2,		0.0008,		0.001],
		["turtle", 		8586,       12734,      2,		0.0006,		0.0012],
		["moonshine", 	5884,       10926,      2,		0.0006,		0.0004],
		["goldbar",		69063,      69063,      3,		0,			0]
	];
};


if (_reset) then {
	if !(olympus_server isEqualTo 4) then {
		_priceArr = [0,124,188,141,141,435,480,1392,930,0,1229,1725,1280,1349,1280,1313,1441,2268,1630,0,1976,1837,2581,2115,2255,7980,8406,8820,30000,69063];
	} else {
		_priceArr = [0,32,48,94,94,290,320,928,620,0,1725,3650,2500,0,1976,3500,3000,9850,8406,69063];
	};
};

{
	serv_market_storage pushBack [(serv_market_varNames select _forEachIndex),_x];
	serv_market_db pushBack _x;
	serv_market_current pushBack [_x,0];
} forEach _priceArr;

serv_market_start = _priceArr;
publicVariable "serv_market_start";
publicVariable "serv_market_current";
publicVariable "serv_market_config";

if (_reset) then {
	_priceArr = [_priceArr] call OES_fnc_mresArray;
	_query = format["UPDATE market SET reset='0', market_array='%1' WHERE id='%2'",_priceArr,olympus_market];
	[_query,1] call OES_fnc_asyncCall;
};