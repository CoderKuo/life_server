//	File: fn_initMarket.sqf
//	Author: Poseidon

//	Description: Initializes the dynamic market.

private["_resetMarket","_marketPrices","_query","_new","_marketPriceArray","_foodDiv","_legalDiv","_basePrices","_illegalDiv","_apple","_peach","_salema","_ornate","_mackerel","_mullet","_catshark","_tuna","_saltr","_cement","_glass","_ironr","_copperr","_silverr","_platinumr","_oilp","_diamondc","_marijuana","_frogp","_mmushroom","_heroinp","_cocainep","_turtle","_moonshine","_crystalmeth","_goldbar"];

_query = format["SELECT market_array FROM market WHERE id='%1'",olympus_market];
_marketPrices = [_query,2,true] call OES_fnc_asyncCall;
_marketPrices = call compile format["%1", (_marketPrices select 0) select 0];
"------------- Market Query Request -------------" call OES_fnc_diagLog;
format["Query: %1",_query] call OES_fnc_diagLog;
format["Market Query Result: %1",_marketPrices] call OES_fnc_diagLog;
"------------------------------------------------" call OES_fnc_diagLog;

_basePrices = [
	//---------------------------
	32,//_apple
	48,//_peach
	94,//_salema
	94,//_ornate
	290,//_mackerel
	320,//_mullet
	928,//_catshark
	620,//_tuna

	//---------------------------
	1229,//_saltr
	1725,//_cement
	1164,//_glass
	1349,//_ironr
	1280,//_copperr
	1313,//_silverr
	1441,//_platinumr
	2268,//_oilp
	1630,//_diamondc

	//---------------------------
	1976,//_marijuana
	1837,//_frogp
	2581,//_mmushroom
	2115,//_heroinp
	2255,//_cocainep
	7980,//_turtle
	8406,//_moonshine
	8820,//_crystalmeth
	42500//_goldbar
];

_minMul = 0.7;
_maxMul = 1.3;
_resetMarket = false;

if(count _marketPrices < 25) then {
	_resetMarket = true;
}else{
	if((_marketPrices select 28) < 30000) then {
		_resetMarket = true;
	};
};

if(_resetMarket) then {
	//------
	_foodDiv = 0;
	_apple = _basePrices select 0;
	_peach = _basePrices select 1;
	_salema = _basePrices select 2;
	_ornate = _basePrices select 3;
	_mackerel = _basePrices select 4;
	_mullet = _basePrices select 5;
	_catshark = _basePrices select 6;
	_tuna = _basePrices select 7;

	//------
	_legalDiv = 0;
	_saltr = _basePrices select 8;
	_cement = _basePrices select 9;
	_glass = _basePrices select 10;
	_ironr = _basePrices select 11;
	_copperr = _basePrices select 12;
	_silverr = _basePrices select 13;
	_platinumr = _basePrices select 14;
	_oilp = _basePrices select 15;
	_diamondc = _basePrices select 16;

	//------
	_illegalDiv = 0;
	_marijuana = _basePrices select 17;
	_frogp = _basePrices select 18;
	_mmushroom = _basePrices select 19;
	_heroinp = _basePrices select 20;
	_cocainep = _basePrices select 21;
	_turtle = _basePrices select 22;
	_moonshine = _basePrices select 23;
	_crystalmeth = _basePrices select 24;
	_goldbar = _basePrices select 25;
}else{
	//------
	_foodDiv = _marketPrices select 0;
	_apple = _marketPrices select 1;
	_peach = _marketPrices select 2;
	_salema = _marketPrices select 3;
	_ornate = _marketPrices select 4;
	_mackerel = _marketPrices select 5;
	_mullet = _marketPrices select 6;
	_catshark = _marketPrices select 7;
	_tuna = _marketPrices select 8;
	//------
	_legalDiv = _marketPrices select 9;
	_saltr = _marketPrices select 10;
	_cement = _marketPrices select 11;
	_glass = _marketPrices select 12;
	_ironr = _marketPrices select 13;
	_copperr = _marketPrices select 14;
	_silverr = _marketPrices select 15;
	_platinumr = _marketPrices select 16;
	_oilp = _marketPrices select 17;
	_diamondc = _marketPrices select 18;
	//------
	_illegalDiv = _marketPrices select 19;
	_marijuana = _marketPrices select 20;
	_frogp = _marketPrices select 21;
	_mmushroom = _marketPrices select 22;
	_heroinp = _marketPrices select 23;
	_cocainep = _marketPrices select 24;
	_turtle = _marketPrices select 25;
	_moonshine = _marketPrices select 26;
	_crystalmeth = _marketPrices select 27;
	_goldbar = _marketPrices select 28;
};


life_market_resources = [
	//######################################################################
	["foodDiv", 0, 0, 0, 0, 0,[
	]],

	["apple", _apple, round((_basePrices select 0) * _minMul), round((_basePrices select 0) * _maxMul), 0.5, 1,[
		["peach",0.5]
	]],

	["peach", _peach, round((_basePrices select 1) * _minMul), round((_basePrices select 1) * _maxMul), 0.5, 1,[
		["apple",0.5]
	]],

	["salema", _salema, round((_basePrices select 2) * _minMul), round((_basePrices select 2) * _maxMul), 0.1, 1,[
	]],

	["ornate", _ornate, round((_basePrices select 3) * _minMul), round((_basePrices select 3) * _maxMul), 0.2, 1,[
		["salema",0.2]
	]],

	["mackerel", _mackerel, round((_basePrices select 4) * _minMul), round((_basePrices select 4) * _maxMul), 0.3, 1,[
		["salema",0.3],
		["ornate",0.3]
	]],

	["mullet", _mullet, round((_basePrices select 5) * _minMul), round((_basePrices select 5) * _maxMul), 0.5, 1,[
		["salema",0.5],
		["ornate",0.5],
		["mackerel",0.5]
	]],

	["catshark", _catshark, round((_basePrices select 6) * _minMul), round((_basePrices select 6) * _maxMul), 1, 1,[
		["salema",1],
		["ornate",1],
		["mackerel",1],
		["mullet",1],
		["tuna",1]
	]],

	["tuna", _tuna, round((_basePrices select 7) * _minMul), round((_basePrices select 7) * _maxMul), 2, 1,[
		["salema",2],
		["ornate",2],
		["mackerel",2],
		["mullet",2],
		["catshark",2]
	]],

	//######################################################################
	["legalDiv", 0, 0, 0, 0, 0,[
	]],

	["saltr", _saltr, round((_basePrices select 8) * _minMul), round((_basePrices select 8) * _maxMul), 3, 1,[
		["cement",1],
		["glass",1],
		["ironr",1],
		["copperr",1],
		["silverr",1],
		["platinumr",1],
		["oilp",1],
		["diamondc",1]
	]],

	["cement", _cement, round((_basePrices select 9) * _minMul), round((_basePrices select 9) * _maxMul), 3, 1,[
		["saltr",1],
		["glass",1],
		["ironr",1],
		["copperr",1],
		["silverr",1],
		["platinumr",1],
		["oilp",1],
		["diamondc",1]
	]],

	["glass", _glass, round((_basePrices select 10) * _minMul), round((_basePrices select 10) * _maxMul), 3, 1,[
		["saltr",1],
		["cement",1],
		["ironr",1],
		["copperr",1],
		["silverr",1],
		["platinumr",1],
		["oilp",1],
		["diamondc",1]
	]],

	["ironr", _ironr, round((_basePrices select 11) * _minMul), round((_basePrices select 11) * _maxMul), 3, 1,[
		["saltr",1],
		["cement",1],
		["glass",1],
		["copperr",1],
		["silverr",1],
		["platinumr",1],
		["oilp",1],
		["diamondc",1]
	]],

	["copperr", _copperr, round((_basePrices select 12) * _minMul), round((_basePrices select 12) * _maxMul), 3, 1,[
		["saltr",1],
		["cement",1],
		["glass",1],
		["ironr",1],
		["silverr",1],
		["platinumr",1],
		["oilp",1],
		["diamondc",1]
	]],

	["silverr", _silverr, round((_basePrices select 13) * _minMul), round((_basePrices select 13) * _maxMul), 3, 1,[
		["saltr",1],
		["cement",1],
		["glass",1],
		["ironr",1],
		["copperr",1],
		["platinumr",1],
		["oilp",1],
		["diamondc",1]
	]],

	["platinumr", _platinumr, round((_basePrices select 14) * _minMul), round((_basePrices select 14) * _maxMul), 3, 1,[
		["saltr",1],
		["cement",1],
		["glass",1],
		["ironr",1],
		["copperr",1],
		["silverr",1],
		["oilp",1],
		["diamondc",1]
	]],

	["oilp", _oilp, round((_basePrices select 15) * _minMul), round((_basePrices select 15) * _maxMul), 3, 1,[
		["saltr",1],
		["cement",1],
		["glass",1],
		["ironr",1],
		["copperr",1],
		["silverr",1],
		["platinumr",1],
		["diamondc",1]
	]],

	["diamondc", _diamondc, round((_basePrices select 16) * _minMul), round((_basePrices select 16) * _maxMul), 3, 1,[
		["saltr",1],
		["cement",1],
		["glass",1],
		["ironr",1],
		["copperr",1],
		["silverr",1],
		["platinumr",1],
		["oilp",1]
	]],

	//######################################################################
	["illegalDiv", 0, 0, 0, 0, 0,[
	]],

	["marijuana", _marijuana, round((_basePrices select 17) * _minMul), round((_basePrices select 17) * _maxMul), 3, 1,[
		["frogp",1],
		["mmushroom",1],
		["heroinp",1],
		["cocainep",1],
		["turtle",1],
		["moonshine",1],
		["crystalmeth",1]
	]],

	["frogp", _frogp, round((_basePrices select 18) * _minMul), round((_basePrices select 18) * _maxMul), 3, 1,[
		["marijuana",1],
		["mmushroom",1],
		["heroinp",1],
		["cocainep",1],
		["turtle",1],
		["moonshine",1],
		["crystalmeth",1]
	]],

	["mmushroom", _mmushroom, round((_basePrices select 19) * _minMul), round((_basePrices select 19) * _maxMul), 3,1,[
		["marijuana",1],
		["frogp",1],
		["heroinp",1],
		["cocainep",1],
		["turtle",1],
		["moonshine",1],
		["crystalmeth",1]
	]],

	["heroinp", _heroinp, round((_basePrices select 20) * _minMul), round((_basePrices select 20) * _maxMul), 3, 1,[
		["marijuana",1],
		["frogp",1],
		["mmushroom",1],
		["cocainep",1],
		["turtle",1],
		["moonshine",1],
		["crystalmeth",1]
	]],

	["cocainep", _cocainep, round((_basePrices select 21) * _minMul), round((_basePrices select 21) * _maxMul), 3, 1,[
		["marijuana",1],
		["frogp",1],
		["mmushroom",1],
		["heroinp",1],
		["turtle",1],
		["moonshine",1],
		["crystalmeth",1]
	]],

	["turtle", _turtle, round((_basePrices select 22) * _minMul), round((_basePrices select 22) * _maxMul), 3, 1,[
		["marijuana",1],
		["frogp",1],
		["mmushroom",1],
		["heroinp",1],
		["cocainep",1],
		["moonshine",1],
		["crystalmeth",1]
	]],

	["moonshine", _moonshine, round((_basePrices select 23) * _minMul), round((_basePrices select 23) * _maxMul), 5, 1,[
		["marijuana",1],
		["frogp",1],
		["mmushroom",1],
		["heroinp",1],
		["cocainep",1],
		["turtle",1],
		["crystalmeth",1]
	]],

	["crystalmeth", _crystalmeth, round((_basePrices select 24) * _minMul), round((_basePrices select 24) * _maxMul), 5, 1,[
		["marijuana",1],
		["frogp",1],
		["mmushroom",1],
		["heroinp",1],
		["cocainep",1],
		["turtle",1],
		["moonshine",1]
	]],

	["goldbar", _goldbar, round((_basePrices select 25) * 0.9), round((_basePrices select 25) * 1.3), 10, 1,[
	]]
];

publicVariable "life_market_resources";
life_market_shortnames = [];
{
	life_market_shortnames set [count life_market_shortnames, _x select 0];
}
foreach life_market_resources;
publicVariable "life_market_shortnames";


randomized_market_life_market_prices = [];
{
	randomized_market_life_market_prices set [count randomized_market_life_market_prices, [_x select 0, _x select 1, 0, 0] ];
}
foreach life_market_resources;
publicVariable "randomized_market_life_market_prices";

diag_log "Market Prices Generated!";


//save market prices every 10 minutes

while{true} do {
	uiSleep (60 * 10);
	_marketPriceArray = [];
	{_marketPriceArray pushBack (round(_x select 1));}foreach randomized_market_life_market_prices;
	_marketPriceArray = [_marketPriceArray] call OES_fnc_mresArray;

	_query = format["UPDATE market SET market_array='%1' WHERE id='%2'",_marketPriceArray,olympus_market];

	[_query,1] call OES_fnc_asyncCall;
};







