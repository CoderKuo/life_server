//	File: fn_managesc.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: User management of whether or not they want to be on a sidechat for their side.

params [
	["_unit",objNull,[objNull]],
	["_bool",false,[false]],
	["_side",civilian,[west]],
	["_adminLevel",0,[0]],
	["_streamerMode",false,[false]],
	["_gangChat",false,[false]]
];

if(isNull _unit) exitWith {};
if (_side isEqualTo civilian && {_gangChat}) then {
	life_radio_gang radioChannelAdd [_unit];
} else {
	life_radio_gang radioChannelRemove [_unit];
};
// If admin level is 5 then just do admin channel stuffs
if (_adminLevel != 5) then {
	if (_adminLevel > 0) then {life_radio_admin radioChannelAdd [_unit];};
	switch (_side) do {
		case west: {
			if(_bool) then {
				life_radio_west radioChannelAdd [_unit];
			} else {
				life_radio_west radioChannelRemove [_unit];
			};
		};

		case civilian: {
			if(_bool) then {
				life_radio_civ radioChannelAdd [_unit];
			} else {
				life_radio_civ radioChannelRemove [_unit];
			};
		};

		case independent: {
			if(_bool) then {
				life_radio_civ radioChannelAdd [_unit];
			} else {
				life_radio_civ radioChannelRemove [_unit];
			};
		};
	};
};

if (_adminLevel == 5) then {
	// Check for streamer mode
	if (!(_streamerMode)) then {
		life_radio_admin radioChannelAdd [_unit];
	} else {
		life_radio_admin radioChannelRemove [_unit];
	};
};