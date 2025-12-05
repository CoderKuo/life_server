_exit = false;
if(count _this >= 3) then {
	if(_this select 1 isEqualTo "seized") exitWith {
		[7, "The airdrop has been seized by the APD!"] remoteExec ["OEC_fnc_broadcast",playableUnits];
		deleteVehicle (_this select 2);
		oev_airdrop = false;
		_exit = true;
	};
};

if(_exit) exitWith {};
if(oev_airdrop) exitWith {[1, "The airdrop event is already active!"] remoteExec["OEC_fnc_broadcast",remoteExecutedOwner];};

oev_airdrop = true;

_drops = [[23079.8,7298.72,0],[20081.1,6734.58,0],[19349.9,9672.64,0],[16494.1,10020.5,0],[16741.2,20459,0],[11727.8,22921.2,0],[9734.74,22311.5,0],[8851.68,23445.2,0],
[2303.9,22184.4,0],[4856.28,21900.9,0],[13774.9,6393.3,0],[9177.32,8516.57,0],[9574.57,9242.59,0],[9713.34,8700.49,0],[12904,9808.03,0],[9901.01,9834.66,0],[7177.86,11010.6,0],
[6577.78,11184,0],[6156.76,10360.7,0],[9962.53,19352.7,0],[12825.5,19668.8,0],[16595.6,19007.8,0],[20596.9,20075.5,0],[2681.23,11522.6,0],[4163.43,11796.3,0],[7003.38,11642.1,0],
[5306.32,11509.3,0],[6488.21,12241.6,0],[10080.2,11321.7,0],[13336.2,13366.8,0],[11682.4,18737.9,0],[10447.3,17299.9,0],[10290.8,19118.3,0],[22783.9,13786.8,0],[24035.9,15357.1,0],
[26052.9,19718.4,0],[26472,20520.8,0],[26598.7,20758.1,0],[27025.8,21501.3,0],[26705.2,21234.2,0],[27786.8,22257,0],[23372.3,24174.8,0],[21609.4,21286.9,0],[17821.1,18137.9,0],
[20117.4,20036.5,0],[28307.2,25768.8,0],[26910.1,24302,0],[18301.7,15556.5,0],[3003.57,18511.4,0],[4230.53,15054.6,0],[18813.6,16627.6,0],[21348.4,16378.2,0],[12493.9,12744.9,0],
[27633.7,24592.8,0],[22633,16821.1,0],[12495.6,15195.3,0],[11132.7,14562.4,0],[10237,14849.5,0],[9595.06,15124,0],[7865.8,14613.7,0],[12613.4,16392,0],[12834.4,16735.4,0]];

_rollSix = [["LMG_Mk200_F","200Rnd_65x39_cased_Box"],["LMG_Mk200_F","200Rnd_65x39_cased_Box"],["arifle_MX_SW_F","100Rnd_65x39_caseless_mag"],["srifle_DMR_03_tan_F","20Rnd_762x51_Mag"],["srifle_EBR_F","20Rnd_762x51_Mag"],["LMG_03_F","200Rnd_556x45_Box_Red_F"],["muzzle_snds_M","NONE"],["muzzle_snds_58_blk_F","NONE"]];
_rollFourFirst = ["V_HarnessOGL_brn","HandGrenade","DemoCharge_Remote_Mag","SLAMDirectionalMine_Wire_Mag","IEDUrbanBig_Remote_Mag","IEDUrbanSmall_Remote_Mag","MiniGrenade","muzzle_snds_L"];
_rollFourSecond = ["U_O_PilotCoveralls","U_O_PilotCoveralls","U_O_CombatUniform_oucamo","U_O_GhillieSuit","U_O_FullGhillie_sard","V_PlateCarrierIAGL_dgtl","V_PlateCarrierL_CTRG"];
_rollChance25 = [["launch_Titan_F","Titan_AA"],["NONE","RPG7_F"]];
_rollChance10 = [["launch_RPG7_F","RPG7_F"],["srifle_DMR_04_Tan_F","10Rnd_127x54_Mag"]];
_rollChance1 = ["NVGogglesB_gry_F","optic_DMS","srifle_DMR_02_camo_F"];

_time = serverTime;
_location = selectRandom _drops;
_marker = createMarker["airdrop",_location];
_marker setMarkerShape "ELLIPSE";
_marker setMarkerBrush "DiagGrid";
_marker setMarkerColor "colorRed";
_marker setMarkerSize[1000,1000];
_markerText = createMarker["text",[(_location select 0)-10,(_location select 1)]];
_markerText setMarkerType "hd_warning";
_markerText setMarkerColor "colorRed";
_markerText setMarkerText "空投区域";

[
	["event","Airdrop Started"],
	["auto",!(isRemoteExecuted)],
	["location",_location],
	["player",name(_this select 0)],
	["player_id",getPlayerUID(_this select 0)]
] call OES_fnc_logIt;

[7, "Altis国家军械库准备投放一个装满稀有装备的空投!"] remoteExec["OEC_fnc_broadcast",playableUnits];
uiSleep 300;
[7, "Altis国家军械空投将在五分钟后投放!"] remoteExec["OEC_fnc_broadcast",playableUnits];
uiSleep 240;
[7, "Altis国家军械空投将在一分钟后投放!"] remoteExec["OEC_fnc_broadcast",playableUnits];

_wind = [wind select 0, wind select 1];
setWind [0, 0, true];
uiSleep 60;

_markerText setMarkerText "空投正在投放";
[7, "Altis国家军械空投将在已经投放!"] remoteExec["OEC_fnc_broadcast",playableUnits];

_chute = "B_Parachute_02_F" createVehicle _location;
_chute setPosATL [getPosATL _chute select 0,getPosATL _chute select 1,1000];
_airdrop = "B_CargoNet_01_ammo_F" createVehicle (getPosATL _chute);
_airdrop enableRopeAttach false;
_chute disableCollisionWith _airdrop;
_chute allowDamage false;
_airdrop allowDamage false;
_airdrop attachTo [_chute,[0,0,0]];
[_airdrop] remoteExec ["OEC_fnc_airdropClient", west, _airdrop];
clearWeaponCargoGlobal _airdrop;
clearItemCargoGlobal _airdrop;
clearMagazineCargoGlobal _airdrop;

for "_i" from 1 to 6 do {
	_rand = selectRandom _rollSix;
	if !(_rand select 1 isEqualTo "NONE") then {
		_airdrop addWeaponCargoGlobal[_rand select 0,1];
		_airdrop addMagazineCargoGlobal[_rand select 1,8];
	} else {
		_airdrop addItemCargoGlobal[_rand select 0,1];
	};
	if(_i <= 4) then {
		_rand = selectRandom _rollFourFirst;
		_airdrop addItemCargoGlobal[_rand,1];
		_rand = selectRandom _rollFourSecond;
		_airdrop addItemCargoGlobal[_rand,1];
	};
};

if(floor(random 4) == 2) then {
	_rand = selectRandom _rollChance25;
	if(_rand select 0 isEqualTo "NONE") then {
		_airdrop addMagazineCargoGlobal[_rand select 1,4];
	} else {
		_airdrop addWeaponCargoGlobal[_rand select 0,1];
		_airdrop addMagazineCargoGlobal[_rand select 1,4];
	};
};

if(floor(random 10) == 5) then {
	_rand = selectRandom _rollChance10;
	_airdrop addWeaponCargoGlobal[_rand select 0,1];
	_airdrop addMagazineCargoGlobal[_rand select 1,4];
};

if(floor(random 100) == 69) then {
	_rand = selectRandom _rollChance1;
	if(_rand isEqualTo "srifle_DMR_02_camo_F") then {
		_airdrop addWeaponCargoGlobal[_rand,1];
	} else {
		_airdrop addItemCargoGlobal[_rand,1];
	};
};

[
	["event","Airdrop Spawned"],
	["gear",(itemCargo _airdrop + weaponCargo _airdrop + magazineCargo _airdrop)]
] call OES_fnc_logIt;

waitUntil {getPosATL _airdrop select 2 < 4 || getPosASL _airdrop select 2 < 0};
uiSleep 3;
if(underwater _airdrop) then {
	_airdrop setPosATL _location;
} else {
	_airdrop setPosATL[getPosATL _airdrop select 0,getPosATL _airdrop select 1,(getPosATL _airdrop select 1)+1];
};
_smoke = "SmokeShellPurple" createVehicle (getPosATL _airdrop);
_smoke attachTo [_airdrop,[0,0,0.7]];
setWind _wind;
uiSleep 0.1;
if(getPosATL _airdrop select 2 > 5) then {
	_airdrop setPosATL[getPosATL _airdrop select 0,getPosATL _airdrop select 1,1];
};
uiSleep 0.1;
_finalPos = getPosATL _airdrop;
_finalPos set[2,(_finalPos select 2)-(getPos _airdrop select 2)];
waitUntil{((count(ItemCargo _airdrop))+(count(WeaponCargo _airdrop))+(count(MagazineCargo _airdrop))) == 0 || (serverTime - _time) >= 1500 || !(oev_airdrop)};
if((serverTime - _time) < 1500 && oev_airdrop) then {
	[7, "The Altis National Armory supply drop has been claimed!"] remoteExec["OEC_fnc_broadcast",playableUnits];
};
deleteVehicle _airdrop;
deleteVehicle _chute;
deleteVehicle _smoke;
deleteMarker _marker;
deleteMarker _markerText;

if(oev_airdrop) then {
	oev_airdrop = false;
};
