// File: fn_updateHouseTrunk.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Updates the storage for a house blah blah
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_house",objNull,[objNull]],
	["_log",false,[false]]
];

if (isNull _house) exitWith {"#### House Issue - Failed to sync trunk, house object is null!" call OES_fnc_diagLog;};
_houseID = _house getVariable["house_id",-1];
if (_houseID isEqualTo -1) exitWith {"#### House Issue - Failed to sync trunk, house id == -1." call OES_fnc_diagLog;};

private _trunkData = _house getVariable ["Trunk",[[-199],0]];
private _physicalTrunkData = _house getVariable ["PhysicalTrunk",[[-199],0]];

if (_trunkData isEqualTo [[-199],0] || _physicalTrunkData isEqualTo [[-199],0]) exitWith {"#### House Issue - Failed to sync trunk, house trunk data not found on house." call OES_fnc_diagLog;};

if (_log) then {
	private _houseOwner = _house getVariable["house_owner",["No PID","No Name"]];
	format["House trunk updated. HouseID: %1, HouseOwner: %2(%3), Trunk: %4, Physical Trunk: %5",_houseID, (_houseOwner select 0), (_houseOwner select 1), _trunkData,_physicalTrunkData] call OES_fnc_diagLog;
};

_trunkData = [_trunkData] call OES_fnc_escapeArray;
_physicalTrunkData = [_physicalTrunkData] call OES_fnc_escapeArray;

// 使用 Mapper 更新库存
["updateinventory", [str _houseID, _trunkData, _physicalTrunkData, str olympus_server]] call DB_fnc_houseMapper;
