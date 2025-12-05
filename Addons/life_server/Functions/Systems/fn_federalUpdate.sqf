//	File: fn_federalUpdate.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Uhhh, adds to it?

private["_currentBarAmount","_newBarAmount"];
while {true} do {
	uiSleep (30 * 60);
	if(!(fed_bank getVariable ["safe_open", false])) then {
		_currentBarAmount = fed_bank getVariable["safe",0];
		_newBarAmount = round(_currentBarAmount+((count playableUnits)/2));
		if (_newBarAmount > 350) then {
			_newBarAmount = 350;
		};
		fed_bank setVariable["safe",_newBarAmount,true];
	};
};