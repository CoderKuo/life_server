// File: fn_runLottery.sqf
// Author: Fusah
// Description: Runs the lottery!

private _restartTime = round((serverCycleLength - (serverTime - serverStartTime)) / 60);
private _winner = [];
private _picked = false;
if (_restartTime < 35) exitWith {};
if (life_lotteryCooldown) exitWith {};
uiSleep floor random 5; //好吧，他妈的你不打算开始两个
if (life_runningLottery) exitWith {};

life_runningLottery = true;
publicVariable "life_runningLottery";

[3,"<t color='#ffdd00'><t size='2'><t align='center'>福利彩票<br/><t color='#eeeeff'><t align='center'><t size='1.2'>福利彩票开卖了，快到附近的加油站买一张碰碰运气吧！<br /><br /><t color='#ffdd00'><t size='1.1'>30分钟后开奖.",false,[],"life_lottery"] remoteExec ["OEC_fnc_broadcast",-2,false];

private _time = 1800; //30 Minutes
for "_i" from 0 to 1 step 0 do {
	if (_time <= 0) exitWith {};
	if (_time in [1500,1200,900,600,300,60]) then {
		[3,format["<t color='#ffdd00'><t size='2'><t align='center'>福利彩票<br/><t color='#eeeeff'><t align='center'><t size='1.2'>快到附近的加油站买一张福利彩票碰碰运气吧！ 本次的中奖者将在 %2 %3分钟后公布.<br /><br /><t color='#ffdd00'><t size='1.1'>奖池一共: $%1元",[((count life_lottery_list) * 50000) * .95] call OEC_fnc_numberText,_time/60,if (_time/60 isEqualTo 1) then {""} else {"s"}],false,[],"life_lottery"] remoteExec ["OEC_fnc_broadcast",-2,false];
	};
	_time = _time - 60;
	uiSleep 60;
};

//lets go COMPLETLY RANDOM cough cough
for "_e" from 0 to 5 do {
	_winner = life_lottery_list select (floor random (count life_lottery_list));
	if ([_winner select 1] call OEC_fnc_isUIDActive) exitWith {_picked = true};
	uiSleep .1;
};
//welp lets jst get the first person who is in the game and reward them for atleast being fucking on..
if !(_picked) then {
	{
		if ([_x select 1] call OEC_fnc_isUIDActive) exitWith {_winner = life_lottery_list select _forEachIndex;_picked = true};
		} forEach life_lottery_list;
};
//oh cmon its like free money why would u fuckin leave
if !(_picked) then {[3,"<t color='#ffdd00'><t size='2'><t align='center'>福利彩票<br/><t color='#eeeeff'><t align='center'><t size='1.2'>中奖者下线了，本期彩票没有中奖的人!<br /><br /><t color='#ffdd00'><t size='1.1'>彩票机构正在调整,稍后将会推出下一期的彩票.",false,[],"life_lottery"] remoteExec ["OEC_fnc_broadcast",-2,false]};

//its like i look at my code and i....
if (_picked) then {
	private _playerNetID = [_winner select 1] call OES_fnc_getPlayer;
	private _winnings = ((count life_lottery_list) * 50000) * .95; // 5%的税
	if !(_playerNetID isEqualTo 0) then {
		[1,_winnings] remoteExec ["OEC_fnc_payPlayer",_playerNetID,false];
		format ["-福利彩票- %1 (%2) 是本期彩票的赢家 奖金总共: %3元!",_winner select 0,_winner select 1,[_winnings] call OEC_fnc_numberText] call OES_fnc_diagLog;
	};
	for "_fuck" from 0 to 2 do {
		[3,format["<t color='#ffdd00'><t size='2'><t align='center'>福利彩票<br/><t color='#eeeeff'><t align='center'><t size='1.2'>%1 是本期彩票的赢家 奖金总共: $%2元!<br /><br /><t color='#ffdd00'><t size='1.1'>彩票机构正在调整,稍后将会推出下一期的彩票.",_winner select 0,[_winnings] call OEC_fnc_numberText],false,[],"life_lottery"] remoteExec ["OEC_fnc_broadcast",-2,false];
		uiSleep 1;
	};
};

life_lotteryCooldown = true;
publicVariable "life_lotteryCooldown";

uiSleep 60; //一分钟重置

life_lottery_list = [];
life_runningLottery = false;
publicVariable "life_runningLottery";
life_lotteryCooldown = false;
publicVariable "life_lotteryCooldown";
