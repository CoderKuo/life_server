// File: fn_getPlayer

private["_uid","_mode","_return","_playerObject"];
_uid = param [0,"",[""]];
_mode = param [1,true,[false]];
_return = 0;
_playerObject = objNull;

if(_uid isEqualTo "") exitWith {
	_return = 0;
};

{
	if(isPlayer _x && getplayeruid _x isEqualTo _uid) exitWith {
		_playerObject = _x;
	};
}foreach allPlayers;

if(_mode) then {
	if(isNull _playerObject) then {
		_return = 0;
	}else{
		_return = (owner _playerObject);
	};
}else{
	if(isNull _playerObject) then {
		_return = objNull;
	}else{
		_return = _playerObject;
	};
};

_return;
