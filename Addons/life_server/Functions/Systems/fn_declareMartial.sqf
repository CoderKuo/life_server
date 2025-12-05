//	File: fn_declareMartial.sqf
//	Author: Jesse "tkcjesse" Schultz

params [
	["_mode",-1,[0]],
	["_city","",[""]],
	["_unit",objNull,[objNull]]
];
if (_mode isEqualTo -1 || _city isEqualTo "") exitWith {};
if (life_martialLaw_time isEqualTo 0) exitWith {
	[1,"You cannot declare Martial Law within the first 5 minutes of server start."] remoteExec ["OEC_fnc_broadcast",(owner _unit),false];
};
if (!(life_martialLaw_active) && _mode isEqualTo 1) exitWith {
	[1,"There is no Martial Law active currently to end."] remoteExec ["OEC_fnc_broadcast",(owner _unit),false];
};
if (life_martialLaw_time > serverTime) exitWith {
	if !(isNull _unit) then {
		[1,format["Martial Law was recently declared in a city. Available to declare again in: %1 minutes.",round((life_martialLaw_time - serverTime) / 60)]] remoteExec ["OEC_fnc_broadcast",(owner _unit),false];
	};
};
if (life_martialLaw_active && _mode isEqualTo 1) exitWith {
	life_martialLaw_active = false;
	[1,"Martial Law is set to end within 30 seconds!"] remoteExec ["OEC_fnc_broadcast",(owner _unit),false];
};
if (life_martialLaw_active && _mode isEqualTo 0) exitWith {
	if !(isNull _unit) then {
		[1,"There is already an active Martial Law declared!"] remoteExec ["OEC_fnc_broadcast",(owner _unit),false];
	};
};

private _distance = 600;
private _location = [0,0,0];

switch (_city) do {
	case "Kavala": {
		_distance = 600;
		_location = [3537,13041,0];
	};
	case "Pyrgos": {
		_distance = 500;
		_location = [16814,12660,0];
	};
	case "Sofia": {
		_distance = 450;
		_location = [25684,21335,0];
	};
	case "Athira": {
		_distance = 500;
		_location = [14018,18696,0];
	};
	case "Neochori": {
		_distance = 500;
		_location = [12575,14354,0];
	};
	case "La Trinite": {
		_distance = 500;
		_location = [7271.88,7953.39,0];
	};
	case "Le Port": {
		_distance = 500;
		_location = [8183.7,3168.27,0];
	};
	case "La Riviere": {
		_distance = 500;
		_location = [3725.94,3255.58,0];
	};
};

if !(isNull _unit) then {
	format["Player %1(%2) declared Martial Law in: %1",name _unit,getPlayerUID _unit,_city] call OES_fnc_diagLog;
};
life_martialLaw_active = true;

life_martialLaw_pv = [true,_city];
publicVariable "life_martialLaw_pv";

[_distance,_location,_city] spawn{
	private _time = 0;

	createMarker ["m_law_srv",(_this select 1)];
	"m_law_srv" setMarkerColor "colorBLUFOR";
	"m_law_srv" setMarkerText "!! Martial Law Active !!";
	"m_law_srv" setMarkerType "mil_warning";

	while {true} do {
		private _nearPlayers = [];
		{
			if ((_x distance (_this select 1)) <= (_this select 0)) then {
				_nearPlayers pushBack _x;
			};
		} forEach playableUnits;

		if (_time >= 1800) then {life_martialLaw_active = false;};
		if !(life_martialLaw_active) exitWith {
			[3,format["<t color='#0000FF'><t size='2'><t align='center'>Martial Law</t></t></t><br/>Citizens of %1, the unrest in town has been settled and Martial Law has been lifted! It is now safe to resume normal activities.",(_this select 2)],false,[]] remoteExec ["OEC_fnc_broadcast",_nearPlayers,false];
			[0,format["Martial Law has been lifted for the city of %1.",(_this select 2)]] remoteExec ["OEC_fnc_broadcast",-2,false];
			deleteMarker "m_law_srv";
			life_martialLaw_time = serverTime + 1800;
			life_martialLaw_pv = [false,""];
			publicVariable "life_martialLaw_pv";
		};
		if (_time isEqualTo 0) then {
			[3,format["<t color='#FF0000'><t size='2'><t align='center'>Martial Law</t></t></t><br/><br/>Martial Law has been declared in the city of %1.",(_this select 2)]] remoteExec ["OEC_fnc_broadcast",-2,false];
			playSound3D ["A3\data_f_curator\sound\cfgsounds\air_raid.wss",objNull,false,(_this select 1),5,1.2,(_this select 0)];
		};
		if (_time in [0,300,600,900,1200,1500,1800]) then {
			[3,format["<t color='#FF0000'><t size='2'><t align='center'>Martial Law</t></t></t><br/>Citizens of %1, Martial Law has been declared by the APD! If you do not wish to be fired upon by Police, leave the city or stay indoors with weapons holstered! This can last for up to 30 minutes! If you decide to remain inside city limits you will be notified when it is safe to return to normal activities.",(_this select 2)],false,[]] remoteExec ["OEC_fnc_broadcast",_nearPlayers,false];
			playSound3D ["A3\data_f_curator\sound\cfgsounds\air_raid.wss",objNull,false,(_this select 1),5,1.2,(_this select 0)];
		};

		uiSleep 30;
		_time = _time + 30;
	};
};