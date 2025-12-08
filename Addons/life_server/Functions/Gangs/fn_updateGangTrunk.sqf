//	File: fn_updateGangTrunk.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Updates the gang trunk in the database.
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_building",objNull,[objNull]],
	["_logOrNot",true,[false]]
];
if (isNull _building) exitWith {"#### Gang Building Issue - Failed to sync trunk, building object is null!" call OES_fnc_diagLog;};

private _trunkData = _building getVariable ["Trunk",[[-199],0]];
private _physicalTrunkData = _building getVariable ["PhysicalTrunk",[[-199],0]];

if ((_trunkData isEqualTo [[-199],0]) && (_physicalTrunkData isEqualTo [[-199],0])) exitWith {"#### Gang Building Issue - Failed to sync trunk, building trunk data not found on building." call OES_fnc_diagLog;};

private _gangName = _building getVariable ["bldg_gangName",""];
if (_gangName isEqualTo "") exitWith {"#### Gang Building Issue - Failed to sync trunk, building had no gangname set." call OES_fnc_diagLog;};

private _gangID = _building getVariable ["bldg_gangid",-1];
if (_gangID isEqualTo -1) exitWith {"#### Gang Building Issue - Failed to sync trunk, building had no gangid set." call OES_fnc_diagLog;};

if (_logOrNot) then {
	private _buildingOwner = _building getVariable ["bldg_owner","No pid var"];
	format["Gang Building trunk updated. Building GangID: %1, Server: %5, Building Owner: %2, GangName: %3(%1) Trunk: %4",_gangID,_buildingOwner,_gangName,_trunkData,olympus_server] call OES_fnc_diagLog;
};

_trunkData = [_trunkData] call OES_fnc_escapeArray;
_physicalTrunkData = [_physicalTrunkData] call OES_fnc_escapeArray;

// 使用 Mapper 更新建筑库存
["updatebuildinginventory", [str _gangID, _gangName, str olympus_server, _trunkData, _physicalTrunkData]] call DB_fnc_gangMapper;
