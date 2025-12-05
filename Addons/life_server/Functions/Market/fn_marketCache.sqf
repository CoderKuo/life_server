// File: fn_marketCache.sqf
// Author: Jesse "tkcjesse" Schultz
// Description: Previously called marketStoreData.sqf <- Rewrote now for new market optimization

params [
	["_itemName","",[""]],
	["_amount",-1,[0]]
];

if (_itemName isEqualTo "" || _amount isEqualTo -1) exitWith {};

if !(serv_market_cache) then {
	serv_market_cache = true;
	[] spawn OES_fnc_marketUpdate;
};

private _inArray = false;
private _arrayAmount = 0;

if ((count serv_market_update) > 0) then {
	{
		if ((_x select 0) isEqualTo _itemName) exitWith {
			_inArray = true;
			_arrayAmount = _x select 1;
			(serv_market_update select _forEachIndex) set [1,(_arrayAmount + _amount)];
		};
	} forEach serv_market_update;
};

if !(_inArray) then {
	serv_market_update pushBack [_itemName,_amount];
};

format ["MARKET CACHE UPDATE:  %1",serv_market_update] call OES_fnc_diagLog;