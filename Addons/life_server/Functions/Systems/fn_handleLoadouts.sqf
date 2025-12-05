//	File: fn_handleLoadouts.sqf
//	Author: Fusah, Raykazi
//	Description: Handles serverside shit of loadouts

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
		/* private _query = format["SELECT pid FROM loadoutsNew WHERE pid='%1' AND loadout='%2' AND shop='%3'",getplayerUID _unit, _slot, _shopType];
		private _queryResult = [_query,2] call OES_fnc_asyncCall;
		if ((count _queryResult != 0)) then {_inDB = true}; //and he is in boies
		[_loadout] call OES_fnc_mresArray;
		if !(_inDB) then {
		} else {
			_query = format["UPDATE loadoutsNew SET physical_items='%1', virtual_items='%2' WHERE pid='%3' AND loadout='%4' AND shop='%5'", _loadout, _playerInv, getplayerUID _unit, _slot, _shopType];
			[_query,1] call OES_fnc_asyncCall;
		}; */
		_query = format["INSERT INTO loadoutsNew (pid, physical_items, virtual_items, shop, loadout) VALUES('%1','%2','%3','%4','%5') on duplicate key update physical_items = values(physical_items), virtual_items = values(virtual_items)",getplayerUID _unit, _loadout, _playerInv, _shopType, _slot];
		[_query,1] call OES_fnc_asyncCall;
		[1,format["Loadout has been saved successfully!"]] remoteExec ["OEC_fnc_broadcast",_unit,false];
	};
	case 2: {
		private _query = format["SELECT physical_items, virtual_items FROM loadoutsNew WHERE pid='%1' AND loadout='%2' AND shop='%3'",getplayerUID _unit, _slot, _shopType];
		private _queryResult = [_query, 2] call OES_fnc_asyncCall;
		_newLoadout = [str (_queryResult select 0)] call OES_fnc_mresToArray;
		if (_newLoadout isEqualType "") then { _newLoadout = call compile format["%1", _newLoadout]; };
		_unit setUnitLoadout _newLoadout;
		/* _query = format["SELECT virtual_items FROM loadoutsNew WHERE pid='%1' AND loadout='%2' AND shop='%3'",getplayerUID _unit, _slot, _shopType];
		_queryResult = [_query, 2] call OES_fnc_asyncCall; */
		_newInv = [str (_queryResult select 1)] call OES_fnc_mresToArray;
		if (_newInv isEqualType "") then {
			_newInv = call compile format["%1", _newInv];
		};
		{
			[true,_x select 0,_x select 1] remoteExec ["OEC_fnc_handleInv",(owner _unit),false];
		} forEach _newInv;
		[format['{"event":"Obtained Loadout", "player":"%1", "target":"%2", "loadout":"%3", "location":"%4"}',getPlayerUID _unit,'null',_newLoadout,getPos _unit]] remoteExecCall ["OES_fnc_logIt", 2];
	};
	case 3: {
		//1 = good // 2 = nonexistant
		private _query = format["SELECT pid, physical_items, virtual_items FROM loadoutsNew WHERE pid='%1' AND loadout='%2' AND shop='%3' AND physical_items!='[]' AND virtual_items!='[]'",getplayerUID _unit, _slot, _shopType];
		private _queryResult = [_query,2] call OES_fnc_asyncCall;
		if ((count _queryResult != 0)) exitWith {
			/* _query = format["SELECT physical_items FROM loadoutsNew WHERE pid='%1' AND physical_items!='[]' AND loadout='%2' AND shop='%3'",getplayerUID _unit, _slot, _shopType];
			_queryResult = [_query,2] call OES_fnc_asyncCall;
			if ((count _queryResult == 0)) exitWith {}; */
			_newLoadout = [(_queryResult select 1)] call OES_fnc_mresToArray;
			if (_newLoadout isEqualType "") then {
				_newLoadout = call compile format["%1", _newLoadout];
			};
			/* _query = format["SELECT virtual_items FROM loadoutsNew WHERE pid='%1' AND virtual_items!='[]' AND loadout='%2' AND shop='%3'",getplayerUID _unit, _slot, _shopType];
			_queryResult = [_query,2] call OES_fnc_asyncCall;
			if ((count _queryResult == 0)) exitWith {}; */
			_newInv = [(_queryResult select 2)] call OES_fnc_mresToArray;
			if (_newInv isEqualType "") then {
				_newInv = call compile format["%1", _newInv];
			};

			[_slot, 1, _newLoadout, _vendorPos, _invPrice, _newInv] remoteExec ["OEC_fnc_loadLoadout",(owner _unit),false];
		}; //and he is in boies
		[-1, 1, [], _vendorPos, _invPrice, []] remoteExec ["OEC_fnc_loadLoadout",(owner _unit),false];
	};
};
