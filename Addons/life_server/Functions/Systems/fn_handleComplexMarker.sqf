//	File: fn_handleComplexMarker.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Changes the color/text/etc of a map marker server side to update for all current & JIP players.

params [
	["_mode",0,[0]],
	["_vault",objNull,[objNull]]
];

switch (_mode) do {
	case 1: {
		//Federal - Active
		"fed_reserve_1" setMarkerColor "ColorOPFOR";
		"fed_reserve_1" setMarkerText "Federal Reserve - Robbery in Progress!";
		"marker_254" setMarkerColor "ColorOPFOR";
	};

	case 2: {
		//Federal - Not Active
		"fed_reserve_1" setMarkerColor "ColorUNKNOWN";
		"fed_reserve_1" setMarkerText "Federal Reserve";
		"marker_254" setMarkerColor "ColorUNKNOWN";
	};

	case 3: {
		//Prison Anti-Air Online
		"marker_103" setMarkerColor "ColorWEST";
		"marker_103" setMarkerText " Anti-Air - ONLINE";
	};

	case 4: {
		//Prison - Not Active
		"marker_247" setMarkerColor "ColorWEST";
		"jail_marker" setMarkerColor "ColorWEST";
		"jail_marker" setMarkerText "Altis Penitentiary";
	};

	case 5: {
		//Prison - Active
		"marker_247" setMarkerColor "ColorOPFOR";
		"jail_marker" setMarkerColor "ColorOPFOR";
		"jail_marker" setMarkerText "Altis Penitentiary - Breakout in Progress!";
	};

	case 6: {
		//Federal Anti-Air Online
		"marker_115" setMarkerColor "ColorWEST";
		"marker_115" setMarkerText " Anti-Air - ONLINE";
	};

	case 7: {
		//Blackwater - Anti-Air Online
		"marker_143" setMarkerColor "ColorOrange";
		"marker_143" setMarkerText " Anti-Air - ONLINE";
	};

	case 8: {
		//Blackwater - Active
		"marker_259" setMarkerColor "ColorOPFOR";
		"bw_marker" setMarkerColor "ColorOPFOR";
		"bw_marker" setMarkerText "Blackwater Armoury - Robbery in Progress!";
	};

	case 9: {
		//Blackwater - Not Active
		"marker_259" setMarkerColor "ColorOrange";
		"bw_marker" setMarkerColor "ColorOrange";
		"bw_marker" setMarkerText "Blackwater Armoury";
	};

	case 10: {
		"gen_marker_1" setMarkerText "Blackwater Generator - On";
		"gen_marker_1" setMarkerColor "ColorOrange";
		"fed_marker" setMarkerText "Government Facility";
		"fed_marker" setMarkerColor "ColorOrange";
		"fed_zone" setMarkerColor "ColorOrange";
	};

	case 11: {
		"gen_marker_2" setMarkerText "Fed Reserve Generator - On";
		"gen_marker_2" setMarkerColor "ColorOrange";
		"fed_marker" setMarkerText "Government Facility";
		"fed_marker" setMarkerColor "ColorOrange";
		"fed_zone" setMarkerColor "ColorOrange";
	};

	case 12: {
		//Bank - Active
		"bank_marker" setMarkerColor "ColorOPFOR";
		"bank_marker" setMarkerText "Bank of Altis - Robbery in Progress!";
		"bank_hatch" setMarkerColor "ColorOPFOR";
		"bank_border" setMarkerColor "ColorOPFOR";

		_markName = switch (_vault) do {
			case (altis_bank): {"vaultMarker"};
			case (altis_bank_1): {"vaultMarker1"};
			case (altis_bank_2): {"vaultMarker2"};
			default {"vaultMarker"};
		};

		createMarker [_markName, _vault];
		_markName setMarkerType "mil_triangle";
		_markName setMarkerColor "ColorRed";
		_markName setMarkerSize [1, 1];
	};

	case 13: {
		//Bank - Not Active
		if !(altis_bank getVariable ["chargeplaced", false] || altis_bank_1 getVariable ["chargeplaced", false] || altis_bank_2 getVariable ["chargeplaced", false]) then {
			if !(altis_bank getVariable ["safe_open", false] || altis_bank_1 getVariable ["safe_open", false] || altis_bank_2 getVariable ["safe_open", false]) then {
				"bank_marker" setMarkerColor "ColorIndependent";
				"bank_marker" setMarkerText "Bank of Altis";
				"bank_hatch" setMarkerColor "ColorIndependent";
				"bank_border" setMarkerColor "ColorIndependent";
			};
		};

		switch (_vault) do {
			case (altis_bank): {deleteMarker "vaultMarker";};
			case (altis_bank_1): {deleteMarker "vaultMarker1";};
			case (altis_bank_2): {deleteMarker "vaultMarker2";};
		};
	};

	default {};
};
