//	File: fn_illegalClaim.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Switches vehicle owner in DB
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_vehicle",objNull,[objNull]],
	["_player",objNull,[objNull]],
	["_skins",[],[[]]],
	["_donorLevel",0,[0]],
	["_price",0,[0]]
];

if (isNull _vehicle || isNull _player || !(alive _vehicle)) exitWith {
	"-CLAIM- A vehicle failed to claim." call OES_fnc_diagLog;
};

// 服务端金钱验证 - 防止客户端作弊
private _ownerID = owner _player;
private _atmcash = _player getVariable ["oev_atmcash", 0];
if (_price <= 0) exitWith {
	format ["-CLAIM- Invalid price %1 for player %2", _price, name _player] call OES_fnc_diagLog;
	[["life_claim_done",true],"OEC_fnc_netSetVar",_ownerID,false] spawn OEC_fnc_MP;
};
if (_atmcash < _price) exitWith {
	format ["-CLAIM- Player %1 has insufficient funds (has: %2, needs: %3)", name _player, _atmcash, _price] call OES_fnc_diagLog;
	[[1,"您的银行余额不足!"],"OEC_fnc_broadcast",_ownerID,false] spawn OEC_fnc_MP;
	[["life_claim_done",true],"OEC_fnc_netSetVar",_ownerID,false] spawn OEC_fnc_MP;
};

private _vInfo = _vehicle getVariable ["dbInfo",[]];
if (count _vInfo isEqualTo 0) exitWith {
	format ["-CLAIM- A %1 was attempted to be claimed but was deleted by the server for improper info.",getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")] call OES_fnc_diagLog;
	deleteVehicle _vehicle;
	[[1,"The vehicle had bad info and was possibly spawned in, it has been deleted."],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
	[["life_claim_done",true],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};

if (_vehicle getVariable ["rekey",false]) exitWith {
	[[1,"This vehicle is currently being claimed."],"OEC_fnc_broadcast",(owner _player),false] spawn OEC_fnc_MP;
	[["life_claim_done",true],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};

_vehicle setVariable ["rekey",true,true];
[[_vehicle,2],"OEC_fnc_lockVehicle",_vehicle,false] spawn OEC_fnc_MP;
uiSleep random(5);

private _uid = _vInfo select 0;
private _plate = _vInfo select 1;
_claimerUID = getPlayerUID _player;
_claimerName = name _player;

uiSleep random(5);
uiSleep random(5);

if (isNull _vehicle || !(alive _vehicle) || !(alive _player)) exitWith {
	[["life_claim_done",true],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
};

private _pos = getPos _vehicle;
private _dir = getDir _vehicle;
private _gangID = _vehicle getVariable ["gangID",0];

// 使用 vehicleMapper 获取车辆信息
private _vInformation = [];
if !(_gangID isEqualTo 0) then {
	_vInformation = ["getgangactiveid", [str _gangID, str olympus_server, _plate]] call DB_fnc_vehicleMapper;
} else {
	_vInformation = ["getactiveid", [_uid, str olympus_server]] call DB_fnc_vehicleMapper;
};
private _vid = (_vInformation select 0);

//Prevent non donors claiming donor skins
private _color = (_vehicle getVariable ["oev_veh_color",["Default",0]]) select 0;
if !(_color isEqualTo "-1") then {
	_currentSkin = -1;
	{if ((_x select 0) isEqualTo _color) exitWith {_currentSkin = _forEachIndex}}forEach _skins; // Get color index

	if !(_currentSkin isEqualTo -1) then {
		_color = _skins select _currentSkin select 0;
	} else {
		private _index = floor(random(count _skins));
		_color = _skins select _index select 0;
	}
};

if ((_vehicle getVariable ["side",""]) == "cop") then {
	switch(typeOf _vehicle) do {
		case "C_Hatchback_01_sport_F": {_color = "APDVandal"};
	};
};
if (_color isEqualType 0) then {_color = str _color};
deleteVehicle _vehicle;

// 使用 vehicleMapper 处理车辆认领
if !(_gangID isEqualTo 0) then {
	// 杀死帮派车库中的车辆
	["markgangdead", [str _gangID, _plate]] call DB_fnc_vehicleMapper;
	uiSleep 0.5;
	// 将车辆添加到认领者的车库
	["insert", [_vInformation select 1, _vInformation select 2, _vInformation select 3, _claimerUID, "0", parseText _color, _vInformation select 4, "[0,0,0,0,0,0,0,0]"]] call DB_fnc_vehicleMapper;
	uiSleep 0.5;
	// 从车辆数据库获取新的 vid
	uiSleep 1;
	_vid = (["getbypidplate", [_claimerUID, "0", _vInformation select 4]] call DB_fnc_vehicleMapper) select 0;
} else {
	["claim", [_claimerUID, _uid, _plate, parseText _color]] call DB_fnc_vehicleMapper;
};

uiSleep 2;

// 服务端扣除金钱 - 在成功认领后扣除
private _newAtmcash = _atmcash - _price;
private _newCacheAtmcash = (_player getVariable ["oev_cache_atmcash", 0]) - _price;
["oev_atmcash", _newAtmcash] remoteExec ["OEC_fnc_netSetVar", (owner _player), false];
["oev_cache_atmcash", _newCacheAtmcash] remoteExec ["OEC_fnc_netSetVar", (owner _player), false];
format ["-CLAIM- Deducted $%1 from player %2 for vehicle claim", _price, name _player] call OES_fnc_diagLog;

[[_vid,_claimerUID,_pos,_player,0,_dir],"OES_fnc_spaw1nVehicle",false,false] spawn OEC_fnc_MP;
[["life_claim_success",true],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;
[["life_claim_done",true],"OEC_fnc_netSetVar",(owner _player),false] spawn OEC_fnc_MP;

if !(_gangID isEqualTo 0) then {
	format ["-CLAIM- A %1 (%5) owned by %2(%6) was claimed by %3(%4)",typeOf _vehicle,_gangID,_claimerUID,_claimerName,_vehicle,_vehicle getVariable ["gangName","Error: No Gang Name"]] call OES_fnc_diagLog;
} else {
	format ["-CLAIM- A %1 (%5) owned by %2 was claimed by %3(%4)",typeOf _vehicle,_uid,_claimerUID,_claimerName,_vehicle] call OES_fnc_diagLog;
};
