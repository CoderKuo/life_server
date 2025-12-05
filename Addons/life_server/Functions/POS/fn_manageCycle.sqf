//  File: fn_manageCycle.sqf
//	Author: Poseidon
//	Description: Adjusts the servers restart cycle/method/message
params [
	["_mode",-1,[0]],
	["_player",objNull,[objNull]]
];
if(_mode isEqualTo -1 || isNull _player) exitWith {};
_time = "";

["666 -LOGGED- %1 (%2) 将服务器循环模式设置为 %3",name _player,getPlayerUID _player,_mode] call OES_fnc_diagLog;

switch(_mode) do {
	case 0: {//硬重新启动，以便进行更新
		serverHardReboot = true;
		serverUpdate = true;
		serv_mArmaReboot = 2;
		[format['{"event":"调整重启模式", "mode":"hard reboot w/ update", "player":"%1", "player_id":"%2"}',name _player,getPlayerUID _player]] call OES_fnc_logIt;
	};

	case 1: {//Hard reboot, no update
		serverUpdate = false;
		serverHardReboot = true;
		serv_mArmaReboot = 1;
		[format['{"event":"调整重启模式", "mode":"hard reboot no update", "player":"%1", "player_id":"%2"}',name _player,getPlayerUID _player]] call OES_fnc_logIt;
	};

	case 2: {//Soft reboot
		serverUpdate = false;
		serverHardReboot = false;
		[format['{"event":"调整重启模式", "mode":"soft reboot", "player":"%1", "player_id":"%2"}',name _player,getPlayerUID _player]] call OES_fnc_logIt;
	};

	case 3: {//Restarts server in 60 minutes
		serverCycleLength = (((1 * 60) * 60) + 15) + (serverTime - serverStartTime);
		[[3,format["<t color='#ff8000'><t size='2'><t align='center'>服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>管理员已调整重新启动时间。新的重新启动时间为60分钟.", round((serverCycleLength - serverStartTime) / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
		sleep 10;
		publicVariable "serverCycleLength";//Broadcast length of time till next restart
		serv_mArmaCycle = serverCycleLength;
		_time = "60";
	};

	case 4: {//Restarts server in 30 minutes
		serverCycleLength = (((0.5 * 60) * 60) + 15) + (serverTime - serverStartTime);
		[[3,format["<t color='#ff8000'><t size='2'><t align='center'>服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>管理员已调整重新启动时间。新的重新启动时间为30分钟.", round((serverCycleLength - serverStartTime) / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
		sleep 10;
		publicVariable "serverCycleLength";//Broadcast length of time till next restart
		serv_mArmaCycle = serverCycleLength;
		_time = "30";
	};

	case 5: {//Restarts server in 15 minutes
		serverCycleLength = (((0.25 * 60) * 60) + 15) + (serverTime - serverStartTime);
		[[3,format["<t color='#ff0000'><t size='2'><t align='center'>服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>管理员已调整重新启动时间。新的重启时间为15分钟.", round((serverCycleLength - serverStartTime) / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
		sleep 10;
		publicVariable "serverCycleLength";//Broadcast length of time till next restart
		serv_mArmaCycle = serverCycleLength;
		_time = "15";
	};

	case 6: {//Restarts server in 1 minute
		serverCycleLength = (((0.01666 * 60) * 60) + 15) + (serverTime - serverStartTime);
		[[3,format["<t color='#ff0000'><t size='2'><t align='center'>服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>管理员已调整重新启动时间。新的重新启动时间为1分钟!", round((serverCycleLength - serverStartTime) / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
		sleep 10;
		publicVariable "serverCycleLength";//Broadcast length of time till next restart
		serv_mArmaCycle = serverCycleLength;
		_time = "1";
	};

	case 8: {//Restarts server in 120 minutes
		serverCycleLength = (((2 * 60) * 60) + 15) + (serverTime - serverStartTime);
		[[3,format["<t color='#ff0000'><t size='2'><t align='center'>服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>管理员已调整重新启动时间。新的重启时间为120分钟!", round((serverCycleLength - serverStartTime) / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
		sleep 10;
		publicVariable "serverCycleLength";//下次重新启动前的广播时间长度
		serv_mArmaCycle = serverCycleLength;
		_time = "120";
	};

	case 7: {//Force saves all vehicles
		[] call OES_fnc_persistentVehiclesSave;
		[] call OES_fnc_persistentGangVehiclesSave;
		[format['{"event":"强制所有车辆", "player":"%1", "player_id":"%2"}',name _player,getPlayerUID _player]] call OES_fnc_logIt;
	};
};
if(_time != "") then {
	[format['{"event":"调整重启时间", "time":"%1", "player":"%2", "player_id":"%3"}',_time,name _player,getPlayerUID _player]] call OES_fnc_logIt;
};
