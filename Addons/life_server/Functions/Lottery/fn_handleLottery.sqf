//	File: fn_handleLottery.sqf
//	Author: Fusah
//	Description: Handles the lottery system.

params ["_type","_player","_amount"];

if (life_lotteryCooldown) exitWith {}; //彩票在冷却
if (typeName _type != "STRING") exitWith {}; //错误的参数
if (isNull _player) exitWith {};

switch (_type) do {
	case "check": {
		private _index = [getPlayerUID _player,life_lottery_list] call OEC_fnc_index;
		if !(_index isEqualTo -1) then {
			["oev_inLottery",true] remoteExec ["OEC_fnc_netSetVar",_player,false];
		} else {
			["oev_inLottery",false] remoteExec ["OEC_fnc_netSetVar",_player,false];
		};
	};
    case "add": {
			if (count life_lottery_list isEqualTo 0) then {
				[] spawn OES_fnc_runLottery;
			};
			for "_i" from 0 to (_amount - 1) do {
				life_lottery_list pushBack [name _player,getPlayerUID _player];
		};
    };
};
