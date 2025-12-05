//  File: fn_spawnBlackwaterLoot
//	Description: Spawns the loot and vehicle(s) for the blackwater robbery

private _bwweapons = [];
private _bwclothes = [];
private _bwaccessories = [];
private _bwvehicle = [];
private _bwexplosive = [];

if (isNil "blackwaterCrates") then {
	blackwaterCrates = [];
} else {
	if(count blackwaterCrates > 0) then {
		{
			if (!isNull _x) then {
				deleteVehicle _x;
			};
		} forEach blackwaterCrates;

		blackwaterCrates = [];

		sleep 2;//allows time for the previous crates to be deleted
	};
};
blackwaterSpawnedGear = [];

{
	private _crate = ("B_Slingload_01_Cargo_F" createVehicle (_x select 0));
	_crate setDir (_x select 1);
	_crate allowDamage false;
	clearBackpackCargoGlobal _crate;
	clearWeaponCargoGlobal _crate;
	clearMagazineCargoGlobal _crate;
	clearItemCargoGlobal _crate;
	blackwaterCrates pushBack _crate;
} forEach [[[20907.8,19212.5,0.000969887],230],[[20896.3,19207.3,0.00312042],255]];

private _selectRandomLoot = {
	private _mode = param [0,"",[""]];
	private _validPackages = [];
	private _allPackages = ([_mode] call OEC_fnc_blackwaterLootConfig);
	private _items = [];
	private _weights = [];

	{
		if(!(_x in blackwaterSpawnedGear)) then {
			_validPackages pushBackUnique _x;
			_items pushBack (_x select 0);
			_weights pushBack (_x select 1);
		};
	}foreach _allPackages;

	private _selectedItem = ([_items, _weights] call OES_fnc_selectRandomWeighted);

	blackwaterSpawnedGear pushBack (_validPackages select (_selectedItem select 1));

	(_selectedItem select 0);
};

{
	private _packageType = _x select 0;
	private _packageCount = _x select 1;


	for "_i" from 1 to _packageCount do {
		private _itemsArray = [_packageType] call _selectRandomLoot;
		private _selectedCrate = selectRandom(blackwaterCrates);

		switch(_packageType) do {
			case "weapon":{
				_currentWeapon = _itemsArray select 0;
				_bwweapons pushBack _currentWeapon;
				_selectedCrate addWeaponCargoGlobal [(_itemsArray select 0),1];
				_selectedCrate addMagazineCargoGlobal [(_itemsArray select 1),5];
			};

			case "clothing":{
				{
					_bwclothes pushBack _x;
					_selectedCrate addItemCargoGlobal [_x, 1];
				}foreach _itemsArray;
			};

			case "accessory":{
				{
					_bwaccessories pushBack _x;
					_selectedCrate addItemCargoGlobal [_x, 1];
				}foreach _itemsArray;
			};

			case "vehicle":{
				_currentVehicle = _itemsArray select 0;
				_bwvehicle pushBack _currentVehicle;
				[(_itemsArray select 0)] spawn OES_fnc_spwnUnownedVeh;

			};

			case "explosive":{
				{
					_bwexplosive pushBack _x;
					_selectedCrate addMagazineCargoGlobal [_x, 1];
				}foreach _itemsArray;
			};
		};
	};
}foreach [
	["weapon", (6 + round(random(2)))],
	["clothing", (6 + round(random(2)))],
	["accessory", (4 + round(random(2)))],
	["vehicle", 1],
	["explosive", (4 + round(random(2)))]
];

//Add 2 Pilot Coveralls to each blackwater crate
{
	_x addItemCargoGlobal ["U_O_PilotCoveralls", 2];
} forEach blackwaterCrates;

[] spawn{
	sleep (60 * 30);

	private _blackwaterDome = nearestObject [[20898.6,19221.7,0.00143909],"Land_Dome_Big_F"];

	if(count blackwaterCrates > 0) then {
		{
			if(!isNull _x) then {
				deleteVehicle _x;
			};
		}foreach blackwaterCrates;

		blackwaterCrates = [];
	};

	sleep (60 * 30);

	for "_i" from 1 to 3 do {_blackwaterDome setVariable[format["bis_disabled_Door_%1",_i],1,true]; _blackwaterDome animate [format["Door_%1_rot",_i],0];};

	_blackwaterDome setVariable ["bwcooldown", false, true];
};

[format['{"event":"Detonated Bomb", "type":"Blackwater", "position":%7, "cops_online":%1, "spawned": {"weapons":%2, "clothing":%3, "accessories":%4, "explosives":%5, "vehicles":%6}}',west countSide playableUnits,_bwweapons,_bwclothes,_bwaccessories,_bwexplosive,_bwvehicle,position (nearestObject [[20898.6,19221.7,0.00143909],"Land_Dome_Big_F"])]] call OES_fnc_logIt;
