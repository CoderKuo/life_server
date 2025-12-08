//Author: Fraali
//Usage: Handles server side of house compensation
//Modified: 迁移到 PostgreSQL Mapper 层

private["_house","_uid","_housePos","_player","_houseID","_queryResult"];
params [
	["_player",objNull,[objNull]],
	["_house",objNull,[objNull]]
];

if (isNull _house || isNull _player) exitWith {};
if !((_house getVariable["trunk_in_use",""]) isEqualTo "") exitWith {};

_uid = getPlayerUID _player;
_houseID = _house getVariable ["house_id",-1];

_house setVariable["trunk_in_use",_uid,true];

// 使用 Mapper 获取组件
_queryResult = ["getcomponents", [str _houseID, str olympus_server, _uid]] call DB_fnc_houseMapper;

if !(_queryResult isEqualTo ["[[]]","[[]]"]) then {

  _physComp = [_queryResult select 0]call OES_fnc_mrestoArray;
  _virtComp = [_queryResult select 1]call OES_fnc_mrestoArray;
  _physInv = _house getVariable ["PhysicalTrunk",[[],0]];
  _virtInv = _house getVariable ["Trunk",[[],0]];

  _lcl_addArray = {
    params ["_invArr", "_compArr", "_mode"];
    _arr = [];
		_weight = 0;
    {
      _obj = _x;
      _ind = _forEachIndex;
      _add = true;
      {
        if((_obj select 0) isEqualTo (_x select 0)) exitWith {
          ((_invArr select 0) select _ind) set [1, (_obj select 1) + (_x select 1)];
          _add = false;
        };
      } forEach (_invArr select 0);

      if(_add) then {
        _arr pushBack _x;
      };

			_weight = switch (_mode) do {
				case "virtual": {_weight + (([_x select 0] call OEC_fnc_itemWeight) * (_x select 1))};
				case "physical": {_weight + (getNumber(missionConfigFile >> "CfgWeights" >> _x select 0 >> "weight") * (_x select 1))};
				default {};
			};
    }forEach _compArr;
    [(_invArr select 0) + _arr,(_invArr select 1) + _weight];
  };

  if !(_physComp isEqualTo [[],0]) then {_physInv = [_physInv, _physComp, "physical"] call _lcl_addArray};
  if !(_virtComp isEqualTo [[],0]) then {_virtInv = [_virtInv, _virtComp, "virtual"] call _lcl_addArray};

  _house setVariable ["PhysicalTrunk", _physInv, true];
  _house setVariable ["Trunk", _virtInv, true];

  [_house] call OES_fnc_updateHouseTrunk;

  // 使用 Mapper 重置组件
  ["resetcomponents", [str _houseID, str olympus_server]] call DB_fnc_houseMapper;

  [format['{"event":"House Comp", "player":"%1", "house_id":"%2", "phys_comp":"%3", "virt_comp":"%4"}',_uid,_houseID,_physComp,_virtComp]] call OES_fnc_logIt;

  [1,"Your house has been compensated!"] remoteExec ["OEC_fnc_broadcast",(owner _player)];
} else {
  [1,"There is nothing to compensate!"] remoteExec ["OEC_fnc_broadcast",(owner _player)];
};

_house setVariable["trunk_in_use","",true];
