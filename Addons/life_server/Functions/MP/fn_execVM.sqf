private ["_params","_script"];

_params = [];
_script = param [0,"",["",[]]];

if (_script isEqualType []) then {
	_params = param [0,[]];
	_script = param [1,"",[""]];
};

_params execvm _script