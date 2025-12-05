#include "macro.h"
//	File: initHC.sqf

DB_Async_Active = false;
DB_Async_ExtraLock = false;
_extDB_notLoaded = "";

diag_log "----------------------------------------------------------------------------------------------------";
diag_log "                                    Altis Life HC Initializing                                      ";
diag_log "----------------------------------------------------------------------------------------------------";

dbColumnGearCiv = "civ_gear";
dbColumnGearMed = "med_gear";
dbColumnGearCop = "cop_gear";
dbColumnPosition = "coordinates";
dbColumVehicle = "vehicles";
dbColumGangVehicle = "gangvehicles";

//[] spawn OES_fnc_initHC;
//[] execVM "\life_server\eventhandlers.sqf";

if (isNil {uiNamespace getVariable "life_sql_id"}) then {
	life_sql_id = round(random(9999));
	__CONST__(life_sql_id,life_sql_id);
	uiNamespace setVariable ["life_sql_id",life_sql_id];

	try {
		_result = "extDB3" callExtension "9:VERSION";
		if (_result isEqualTo "") then {throw "The server-side extension extDB was not loaded into the engine, report this to the server admin."};
		_result = "extDB3" callExtension format ["9:ADD_DATABASE:%1","Database2"];
		if !(_result isEqualTo "[1]") then {throw "extDB: Error with Database Connection 1. Contact an administrator."};
		_result = "extDB3" callExtension format ["9:ADD_DATABASE_PROTOCOL:Database2:SQL:%1:TEXT2",__GETC__(life_sql_id)];
		if !(_result isEqualTo "[1]") then {throw "extDB: Error with Database Connection 2. Contact an administrator."};
	} catch {
		diag_log _exception;
		_extDB_notLoaded = [true, _exception];
	};

	if (_extDB_notLoaded isEqualType []) exitWith {};
	"extDB3" callExtension "9:LOCK";
} else {
	life_sql_id = uiNamespace getVariable "life_sql_id";
	__CONST__(life_sql_id,life_sql_id);
};

if (_extDB_notLoaded isEqualType []) exitWith {};

enableEnvironment false;
enableEngineArtillery false;
enableCaustics false;
disableRemoteSensors true;

life_HC_isActive = true;
publicVariable "life_HC_isActive";

diag_log "----------------------------------------------------------------------------------------------------";
diag_log "                                     Altis Life HC Initialized                                      ";
diag_log "----------------------------------------------------------------------------------------------------";