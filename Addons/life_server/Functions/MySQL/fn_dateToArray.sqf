//	Author: Poseidon

//	Description: Converts timestamp string from database to arma array
//	_return = [year, month, day, hour, minute, second];

private["_timeStamp","_return"];
_timeStamp = param [0,"",[""]];
_return = [];

if(_timeStamp == "") exitWith {[2015,1,1,1,1,1]};

_return pushBack parseNumber(_timeStamp select[0,4]);
_return pushBack parseNumber(_timeStamp select[5,2]);
_return pushBack parseNumber(_timeStamp select[8,2]);
_return pushBack parseNumber(_timeStamp select[11,2]);
_return pushBack parseNumber(_timeStamp select[14,2]);
_return pushBack parseNumber(_timeStamp select[17,2]);

_return;