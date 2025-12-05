switch(_this select 0) do {
	case 0: {
		"Art_1" setMarkerColor "colorOPFOR";
		"Art_2" setMarkerColor "colorOPFOR";
		"Art_3" setMarkerColor "colorOPFOR";
		[
			["event","Art Gallery Robbery"],
			["player",name (_this select 1)],
			["player_id",getPlayerUID (_this select 1)]
		] call OES_fnc_logIt;
		if(_this select 2 == 0) then {
			gallery_siren setVariable["bombtime",time+300];
		} else {
			gallery_siren setVariable["bombtime",time+420];
		};
		(_this select 1) spawn{
			uiSleep 15;
			while{oev_artGallery} do {
				if(owner _this == 0) exitWith {
					oev_artGallery = false;
					publicVariable "oev_artGallery";
					gallery_siren setVariable ["bombtime",0];
				};
				uiSleep 30;
			};
			uiSleep 255;
			"Art_1" setMarkerColor "ColorCIV";
			"Art_2" setMarkerColor "ColorCIV";
			"Art_3" setMarkerColor "ColorCIV";
		};
	};
	case 1: {
		[] spawn{
			uiSleep 300;
			"Art_1" setMarkerColor "ColorCIV";
			"Art_2" setMarkerColor "ColorCIV";
			"Art_3" setMarkerColor "ColorCIV";
		};
		[
			["event","Painting Stolen"],
			["size",(_this select 4)],
			["player",getPlayerUID (_this select 3)],
			["player_id",name (_this select 3)]
		] call OES_fnc_logIt;
		[_this select 1, _this select 2] spawn{
			uiSleep 3600;
			(_this select 0) setObjectTextureGlobal[0,_this select 1];
			(_this select 0) setVariable["cooldown",false,true];
		};
		gallery_siren setVariable ["bombtime",0];
		"ArtNPCMAP_1" setMarkerType "mil_triangle";
		"ArtNPCMAP_2" setMarkerType "mil_triangle";
		"ArtNPCMAP_3" setMarkerType "mil_triangle";
	};
};
