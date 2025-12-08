//  File: fn_initTerritories
//  Description: Initializes and manages the gang territories
//  Modified: Migrated to PostgreSQL Mapper layer

private["_territory","_gangID","_gangName","_captureProgress","_locID","_flagObject","_markerName","_capturableTerritories","_territoryData","_position","_alreadyUsedLocations","_markerCustomName","_supportedLocations","_supportedTerritories"];

// Wait for database functions to load
"[initTerritories] Waiting for database functions..." call OES_fnc_diagLog;
waitUntil {uiSleep 0.1; !isNil "DB_fnc_dbExecute" && !isNil "DB_fnc_gangMapper"};
"[initTerritories] DB functions loaded" call OES_fnc_diagLog;

"------------- Territories Query Request -------------" call OES_fnc_diagLog;

// Use Mapper to get territory data
private _territories = ["getterritories", [str olympus_server]] call DB_fnc_gangMapper;

format["[initTerritories] Territories Raw Result: %1 (type: %2)", _territories, typeName _territories] call OES_fnc_diagLog;

// Validate result
if (isNil "_territories" || {!(_territories isEqualType [])} || {count _territories == 0}) then {
	_territories = [];
	"[initTerritories] Territory data is empty or invalid, using empty array" call OES_fnc_diagLog;
};

format["Territories Result: %1",_territories] call OES_fnc_diagLog;
"-----------------------------------------------------" call OES_fnc_diagLog;

_supportedTerritories = ["Meth","Mushroom","Moonshine","Arms"];
_alreadyUsedLocations = [];
_supportedLocations = [
	[14273.0,13030.6,0], // Mushroom Island Penn - cartel_5, cartel_6
	//[23037.8,7244.7,0], // Pyrgos - cartel_11, cartel_12
	[12077,10492,0] // og heroin - cartel_8, cartel_7
];

// Church - [8923.65,7478.38,0] - cartel_3, cartel_4
// Castle - [11207.3,8697.7,0.293] - cartel_1, cartel_2

private _randomPersistent = selectRandom ["Meth","Moonshine","Mushroom"];

{
	if (isNil "_x" || {!(_x isEqualType [])} || {count _x < 4}) then { continue; };
	_territory = _x select 0;
	_gangID = _x select 1;
	_gangName = _x select 2;
	_captureProgress = _x select 3;
	_position = [];

	if(_territory in _supportedTerritories) then {
		_flagObject = call compile format["%1_flag",_territory];
	} else {
		_flagObject = nil;
	};

	if(!isNil "_flagObject") then {
		if(!isNull _flagObject) then {
			while {true} do {
				private _exit = false;
				if (_territory == "Arms") then {
					_position = [11207.3,8697.7,0.293];
					_exit = true;
				} else {
					if (_territory == _randomPersistent) then {
						_position = [8923.65,7478.38,0];
						_exit = true;
					} else {
						_position = selectRandom _supportedLocations;

						if (!(_position in _alreadyUsedLocations)) exitWith {
							_alreadyUsedLocations pushBack _position;
							_exit = true;
						};
					};
				};
				if (_exit) exitWith {};
			};
			_flagObject setPos _position;
			_locID = switch (_position) do {
				case [8923.65,7478.38,0]: {1};
				case [11207.3,8697.7,0.293]: {2};
				case (_supportedLocations select 0): {3};
				case (_supportedLocations select 1): {4};
				//case [23037.8,7244.7,0]: {5};
				default {-1};
			};
			_flagObject setVariable ["capture_data",[_gangID,_gangName,(_captureProgress / 100)],true];
			_flagObject setVariable ["cartel_num",_locID,true];
			_markerName = format["%1_cartel",_territory];
			_markerName setMarkerPos [_position select 0,_position select 1];
			_markerCustomName = "";
			_markerCustomName = switch(_territory) do {
				case "Meth": {"Meth and Weed";};
				case "Moonshine": {"Moonshine and Heroin";};
				case "Mushroom": {"Mushroom and Cocaine";};
				case "Arms": {"Arms Dealer";};
				default {"Ur Mums"};
			};

			_markerName setMarkerText format["%1 (%2)",_markerCustomName,_gangName];

			//Circle around cartels. Marker Name Ex: arms_cartelCircle
			_zoneMarkerName = format["%1_cartelCircle",_territory];
			_zoneMarker = createMarker [_zoneMarkerName,[_position select 0,_position select 1]];
			_zoneMarker setMarkerShape "ELLIPSE";
			_zoneMarker setMarkerBrush "Border";
			_zoneMarker setMarkerColor "colorOPFOR";
			_zoneMarker setMarkerSize [95,95];
		};
	};
} forEach _territories;

//update data in database
while{true} do {
	uiSleep (60 * 5);
	//_capturableTerritories = ["Weed","Heroin","Cocaine","Meth","Mushroom","Moonshine","Frog"];

	{
		_territory = _x;
		_flagObject = call compile format["%1_flag",_territory];
		_territoryData = _flagObject getVariable["capture_data",[0,"Neutral",0.5]];

		// Use Mapper to update territory
		["updateterritory", [str (_territoryData select 0), _territoryData select 1, str (round((_territoryData select 2) * 100)), str olympus_server, _territory]] call DB_fnc_gangMapper;
	} forEach _supportedTerritories;
};
