//	File: fn_spawnDeletedAmmoOnLoad.sqf
//	Author: Kurt
//	Description: Spawns ammo in a groundWeaponHolder if the person cannot hold it after loading into the server

params [
	["_player",objNull,[objNull]],
	["_itemsToDrop",[],[[]]]
];

if(isNull _player) exitWith {};

//After the gun has been added see if we can then add it back to the player (since a magazine is loaded into the gun usually once it is spawned).  If it cannot be added then we spawn it on the ground near the player

private _holder = nearestObject [_player, "groundWeaponHolder"]; // This will return objNull if non-exsistent
if (isNull _holder) then {
    //-- code for creating a new ground holder
    _holder = createVehicle ["groundWeaponHolder",getPosATL _player,[], 0, "can_collide"];
    serv_weaponholder_cleanup pushBack [_holder,(serverTime + (900))];
};

{
	_holder addItemCargoGlobal [_x, 1];
} forEach _itemsToDrop;
