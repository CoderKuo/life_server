// File: fn_marketSetOthers.sqf
// Author: Jesse "tkcjesse" Schultz
// Description: Sets the other market values of items when updating.
params [["_varName","",[""]],["_legality",-1,[0]],["_amount",-1,[0]]];
private ["_legal","_tmpIncrease","_tmpPrice","_curPrice","_curAdjust"];

{
	_legal = ((serv_market_config select _forEachIndex) select 3);
	if (!((_x select 0) isEqualTo _varName) && {_legality isEqualTo _legal}) then {
		_tmpIncrease = ((serv_market_config select _forEachIndex) select 5);
		_curPrice = _x select 1;
		_tmpIncrease = ceil(_curPrice * _tmpIncrease * _amount * 1.15);
		_tmpPrice = ceil(_curPrice + _tmpIncrease);
		_curAdjust = ((serv_market_current select _forEachIndex) select 1);
		_curAdjust = (_curAdjust + _tmpIncrease);

		if (_tmpPrice > ((serv_market_config select _forEachIndex) select 2)) then {
			_curAdjust = (((serv_market_config select _forEachIndex) select 2) - (serv_market_start select _forEachIndex));
			_tmpPrice = ((serv_market_config select _forEachIndex) select 2);
		};

		(serv_market_storage select _forEachIndex) set [1,_tmpPrice];
		serv_market_current set [_forEachIndex,[_tmpPrice,_curAdjust]];
		serv_market_db set [_forEachIndex,_tmpPrice];
		systemChat format ["Price = %1", _curAdjust];
	};
} forEach serv_market_storage;
