//	File: fn_chopShopSell.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Checks whether or not the vehicle is persistent or temp and sells it.
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_vehicle","_isInsured","_color","_gangID"];
params [
	["_player",objNull,[objNull]],
	["_vehicle",objNull,[objNull]],
	["_price",500,[0]],
	["_cash",0,[0]],
	["_cashRand",0,[0]]
];

//Error checks
if(isNull _vehicle || isNull _player) exitWith {
	// [["oev_action_inUse",false],"OEC_fnc_netSetVar",nil,false] spawn OEC_fnc_MP;
};

private _unit = owner _player;
_dbInfo = _vehicle getVariable["dbInfo",[]];
_gangID = _vehicle getVariable ["gangID",0];
_displayName = getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName");
_isInsured = _vehicle getVariable["insured",1];
_color = ((_vehicle getVariable ["oev_veh_color",["Default",0]]) select 0);
if (_color isEqualType 0) then {_color = str _color};
// pharma vehicles have _dbInfo = "1234"
if (typeName _dbInfo == "ARRAY" && count _dbInfo > 0) then {
	_uid = _dbInfo select 0;
	_plate = _dbInfo select 1;

	switch (_isInsured) do {
		case 0: {
			// 无保险 - 删除车辆
			if !(_gangID isEqualTo 0) then {
				["sellgang", [str _gangID, str _plate]] call DB_fnc_vehicleMapper;
			} else {
				["sell", [_uid, str _plate]] call DB_fnc_vehicleMapper;
			};
		};
		case 1: {
			// 有保险 - 重置车辆
			if !(_gangID isEqualTo 0) then {
				["chopgang", [str _gangID, str _plate, _color]] call DB_fnc_vehicleMapper;
			} else {
				["chop", [_uid, str _plate, _color]] call DB_fnc_vehicleMapper;
			};
		};
		case 2: {
			// 特殊保险 - 保留改装但清库存
			if !(_gangID isEqualTo 0) then {
				["chopgang", [str _gangID, str _plate, _color]] call DB_fnc_vehicleMapper;
			} else {
				["chop", [_uid, str _plate, _color]] call DB_fnc_vehicleMapper;
			};
		};
	};
};

if !(_gangID isEqualTo 0) then {
	format ["88 -LOGGED- %1 (%2) Chopped a gang %3 (%4) for %5",name _player,getPlayerUID _player,typeOf _vehicle,_gangID,[_price] call OEC_fnc_numberText] call OES_fnc_diagLog;
} else {
	format ["88 -LOGGED- %1 (%2) Chopped a %3 (%4) for %5",name _player, getPlayerUID _player,typeOf _vehicle,_vehicle getVariable["vehicle_info_owners","No owner available."],[_price] call OEC_fnc_numberText] call OES_fnc_diagLog;
};

deleteVehicle _vehicle; remoteExec ["OEC_fnc_netSetVar",_unit,false];
["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",_unit,false];
["oev_cash",_cash] remoteExec ["OEC_fnc_netSetVar",_unit,false];
["oev_cache_cash",_cashRand] remoteExec ["OEC_fnc_netSetVar",_unit,false];
[2,format[(localize "STR_NOTF_ChopSoldCar"),_displayName,[_price] call OEC_fnc_numberText]] remoteExec ["OEC_fnc_broadcast",_unit,false];
[1,"Vehicle looks good, here's some cash..."] remoteExec ["OEC_fnc_broadcast",_unit,false];
