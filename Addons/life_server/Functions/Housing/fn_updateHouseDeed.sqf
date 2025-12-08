// File: updateHouseDeed.sqf
// Author: Tech
// Desciption: Updates the timestamp on houses by updating the expires_on sql column.
// Modified: 迁移到 PostgreSQL Mapper 层

params [
  ["_houseID",-1,[0]],
  ["_daysToAdd",-1,[0]]
];
if(_houseID isEqualTo -1 || _daysToAdd isEqualTo -1) exitWith {};

// 使用 Mapper 延长房产契约
["extenddeed", [str _houseID, _daysToAdd, str olympus_server]] call DB_fnc_houseMapper;
