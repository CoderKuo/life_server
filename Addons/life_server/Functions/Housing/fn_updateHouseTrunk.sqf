// File: fn_updateHouseTrunk.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Updates the storage for a house blah blah

params [
	["_house",objNull,[objNull]],
	["_log",false,[false]]
];

if (isNull _house) exitWith {"#### House Issue - Failed to sync trunk, house object is null!" call OES_fnc_diagLog;};
_houseID = _house getVariable["house_id",-1];
if (_houseID isEqualTo -1) exitWith {"#### House Issue - Failed to sync trunk, house id == -1." call OES_fnc_diagLog;}; //Dafuq?

private _trunkData = _house getVariable ["Trunk",[[-199],0]];
private _physicalTrunkData = _house getVariable ["PhysicalTrunk",[[-199],0]];

if (_trunkData isEqualTo [[-199],0] || _physicalTrunkData isEqualTo [[-199],0]) exitWith {"#### House Issue - Failed to sync trunk, house trunk data not found on house." call OES_fnc_diagLog;};

if (_log) then {
	private _houseOwner = _house getVariable["house_owner",["No PID","No Name"]];
	format["House trunk updated. HouseID: %1, HouseOwner: %2(%3), Trunk: %4, Physical Trunk: %5",_houseID, (_houseOwner select 0), (_houseOwner select 1), _trunkData,_physicalTrunkData] call OES_fnc_diagLog;
};

_trunkData = [_trunkData] call OES_fnc_mresArray;
_physicalTrunkData = [_physicalTrunkData] call OES_fnc_mresArray;

_query = format["UPDATE houses SET inventory='%1', physical_inventory='%3' WHERE id='%2' AND server='%4'",_trunkData,_houseID,_physicalTrunkData,olympus_server];
[_query,1] call OES_fnc_asyncCall;
