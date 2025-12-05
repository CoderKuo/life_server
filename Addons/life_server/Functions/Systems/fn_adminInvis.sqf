// fn_adminInvis.sqf

private["_mode","_player"];
_mode = _this select 0;
_player = _this select 1;

switch(_mode) do {
	case 0: {_player hideObjectGlobal true; _player setVariable["olympusinvis",true,true];};
	case 1: {_player hideObjectGlobal false; _player setVariable["olympusinvis",nil,true];};
};