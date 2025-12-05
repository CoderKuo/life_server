//	File: fn_handleAntiAir.sqf
//	Author: Poseidon
//	Reworked: Jesse "tkcjesse" Schultz
//	Description: Does what it do.

params [
	["_object",objNull,[objNull]],
	["_mode",0,[0]]
];
private _endTime = time + (60 * 3);

if(isNull _object) exitWith {};
if (_mode isEqualTo 0) exitWith {};

//civilian
if (_mode isEqualTo 1) then {
	_object setVariable ["virus","CIV",true];

	if(_object isEqualTo bwAntiAir) then {
		[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Blackwater Armoury anti air system is being hacked!",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
		"marker_143" setMarkerColor "ColorOPFOR";
		"marker_1235" setMarkerColor "ColorOPFOR";
		"marker_143" setMarkerText " Anti-Air - Infected";
	} else {
		if(_object isEqualTo jailAntiAir) then {
			[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Altis Penitentiary anti air system is being hacked!",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			"marker_103" setMarkerColor "ColorOPFOR";
			"marker_1236" setMarkerColor "ColorOPFOR";
			"marker_103" setMarkerText " Anti-Air - Infected";
		} else {
			[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Federal Reserve anti air system is being hacked!",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			"marker_115" setMarkerColor "ColorOPFOR";
			"marker_1234" setMarkerColor "ColorOPFOR";
			"marker_115" setMarkerText " Anti-Air - Infected";
		};
	};

	waitUntil {time > _endTime || !((_object getVariable ["virus",""]) isEqualTo "CIV")};
	if !((_object getVariable ["virus",""]) isEqualTo "CIV") exitWith {};

	if ((_object getVariable ["virus",""]) isEqualTo "CIV") then {
		if(_object isEqualTo bwAntiAir) then {
			[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Blackwater Armoury anti air system has been corrupted!",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			"marker_143" setMarkerColor "ColorOPFOR";
			"marker_143" setMarkerText " Anti-Air - OFFLINE";
		} else {
			if(_object isEqualTo jailAntiAir) then {
				[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Altis Penitentiary anti air system has been corrupted!",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
				"marker_103" setMarkerColor "ColorOPFOR";
				"marker_103" setMarkerText " Anti-Air - OFFLINE";
			} else {
				[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Federal Reserve anti air system has been corrupted!",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
				"marker_115" setMarkerColor "ColorOPFOR";
				"marker_115" setMarkerText " Anti-Air - OFFLINE";
			};
		};

		_object setVariable ["active",false,true];
		_object setVariable ["virus","",true];
	};
};

//west
if (_mode isEqualTo 2) then {
	_object setVariable ["virus","APD",true];

	if(_object isEqualTo bwAntiAir) then {
		[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Blackwater Armoury anti air system is being repaired.",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
		"marker_143" setMarkerColor "ColorOPFOR";
		"marker_143" setMarkerText " Anti-Air - Repairing";
	} else {
		if(_object isEqualTo jailAntiAir) then {
			[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Altis Penitentiary anti air system is being repaired.",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			"marker_103" setMarkerColor "ColorOPFOR";
			"marker_103" setMarkerText " Anti-Air - Repairing";
		} else {
			[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Federal Reserve anti air system is being repaired.",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			"marker_115" setMarkerColor "ColorOPFOR";
			"marker_115" setMarkerText " Anti-Air - Repairing";
		};
	};

	waitUntil {time > _endTime || !((_object getVariable ["virus",""]) isEqualTo "APD")};
	if !((_object getVariable ["virus",""]) isEqualTo "APD") exitWith {};

	if ((_object getVariable ["virus",""]) isEqualTo "APD") then {
		if(_object isEqualTo bwAntiAir) then {
			[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Blackwater Armoury anti air system has been repaired!",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			"marker_143" setMarkerColor "ColorWEST";
			"marker_1235" setMarkerColor "ColorOrange";
			"marker_143" setMarkerText " Anti-Air - ONLINE";
		} else {
			if(_object isEqualTo jailAntiAir) then {
				[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Altis Penitentiary anti air system has been repaired!",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
				"marker_103" setMarkerColor "ColorWEST";
				"marker_1236" setMarkerColor "ColorWEST";
				"marker_103" setMarkerText " Anti-Air - ONLINE";
			} else {
				[[3,"<t color='#ff2222'><t size='2.2'><t align='center'>A.A. ALERT<br/><t color='#FFC966'><t align='center'><t size='1.2'>The Federal Reserve anti air system has been repaired!",false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
				"marker_115" setMarkerColor "ColorWEST";
				"marker_1234" setMarkerColor "ColorYellow";
				"marker_115" setMarkerText " Anti-Air - ONLINE";
			};
		};

		_object setVariable ["active",true,true];
		_object setVariable ["virus","",true];
	};
};