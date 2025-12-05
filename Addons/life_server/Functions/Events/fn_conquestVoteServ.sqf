_exit = false;
if !(isNil{_this select 1}) then {
	if(_this select 1 != -1) exitWith {
		["autoStart",false,_this select 1] spawn OES_fnc_conquestServer;
		_exit = true;
	};
};

if(_exit) exitWith {};

conquestVotes = [];
votedPIDs = [];

"oev_conquest_add_vote" addPublicVariableEventHandler {
	[] spawn {
		uiSleep 1+(random 1);
	};
	if !(((_this select 1) select 1) in votedPIDs) then {
		conquestVotes pushBack ((_this select 1) select 0);
		votedPIDs pushBack ((_this select 1) select 1);
	};
};

[3,"<t color='#ffdd00'><t size='2'><t align='center'>征服<br/><t color='#eeeeff'><t align='center'><t size='1.2'>征服事件开始了！ Type ;vote 在聊天中投票的地点！ <br /><br /><t color='#ffdd00'><t size='1.1'>2分钟后将选择一张地图.",false,[]] remoteExec ["OEC_fnc_broadcast",civilian,false];

[
	["event","征服投票开始了"]
] call OES_fnc_logIt;

oev_conquestVote = true;
publicVariable "oev_conquestVote";
_exit = false;
for "_i" from 0 to 120 do {
	if (oev_cancelConq) exitWith {
		[6, "征服投票被取消了!"] remoteExec ["OEC_fnc_broadcast", civilian];
		oev_cancelConq = false;
		oev_conquestData = [ false, ["", []], [], [], 0, [], [[],[],[]], 3000];
		oev_conquestServ = [ [], [], [], 0 ];
		oev_conquestVote = false;
		_exit = true;
		publicVariable "oev_conquestData";
		publicVariable "oev_conquestVote";
	};
	uiSleep 1;
};
if (_exit) exitWith {};
_arr = [];
_zone = selectRandom[0,1,2,3,4,5,6,7,8];
for "_i" from 1 to 9 do {
	_arr pushBack ({_x == _i} count conquestVotes);
};
if(count _arr != 0) then {
	_zone = _arr find (selectMax _arr);
};

oev_lastConquest = _zone;
publicVariable "oev_lastConquest";

["autoStart",false,_zone,_this select 0] spawn OES_fnc_conquestServer;

oev_conquestVote = false;
publicVariable "oev_conquestVote";

playableUnits apply {_x setVariable["votedConquest",nil,true]};

_location = "";
switch(_zone) do {
	case 0: {
		_location = "Ghost Hotel";
	};
	case 1: {
		_location = "Nifi";
	};
	case 2: {
		_location = "Kavala";
	};
	case 3: {
		_location = "Syrta";
	};
	case 4: {
		_location = "Oreokastro";
	};
	case 5: {
		_location = "Warzone";
	};
	case 6: {
		_location = "Panagia";
	};
	case 7: {
		_location = "Sofia";
	};
};

conquestVotes = nil;
votedPIDs = nil;

[
	["event","Conquest Vote Ended"],
	["location",_location]
] call OES_fnc_logIt;
