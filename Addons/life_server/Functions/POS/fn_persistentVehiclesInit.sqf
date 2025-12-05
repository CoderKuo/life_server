//	Author: Poseidon
//	Description: Starts the persistent vehicle system

[] spawn OES_fnc_persistentVehiclesLoad;
[] spawn OES_fnc_persistentGangVehiclesLoad;

[] spawn{
	waitUntil{uiSleep 0.1; !isNil "serverStartTime" && !isNil "serverCycleLength"};
	waitUntil{uiSleep 5; serverTime >= ((serverStartTime + serverCycleLength) - 25)};//Wait till 15 seconds before restart
	[] call OES_fnc_persistentVehiclesSave;
	[] call OES_fnc_persistentGangVehiclesSave;
};