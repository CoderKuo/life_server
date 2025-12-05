//author: trimorphious
//case 0 queries db on login to set player variables for hex icons
//case 1 rolls for a random hex icon and sets the according db values
//case 2 sets the hex icon as their currently equipped icon in db
//case 3 unequips the selected icon and sets their currently equipped to "" in db

switch(_this select 1) do {
	case 0: {
		_query = format["select * from hex_icons where pid='%1'",getPlayerUID (_this select 0)];
		_hexArray = [_query,2] call OES_fnc_asyncCall;
		if (count _hexArray != 0) then {
				[4,_hexArray] remoteExec["OEC_fnc_hexIconMaster",(_this select 0)];
		} else {
			_query = format["INSERT INTO hex_icons (pid) VALUES ('%1')",getPlayerUID (_this select 0)];
			[_query,1] call OES_fnc_asyncCall;
			_query = format["select * from hex_icons where pid='%1'",getPlayerUID (_this select 0)];
			_hexArray = [_query,2] call OES_fnc_asyncCall;
			[4,_hexArray] remoteExec["OEC_fnc_hexIconMaster",(_this select 0)];
		};
	};

	case 1: {
		_locked = [];
		_iconArray = _this select 2;
		{
			if(_forEachIndex > 0) then {
				if(_x == 0) then {
					_locked pushBack _forEachIndex;
				};
			};
		} forEach _iconArray;
		if(count _locked == 0) exitWith {};
		_rand = selectRandom _locked;
		_iconArray set [_rand,1];
		[3,_rand, _iconArray] remoteExec["OEC_fnc_hexIconMaster",(_this select 0)];
		_query = format["UPDATE players SET hex_icon_redemptions=hex_icon_redemptions-1 WHERE playerid='%1'",getPlayerUID (_this select 0)];
		[_query,1] call OES_fnc_asyncCall;
		_query = format["UPDATE hex_icons SET `%1`=1 WHERE pid='%2'",getText(((missionConfigFile >> "CfgIcons") select (_rand-1)) >> "name"),getPlayerUID (_this select 0)];
		[_query,1] call OES_fnc_asyncCall;
	};

	case 2: {
		_query = format["UPDATE players SET hex_icon='%1' WHERE playerid='%2'",(_this select 2),getPlayerUID (_this select 0)];
		[_query,1] call OES_fnc_asyncCall;
	};

	case 3: {
		_query = format["UPDATE players SET hex_icon='%1' WHERE playerid='%2'","",getPlayerUID (_this select 0)];
		[_query,1] call OES_fnc_asyncCall;
	};
};