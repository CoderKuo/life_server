// File: fn_createAdminVeh.sqf
// Author: Jesse "tkcjesse" Schultz
// Creates a simple admin veh server side
params [
	["_className","",[""]],
	["_position",[],[[]]]
];

if (_className isEqualTo "" || {_position isEqualTo []}) exitWith {};
if (diag_fps < 18) exitWith {
	if !(remoteExecutedOwner isEqualTo 0) then {
		[1,"Your vehicle could not be created due to server FPS being under 18 FPS!"] remoteExecCall ["OEC_fnc_broadcast",remoteExecutedOwner];
	};
};

private _vehicle = _className createVehicle _position;

if !(_className isEqualTo "C_Plane_Civil_01_racing_F") then {
	[_vehicle] call OEC_fnc_clearVehicleAmmo;
} else {
	[_vehicle, "civ", true] call OEC_fnc_clearVehicleAmmo;
};

_vehicle setVariable ["eventVehicle",true,true];
//_vehicle addEventHandler ["Killed","[_this select 0] spawn OES_fnc_vehicleDead"];
clearWeaponCargo _vehicle;
clearMagazineCargo _vehicle;

life_serv_vehicles pushBack _vehicle;

if(_vehicle isKindOf "Air") then {
	_vehicle addEventHandler ["RopeAttach", {
		if !(owner (currentPilot (_this select 0)) isEqualTo owner (_this select 2)) then {
			(_this select 2) setOwner (owner (currentPilot (_this select 0)));
		};
		if (count crew (_this select 2) > 0) then {
			hint "Warning! Slinging vehicles with players in them is unstable and the rope may break!";
			{
				['Warning! Slinging vehicles with players in them is unstable and the rope may break!'] remoteExec['hint',_x];
			} forEach (crew (_this select 2));
			[(_this select 2),(_this select 0),owner (currentPilot (_this select 0))] spawn{
				waitUntil{(count crew (_this select 0) isEqualTo 0) && (owner (currentPilot (_this select 1)) isEqualTo (_this select 2))};
				(_this select 0) setOwner (_this select 2);
			};
		};
	}];
};

for [{_i = 0}, {_i < 5}, {_i = _i + 1}] do {
	_vehicle setObjectTextureGlobal [_i,'#(argb,8,8,3)color(0,0,0,1)']
};

if !(remoteExecutedOwner isEqualTo 0) then {
	[1,"Your vehicle has been spawned!"] remoteExecCall ["OEC_fnc_broadcast",remoteExecutedOwner];
};