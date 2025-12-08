//	File: fn_handleLoadouts.sqf
//	Author: Fusah, Raykazi
//	Description: Handles serverside shit of loadouts
//  Modified: 迁移到 PostgreSQL Mapper 层

params [
	["_loadout",[],[[]]],
	["_mode",0,[0]],
	["_unit",ObjNull,[ObjNull]],
	["_shopType","",[""]],
	["_vendorPos",[],[[]]],
	["_playerInv",[],[[]]],
	["_invPrice",0,[0]],
	["_slot",-1,[0]]
];

//_Mode 1 = Save Loadout // _Mode 2 = Set Loadout // _Mode 3 = Check Loadout

private _inDB = false;
private _price = 0;
private _new = "";
private _newInv = "";
private _newLoadout = "";
if (_mode isEqualTo 0 || _unit isEqualTo ObjNull || _shopType isEqualTo "") exitWith {};
private _loadoutType = switch (_shopType) do {
	case "rebel": {"reb_loadout"};
	case "vigilante": {"vigi_loadout"};
	case "cop_basic": {"cop_loadout"};
	case "med_basic": {"med_loadout"};
	default {""};
};
private _invType = switch (_shopType) do {
	case "rebel": {"reb_inv"};
	case "vigilante": {"vigi_inv"};
	case "cop_basic": {"cop_inv"};
	case "med_basic": {"med_inv"};
	default {""};
};

if (_loadoutType isEqualTo "") exitWith {};
switch (_mode) do {
	case 1: {
		if (_loadout isEqualTo []) exitWith {};
		// 使用 miscMapper 保存装备
		["loadoutsave", [getplayerUID _unit, str _loadout, str _playerInv, _shopType, str _slot]] call DB_fnc_miscMapper;
		[1,format["Loadout has been saved successfully!"]] remoteExec ["OEC_fnc_broadcast",_unit,false];
	};
	case 2: {
		// 使用 miscMapper 获取装备
		private _queryResult = ["loadoutget", [getplayerUID _unit, str _slot, _shopType]] call DB_fnc_miscMapper;
		// 解析装备数据和物品栏数据
		_newLoadout = [_queryResult select 0, []] call DB_fnc_parseJsonb;
		_unit setUnitLoadout _newLoadout;
		_newInv = [_queryResult select 1, []] call DB_fnc_parseJsonb;
		{
			[true,_x select 0,_x select 1] remoteExec ["OEC_fnc_handleInv",(owner _unit),false];
		} forEach _newInv;
		[format['{"event":"Obtained Loadout", "player":"%1", "target":"%2", "loadout":"%3", "location":"%4"}',getPlayerUID _unit,'null',_newLoadout,getPos _unit]] remoteExecCall ["OES_fnc_logIt", 2];
	};
	case 3: {
		//1 = good // 2 = nonexistant
		// 使用 miscMapper 检查装备
		private _queryResult = ["loadoutcheck", [getplayerUID _unit, str _slot, _shopType]] call DB_fnc_miscMapper;
		if ((count _queryResult != 0)) exitWith {
			// 解析装备数据和物品栏数据
			_newLoadout = [_queryResult select 1, []] call DB_fnc_parseJsonb;
			_newInv = [_queryResult select 2, []] call DB_fnc_parseJsonb;

			[_slot, 1, _newLoadout, _vendorPos, _invPrice, _newInv] remoteExec ["OEC_fnc_loadLoadout",(owner _unit),false];
		}; //and he is in boies
		[-1, 1, [], _vendorPos, _invPrice, []] remoteExec ["OEC_fnc_loadLoadout",(owner _unit),false];
	};
};
