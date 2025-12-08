//	Author: Poseidon
//	Description: Handles things for restarting server and stuff
//  Modified: 迁移到 PostgreSQL Mapper 层

private["_cycleLength","_startTime","_notificationTimes","_notificationServerTime","_time"];
sleep 1;
waitUntil{uiSleep 0.5; serverTime > 0 && serverTime < 259200};//检查以确保serverTime变量没有被破坏
_cycleLength = ((6 * 60) * 60) - 360; //服务器在重新启动前启动的时间长度（以秒为单位）--对于mArma，也可以在init中进行调整
_offset = getNumber(configFile >> "ServerCycle" >> (format ["server%1",olympus_server]) >> "offset");
//_cycleLength = ([_query,2] call OES_fnc_asyncCall select 0) * 60; //获取服务器重新启动前的时间（秒）
_startTime = serverTime; //当前服务器时间，因为服务器时间在重新加载任务后不会重置
serv_mArmaTime = _startTime;  //----在初始化中也为mArma进行调整
serv_timeFucked = false;
life_martialLaw_active = false; //找到了一个具有现有serverTime wait的循环，并转到此处..：D
life_martialLaw_time = serverTime; //同上.
_notificationTimes = [3600,1800,900,300,120]; //显示重新启动通知前的时间（以秒为单位）.

serverStartTime = _startTime;
publicVariable "serverStartTime";//广播服务器开始时间为Y菜单时间，直到重新开始计算
serverCycleLength = _cycleLength;
publicVariable "serverCycleLength";//下次重新启动前的广播时间长度
serverHardReboot = false;
serverUpdate = false;

_hour = getNumber(configFile >> "ServerCycle" >> (format ["server%1",olympus_server]) >> "hour");
// 使用 miscMapper 检查是否为硬重启
private _isHardResult = ["checkhardreset", [str _cycleLength, str _hour]] call DB_fnc_miscMapper;
_isHard = if (isNil "_isHardResult" || {count _isHardResult == 0}) then { 0 } else { _isHardResult select 0 };

_isLock = 0;
if(olympus_server isEqualTo 2) then {
	// 使用 miscMapper 检查时间范围
	private _isLockResult = ["checktimerange", [str _hour, str (_hour+12)]] call DB_fnc_miscMapper;
	_isLock = if (isNil "_isLockResult" || {count _isLockResult == 0}) then { 0 } else { _isLockResult select 0 };
	if(_isLock isEqualTo 0) then {
		"fdFPXGkYrxwdaxf5kiE" serverCommand "#lock";
		[] spawn{
			while {true} do {
				uiSleep random(30);
				[3,"<t color='#ff2222'><t size='2.2'><t align='center'>WARNING!<br/><t color='#FFC966'><t align='center'><t size='1.2'>您在非高峰时间使用服务器2。服务器会在1分钟内踢你。请现在移到服务器1。非常感谢。.",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
				uiSleep 90;
				[3,"<t color='#ff2222'><t size='2.2'><t align='center'>WARNING!<br/><t color='#FFC966'><t align='center'><t size='1.2'>You are on server 2 during non-peak hours. The server will be kicking now. Please move to server 1 at this time. Thank you.",false,[]] remoteExec ["OEC_fnc_broadcast",-2,false];
				uiSleep random(15);

				{
					"fdFPXGkYrxwdaxf5kiE" serverCommand format ["#kick %1", getPlayerUID _x];
					uiSleep 0.2;
				} forEach (allPlayers - entities "HeadlessClient_F");
				uiSleep (2 * 60);
			};
		};
	};
};


if(_isHard isEqualTo 1) then {
	serverHardReboot = false;
	serv_mArmaReboot = 1;
}else{
	serverHardReboot = false;
};

[] spawn{
	waitUntil{!isNil "serverStartTime" && !isNil "serverCycleLength"};
	waitUntil{uiSleep 10; serverTime >= ((serverStartTime + serverCycleLength) - 150)};//Wait till 150 seconds before restart
	[] spawn OES_fnc_saveAllHouses;
};

[] spawn{
	waitUntil{uiSleep 10; serverTime >= (serverStartTime + serverCycleLength)};//Wait for server time to meet the cycleLength requirement
	waitUntil{olympusVehiclesSaved};
	waitUntil{olympusGangVehiclesSaved};
	if(serverHardReboot) then {
		sleep 5;
		"fdFPXGkYrxwdaxf5kiE" serverCommand "#restart";
	}else{
		"fdFPXGkYrxwdaxf5kiE" serverCommand "#restart";
	};
};

[] spawn{
	waitUntil{uiSleep 10; ((serverStartTime + serverCycleLength) - servertime) < -120};//Fail safe incase server dont restart for some reason, if time is negative 2 minutes restart
	if(serverHardReboot) then {
		sleep 5;
		"fdFPXGkYrxwdaxf5kiE" serverCommand "#restart";
	}else{
		"fdFPXGkYrxwdaxf5kiE" serverCommand "#restart";
	};
};


while{true} do {
	{
		_notificationServerTime = (serverStartTime + serverCycleLength) - _x;

		if(serverTime < _notificationServerTime) then {
			waitUntil{uiSleep 10; serverTime > _notificationServerTime || serverCycleLength != _cycleLength};
			if(serverCycleLength != _cycleLength) exitWith {};//Cycle changed, exit so new notification loop can be started

			if(serverHardReboot) then {
				if(serverUpdate) then {
					[[3,format["<t color='#ff0000'><t size='2'><t align='center'>Server Notice<br/><t color='#eeeeff'><t align='center'><t size='1.2'>服务器将在%1分钟后重新启动. <br /><br /><t color='#bbbbff'><t size='1.1'>一个Altis生命更新也将在重启时推出.", (_x / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
					sleep 0.3;
					[[3,format["<t color='#ff8000'><t size='2'><t align='center'>Server Notice<br/><t color='#eeeeff'><t align='center'><t size='1.2'>服务器将在%1分钟后重新启动. <br /><br /><t color='#bbbbff'><t size='1.1'>一个Altis生命更新也将在重启时推出.", (_x / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
					sleep 0.3;
					[[3,format["<t color='#ff0000'><t size='2'><t align='center'>Server Notice<br/><t color='#eeeeff'><t align='center'><t size='1.2'>服务器将在%1分钟后重新启动. <br /><br /><t color='#bbbbff'><t size='1.1'>一个Altis生命更新也将在重启时推出.", (_x / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
				}else{
					[[3,format["<t color='#ff0000'><t size='2'><t align='center'>Server Notice<br/><t color='#eeeeff'><t align='center'><t size='1.2'>服务器将在%1分钟后重新启动.", (_x / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
					sleep 0.3;
					[[3,format["<t color='#ff8000'><t size='2'><t align='center'>Server Notice<br/><t color='#eeeeff'><t align='center'><t size='1.2'>服务器将在%1分钟后重新启动.", (_x / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
					sleep 0.3;
					[[3,format["<t color='#ff0000'><t size='2'><t align='center'>Server Notice<br/><t color='#eeeeff'><t align='center'><t size='1.2'>服务器将在%1分钟后重新启动.", (_x / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
				};
			}else{
				[[3,format["<t color='#ff0000'><t size='2'><t align='center'>世纪天城服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>软服务器重新启动将在%1分钟后发生. <br /><br /><t color='#bbffbb'><t size='1.1'>当任务重新加载时，软重启使玩家返回大厅.", (_x / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
				sleep 0.3;
				[[3,format["<t color='#ff8000'><t size='2'><t align='center'>世纪天城服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>软服务器重新启动将在%1分钟后发生. <br /><br /><t color='#bbffbb'><t size='1.1'>当任务重新加载时，软重启使玩家返回大厅.", (_x / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
				sleep 0.3;
				[[3,format["<t color='#ff0000'><t size='2'><t align='center'>世纪天城服务器通知<br/><t color='#eeeeff'><t align='center'><t size='1.2'>软服务器重新启动将在%1分钟后发生. <br /><br /><t color='#bbffbb'><t size='1.1'>当任务重新加载时，软重启使玩家返回大厅.", (_x / 60)],false,[]],"OEC_fnc_broadcast",-2,false] spawn OEC_fnc_MP;
			};
		};

		if(serverCycleLength != _cycleLength) exitWith {};
	}foreach _notificationTimes;

	if(serverCycleLength == _cycleLength) exitWith {};//Server cycle has not been modified since the last time it was set, server restart is ready to happen
	if(serverCycleLength != _cycleLength) then {_cycleLength = serverCycleLength;};//Server cycle was modified, the notification loop was exitied, start it over again.
};
