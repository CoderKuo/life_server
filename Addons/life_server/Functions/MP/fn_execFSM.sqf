private ["_params","_fsm"];

_params = [];
_fsm = param [0,"",["",[]]];

if (_fsm isEqualType []) then {
	_params = param [0,[]];
	_fsm = param [1,"",[""]];

};

_params execfsm _fsm