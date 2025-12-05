//	File: fn_initHC.sqf
//	Author: Poseidon
//	Description: Wait's until the headless client connects, then sets it to active. If it disconnects it instantly detects it and sets to inactive

//while{true} do {
//	waitUntil{life_HC_isActive};
//	uiSleep 3;
//	/*[] spawn{
//		while{life_HC_isActive} do {
//			uiSleep 300;
//			if(!life_HC_isActive) exitWith {};
//			{
//				if(((owner _x) != (owner HeadlessClient)) && (!isPlayer _x)) then {
//					if(!((typeOf _x) in ["ModuleCurator_F","Logic"])) then {
//						_x setOwner (owner HeadlessClient);
//					};
//				};
//			}foreach allMissionObjects "";
//	};*/
//	waitUntil{!isPlayer HeadlessClient};
//	life_HC_isActive = false;
//};

HC_UID = nil;

// JIP integration of an hc
"life_HC_isActive" addPublicVariableEventHandler {
    if (_this select 1) then {
        HC_UID = getPlayerUID HeadlessClient;
        HC_ID = owner HeadlessClient;
        publicVariable "HC_ID";
        //HC_ID publicVariableClient "serv_sv_use";
        //cleanupFSM setFSMVariable ["stopfsm",true];
        //terminate cleanup;
        //terminate aiSpawn;
        //[true] call TON_fnc_transferOwnership;
        //HC_ID publicVariableClient "animals";
        diag_log "Headless client is connected and ready to work!";
    };
};

HC_DC = ["HC_Disconnected", "onPlayerDisconnected", {
	if (!isNil "HC_UID" && {_uid isEqualTo HC_UID}) then {
		life_HC_isActive = false;
		publicVariable "life_HC_isActive";
		HC_ID = false;
		publicVariable "HC_ID";
		//cleanup = [] spawn TON_fnc_cleanup;
		//cleanupFSM = [] execFSM "\life_server\FSM\cleanup.fsm";
		//[false] call TON_fnc_transferOwnership;
		//aiSpawn = ["hunting_zone",30] spawn TON_fnc_huntingZone;
		diag_log "Headless client disconnected! Broadcasted the vars!";
		diag_log "Ready for receiving queries on the server machine.";
	};
}] call BIS_fnc_addStackedEventHandler;
