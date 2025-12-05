/*
ShongY制作日志系统
*/
params [
["_PID","",[""]],
["_LOGTitle","",[""]],
["_LOG","",[""]]
];
_query = format ["INSERT INTO playerlogs (playerID,logTitle,log) VALUES('%1','%2','%3')",_PID,_LOGTitle,_LOG];
[_query,1] call OES_fnc_asyncCall;

//[getPlayerUID player, "TEST-Log", format ["%1 hat die Log Funktion mit Params getestet!",name player]] remoteExec ["DB_fnc_AdvancedLog",2];