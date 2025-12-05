/*
    File: fn_seizePlayerItemsCiv.sqf
    Author: Kurt Reanolds

    Description:
    Removes a specific piece of gear from the player and drops it to the ground.
*/

private["_holder","_bagItems""_bag","_helm","_nvg","_uniItems","_uni","_vestItems","_vest","_weaponPrimary","_weaponAttachPrimary","_weaponSecondary","_weaponAttachSecondary","_weaponHandgun","_weaponAttachHandgun","_distance"];

params [
    ["_slot","",[""]],
    ["_robber",objNull,[objNull]],
    ["_victim",objNull,[objNull]]
];

_holder = nearestObject [_robber, "groundWeaponHolder"]; // This will return objNull if non-exsistent

if !(isNull _holder) then {
    //Check to make sure the distance between the player and the nearest ground weapon holder on the ground is less than 5 meters.
    _distance = _robber distance2D _holder;
    if (_distance > 5) then {
         _holder = createVehicle ["groundWeaponHolder",getPosATL _robber,[], 0, "can_collide"] ;
         serv_weaponholder_cleanup pushBack [_holder,(serverTime + (900))];
    };
} else {
    //-- code for creating a new ground holder
    _holder = createVehicle ["groundWeaponHolder",getPosATL _robber,[], 0, "can_collide"] ;
    serv_weaponholder_cleanup pushBack [_holder,(serverTime + (900))];
};



switch _slot do {
    case "backpack": {
        //Backpack Items
        _bagItems = backpackItems _victim;
        if (count _bagItems > 0) then {
            {
                _holder addItemCargoGlobal[_x, 1];
            } forEach (_bagItems);
            format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _bagItems] call OES_fnc_diagLog;
        };
        //Backpack Slot
        _bag = backpack _victim;
        if !(_bag IsEqualTo "") then {
            _holder addBackpackCargoGlobal[_bag, 1];
            removeBackpackGlobal _victim;
            format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _bag] call OES_fnc_diagLog;
        };
    };
    case "headgear": {
        //Helm Slot
        _helm = headgear _victim;
        _nvg = hmd _victim;
        if !(_helm IsEqualTo "") then {
            _holder addItemCargoGlobal[_helm, 1];
            removeHeadgear _victim;
            format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _helm] call OES_fnc_diagLog;
        };
        if !(_nvg IsEqualTo "") then {
            _holder addItemCargoGlobal[_nvg, 1];
            _victim removeWeaponGlobal _nvg;
            format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _nvg] call OES_fnc_diagLog;
        };
    };
    case "uniform": {
        //Uniform Items
        _uniItems = getMagazineCargo uniformContainer _victim;
         if (count (_uniItems select 0) > 0) then {
            for [{_i = 0}, {_i < count (_uniItems select 0)}, {_i=_i+1}] do {
                 _holder addItemCargoGlobal[(_uniItems select 0) select _i, (_uniItems select 1) select _i];
            };
            format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _uniItems] call OES_fnc_diagLog;
        };
        //Uniform Slot
        _uni = uniform _victim;
        if !(_uni IsEqualTo "") then {
            _holder addItemCargoGlobal[_uni, 1];
            removeUniform _victim;
            format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _uni] call OES_fnc_diagLog;
        };
    };
    case "vest": {
        //Vest Items
        _vestItems = getMagazineCargo vestContainer _victim;
         if (count (_vestItems select 0) > 0) then {
            for [{_i = 0}, {_i < count (_vestItems select 0)}, {_i=_i+1}] do {
                 _holder addItemCargoGlobal[(_vestItems select 0) select _i, (_vestItems select 1) select _i];
            };
            format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _vestItems] call OES_fnc_diagLog;
        };
        //Vest Slot
        _vest = vest _victim;
        if !(_vest IsEqualTo "") then {
            _holder addItemCargoGlobal[_vest, 1];
            removeVest _victim;
            format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _vest] call OES_fnc_diagLog;
        };
    };
    case "weapon": {
        //Weapon Slot
        _weaponPrimary = primaryWeapon _victim;
        _weaponSecondary = secondaryWeapon _victim;
        _weaponHandgun = handgunWeapon _victim;
        _weaponAttachPrimary = primaryWeaponItems _victim;
        _weaponAttachSecondary = secondaryWeaponItems _victim;
        _weaponAttachHandgun = handgunItems _victim;
        if !(_weaponPrimary isEqualTo "") then {
            {
                if (_x != "") then {
                    _holder addItemCargoGlobal [_x, 1];
                    format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _x] call OES_fnc_diagLog;
                };
            } forEach _weaponAttachPrimary;
            {
                _holder addItemCargoGlobal [_x, 1];
            } forEach (primaryWeaponMagazine _victim);
			_holder addWeaponWithAttachmentsCargoGlobal [[_weaponPrimary, "", "", "", [], [], ""], 1];
            _victim removeWeaponGlobal _weaponPrimary;
        };
        if !(_weaponSecondary isEqualTo "") then {
            {
                if (_x != "") then {
                    _holder addItemCargoGlobal [_x, 1];
                    format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _x] call OES_fnc_diagLog;
                };
            } forEach _weaponAttachSecondary;
            {
                _holder addItemCargoGlobal [_x, 1];
            } forEach (secondaryWeaponMagazine _victim);
			_holder addWeaponWithAttachmentsCargoGlobal [[_weaponSecondary, "", "", "", [], [], ""], 1];			
            _victim removeWeaponGlobal _weaponSecondary;
        };
        if !(_weaponHandgun isEqualTo "") then {
            {
                if (_x != "") then {
                    _holder addItemCargoGlobal [_x, 1];
                    format["%1(%2) robbed the following from %3(%4): %5",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _x] call OES_fnc_diagLog;
                };
            } forEach _weaponAttachHandgun;
            {
                _holder addItemCargoGlobal [_x, 1];
            } forEach (handgunMagazine _victim);
			_holder addWeaponWithAttachmentsCargoGlobal [[_weaponHandgun, "", "", "", [], [], ""], 1];
            _victim removeWeaponGlobal _weaponHandgun;
        };
        format["%1(%2) robbed the following from %3(%4): %5, %6, %7",name _robber, getPlayerUID _robber, name _victim, getPlayerUID _victim, _weaponPrimary, _weaponSecondary, _weaponHandgun] call OES_fnc_diagLog;
    };
    case "inventory": {
        //y-inventory
        [_robber] remoteExecCall ["OEC_fnc_robInventory",_victim,false];
    };
};
[true] remoteExecCall ["OEC_fnc_saveGear",_victim,false];


//Checks to make sure that a charge is applied once per 15 minutes
private _recentRob = false;
private _exit = false;

{
    if (((_x select 0) isEqualTo getPlayerUID _robber) && ((_x select 1) isEqualTo getPlayerUID _victim)) then {
        if ((_x select 2) > serverTime) exitWith {
            _exit = true;
            _recentRob = true;
        };
        if ((_x select 2) <= serverTime) then {
            serv_gear_robberies deleteAt _forEachIndex;
            _exit = true;
        };
    };
    if (_exit) exitWith {};
} forEach serv_gear_robberies;

if !(_recentRob) then {
    serv_gear_robberies pushBack [getPlayerUID _robber,getPlayerUID _victim,(serverTime + (1800))];
    [getPlayerUID _robber,_robber getVariable["realname",name _robber],"8",_robber] spawn OES_fnc_wantedAdd;
    [["robberies",1],"OEC_fnc_statArrUp",_robber,false] spawn OEC_fnc_MP;
};
