// File: fn_marketUpdate.sqf
// Author: Jesse "tkcjesse" Schultz
// Description: Triggered by fn_marketCache.sqf
uiSleep 240;
uiSleep round(random(120));

private _saveArr = serv_market_update;
serv_market_update = [];
serv_market_cache = false;

private ["_cfgArr","_index","_curPrice","_tmp","_tmpDecrease","_handle","_curAdjust","_varName","_amount"];
{
	_varName = _x select 0;
	_amount = _x select 1;
	_index = serv_market_varNames find _varName;
	_cfgArr = serv_market_config select _index;
	_curPrice = ((serv_market_storage select _index) select 1);
	_curAdjust = ((serv_market_current select _index) select 1);


	_tmpDecrease = ceil(_curPrice * (_cfgArr select 4) * _amount);
	_tmp = ceil(_curPrice - _tmpDecrease);
	_curAdjust = (_curAdjust - _tmpDecrease);

	if (_tmp < (_cfgArr select 1)) then {
		_tmp = (_cfgArr select 1);
		_curAdjust = ((serv_market_start select _index) - (_cfgArr select 1));
		_curAdjust = (_curAdjust * -1);
	};

	(serv_market_storage select _index) set [1,_tmp];
	serv_market_current set [_index,[_tmp,_curAdjust]];
	serv_market_db set [_index,_tmp];

	_handle = [_varName,(_cfgArr select 3),_amount] spawn OES_fnc_marketSetOthers;
	waitUntil {scriptDone _handle};

} forEach _saveArr;

publicVariable "serv_market_current";

private _tmpArray = [serv_market_db] call OES_fnc_mresArray;
private _query = format ["UPDATE market SET market_array='%1' WHERE id='%2'",serv_market_db,olympus_market];
[_query,1] call OES_fnc_asyncCall;