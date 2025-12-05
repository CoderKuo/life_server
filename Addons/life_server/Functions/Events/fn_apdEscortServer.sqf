//	File: fn_apdEscortServer.sqf
//	Author: Tech
//	Description: Handles the APD escort event on the server

// serv_apdEscortData
// [type,gear vehicle,gearCount,current checkpoint,marker count,player who started,max length of event,armed veh,isCheckpointactive?,allMarkerNames]
// oev_apdEscort (true if active, nil if not)

params [
  ["_mode",-1,[0]],
  ["_vars",[],[[],0]],
  ["_player",objNull,[objNull]]
];

_lcl_addGear = {
  params [
    ["_vehicle",objNull,[objNull]]
  ];

  _rollSix = [["LMG_Mk200_F","200Rnd_65x39_cased_Box"],["LMG_Mk200_F","200Rnd_65x39_cased_Box"],["arifle_MX_SW_F","100Rnd_65x39_caseless_mag"],["srifle_DMR_03_tan_F","20Rnd_762x51_Mag"],["srifle_DMR_03_F","20Rnd_762x51_Mag"],["LMG_03_F","200Rnd_556x45_Box_Red_F"],["muzzle_snds_M","NONE"],["muzzle_snds_58_blk_F","NONE"]];
  _rollFourFirst = ["V_HarnessOGL_brn","HandGrenade","DemoCharge_Remote_Mag","SLAMDirectionalMine_Wire_Mag","IEDUrbanBig_Remote_Mag","IEDUrbanSmall_Remote_Mag","MiniGrenade","muzzle_snds_B"];
  _rollFourSecond = ["U_O_PilotCoveralls","U_O_PilotCoveralls","U_O_CombatUniform_oucamo","V_PlateCarrierSpec_blk","V_PlateCarrier2_blk","V_PlateCarrierIAGL_dgtl","V_PlateCarrierL_CTRG"];
  _rollChance25 = [["launch_Titan_F","Titan_AA"],["NONE","RPG7_F"],["srifle_DMR_02_F","10Rnd_338_Mag"]];
  _rollChance10 = [["launch_RPG7_F","RPG7_F"],["srifle_DMR_04_Tan_F","10Rnd_127x54_Mag"]];
  _rollChance5 = ["NVGogglesB_blk_F","optic_DMS","srifle_DMR_02_camo_F"];

  for "_i" from 1 to 6 do {
  	_rand = selectRandom _rollSix;
  	if !(_rand select 1 isEqualTo "NONE") then {
  		_vehicle addWeaponCargoGlobal[_rand select 0,1];
      if (_rand select 1 isEqualTo "20Rnd_762x51_Mag") then {
  		  _vehicle addMagazineCargoGlobal[_rand select 1,3];
      } else {
        _vehicle addMagazineCargoGlobal[_rand select 1,8];
      };
  	} else {
  		_vehicle addItemCargoGlobal[_rand select 0,1];
  	};
  	if(_i <= 4) then {
  		_rand = selectRandom _rollFourFirst;
  		_vehicle addItemCargoGlobal[_rand,1];
  		_rand = selectRandom _rollFourSecond;
  		_vehicle addItemCargoGlobal[_rand,1];
  	};
  };

  if(floor(random 4) isEqualTo 2) then {
  	_rand = selectRandom _rollChance25;
  	if(_rand select 0 isEqualTo "NONE") then {
  		_vehicle addMagazineCargoGlobal[_rand select 1,4];
  	} else {
  		_vehicle addWeaponCargoGlobal[_rand select 0,1];
  		_vehicle addMagazineCargoGlobal[_rand select 1,4];
  	};
  };

  if(floor(random 10) isEqualTo 5) then {
  	_rand = selectRandom _rollChance10;
  	_vehicle addWeaponCargoGlobal[_rand select 0,1];
  	_vehicle addMagazineCargoGlobal[_rand select 1,4];
  };

  if(floor(random 20) isEqualTo 15) then {
  	_rand = selectRandom _rollChance5;
  	if(_rand isEqualTo "srifle_DMR_02_camo_F") then {
  		_vehicle addWeaponCargoGlobal[_rand,1];
  	} else {
  		_vehicle addItemCargoGlobal[_rand,1];
  	};
  };
};

_lcl_makeMarkers = {
  // small, medium, large escort marker positions
  _markers = [
    [[3292.29,12968.6],[10194.245,15905.239],[13861.876,18564.184]],
    [[3292.29,12968.6],[13861.876,18564.184],[17391.779,13146.482]],
    [[3292.29,12968.6],[12672.19,16355.678],[18201.34,15524.81],[25337.967,21828.752]]
  ];

  serv_apdEscortData set [9,[]];

  _count = (count (_markers select _type)) -1;
  {
    _suffix = switch (_forEachIndex) do {
        case 0: {"start"};
        case _count: {"end"};
        default {_forEachIndex}
    };
    _markName = format ["apd_escort_%1",_suffix];
    (serv_apdEscortData select 9) pushBack _markName;
    createMarker [_markName, _x];
    _markName setMarkerColor "ColorWEST";
    _markName setMarkerShape "ICON";
    if(_suffix isEqualType "") then {
      if(_suffix isEqualTo "start") then {
        _markName setMarkerText "APD Escort Start";
      } else {
        _markName setMarkerText "APD Escort Drop-Off";
      }
    } else {
      _markName setMarkerText format ["APD Escort Checkpoint %1",_suffix];
    };

    if(_suffix isEqualType 0) then {_suffix = "pickup";};
    _markName setMarkerType format["mil_%1",_suffix];
  } forEach (_markers select _type);

    serv_apdEscortData set [4,count (_markers select _type)-1];
};

_lcl_spawns = {
  [] spawn{
    sleep 3;
    (serv_apdEscortData select 1) allowDamage true;
    (serv_apdEscortData select 7) allowDamage true;
  };

  //ESCORT VEHICLE
  (serv_apdEscortData select 1) spawn{
    while {true} do {
      uiSleep 3;
      if(isNull _this) exitWith {};
      if(count serv_apdEscortData isEqualTo 0) exitWith {};
      if(serverTime >= (serv_apdEscortData select 6)) exitWith {
        _msg = "<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>Due to the event taking too long, the escort vehicle(s) will self destruct in 2 minutes.";
        [3,_msg] remoteExec ["OEC_fnc_broadcast",-2,false];
        uiSleep 120;
        _msg = "<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>Due to the event taking too long, the escort vehicle(s) will self destruct in 20 seconds.";
        [3,_msg] remoteExec ["OEC_fnc_broadcast",-2,false];
        uiSleep 20;
        _this setDamage 1;
        (serv_apdEscortData select 7) setDamage 1;
      };
      if(getDammage _this isEqualTo 1) exitWith {
        _msg = "<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>The escort vehicle has blown up!";
        [3,_msg] remoteExec ["OEC_fnc_broadcast",-2,false];
        if !(isNull (serv_apdEscortData select 7) || getDammage (serv_apdEscortData select 7) isEqualTo 1) then {
          uiSleep 60;
          _msg = "<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>The armed vehicle still remains. It will self destruct in 4 minutes.";
          [3,_msg] remoteExec ["OEC_fnc_broadcast",-2,false];
          uiSleep (60*4);
          (serv_apdEscortData select 7) setDamage 1;
        };
      };
      if((count(ItemCargo _this))+(count(WeaponCargo _this))+(count(MagazineCargo _this)) isEqualTo 0) exitWith {
        _msg = "<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>The escort vehicle lost all of its gear. The vehicle will self destruct in 45 seconds";
        [3,_msg] remoteExec ["OEC_fnc_broadcast",-2,false];
        uiSleep 45;
        _this setDamage 1;
      };
    };
    serv_apdEscortCooldown = (serverTime + 1800);
    publicVariable "serv_apdEscortCooldown";
    {deleteMarker _x;} forEach (serv_apdEscortData select 9);
    serv_apdEscortData = [];
    oev_apdEscort = nil;
    publicVariable "oev_apdEscort";
  };

  (serv_apdEscortData select 1) spawn{
    _vehicle = _this;
    private _time = switch (serv_apdEscortData select 0) do {
      case 0: {70};
      case 1: {60};
      case 2: {50};
    };

    private _pos = (getPos _vehicle);
    _marker = createMarker ["apdEscort",_pos];
    _markerOutline = createMarker ["apdEscortOutline",_pos];

    if (random(175) >= 100) then {
      _pos = [((_pos select 0) + random(170)), ((_pos select 1) + random(170))];
    } else {
      _pos = [((_pos select 0) - random(170)), ((_pos select 1) - random(170))];
    };

    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerBrush "FDiagonal";
    _marker setMarkerSize [200, 200];
    _marker setMarkerColor "ColorWEST";
    _marker setMarkerPos [_pos select 0, _pos select 1];

    _markerOutline setMarkerShape "ELLIPSE";
    _markerOutline setMarkerBrush "Border";
    _markerOutline setMarkerSize [200, 200];
    _markerOutline setMarkerColor "ColorWEST";
    _markerOutline setMarkerPos [_pos select 0, _pos select 1];

    while {true} do {
      uiSleep _time;
      if (isNull _vehicle || !(alive _vehicle) || (count serv_apdEscortData) isEqualTo 0) exitWith {
        deleteMarker _marker;
        deleteMarker _markerOutline;
      };

      _pos = getPos _vehicle;
      if (random(175) >= 100) then {
        _pos = [((_pos select 0) + random(170)), ((_pos select 1) + random(170))];
      } else {
        _pos = [((_pos select 0) - random(170)), ((_pos select 1) - random(170))];
      };
      _marker setMarkerPos [_pos select 0, _pos select 1];
      _markerOutline setMarkerPos [_pos select 0, _pos select 1];

      [0,"The APD escort vehicle location has been updated."] remoteExec ["OEC_fnc_broadcast",-2,false];
    };

    if !(isNil _marker) then {deleteMarker _marker;};
    if !(isNil _markerOutline) then {deleteMarker _markerOutline;};
  };

  //ARMED VEHICLE
  if !(isNull (serv_apdEscortData select 7)) then {
    (serv_apdEscortData select 7) spawn{
      while {true} do {
        uiSleep 3;
        if(isNull _this) exitWith {};
        if(count serv_apdEscortData isEqualTo 0) exitWith {};
        if(serverTime >= (serv_apdEscortData select 6)) exitWith {};
        if(getDammage _this isEqualTo 1) exitWith {
          _msg = "<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>The armed escort vehicle has blown up!";
          [3,_msg] remoteExec ["OEC_fnc_broadcast",-2,false];
        };
      };
    };
  };
};

_lcl_startEscort = {
  params[
    ["_type",0,[0]],
    ["_player",objNull,[objNull]]
  ];

  call _lcl_makeMarkers;

  //Broadcast global message
  _msg = format[
    "<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>Officer %1 has started an APD escort, they will be moving a truck with a %2 amount of APD evidence in %3.",
    name _player,
    ["small","moderate","large"] select _type,
    ["1 minute", "2 minutes", "2 minutes and 30 seconds"] select _type
  ];
  [3,_msg] remoteExec ["OEC_fnc_broadcast",-2,false];

  serv_apdEscortData set [0,_type];
  oev_apdEscort = true;
  publicVariable "oev_apdEscort";

  _wait = switch(_type) do {
    case 0: {60};
    case 1: {120};
    case 2: {150};
  };
  uiSleep _wait;
  _msg = format["<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>The truck is now moving towards %1.",["the drop off", "the next checkpoint", "the next checkpoint"] select _type];
  [3,_msg] remoteExec ["OEC_fnc_broadcast",-2,false];

  private _armedVeh = objNull;
  _armedVehClass = switch (_type) do {
      case 1: {"I_G_Offroad_01_armed_F"};
      case 2: {"B_T_LSV_01_armed_F"};
  };
  if(_armedVehClass isEqualType "") then {
    {deleteVehicle _x;} forEach nearestObjects[[3277.66,12955.4,0.00143671],["Car","Air","Ship","Armored","Submarine"],8];
    _armedVeh = createVehicle [_armedVehClass,[3277.66,12955.4,0.00143671],[],0,"CAN_COLLIDE"];
    waitUntil {!isNil "_armedVeh" && {!isNull _armedVeh}};
    _armedVeh lock 0;
    clearItemCargoGlobal _armedVeh;
    _armedVeh allowDamage false;
    _armedVeh setDir 90;
    [_armedVeh,["Guerilla_12",1], ["Hide_Shield",0,"Hide_Rail",0,"HideDoor1",0,"HideDoor2",0,"HideDoor3",0,"HideBackpacks",0,"HideBumper1",1,"HideBumper2",0,"HideConstruction",0]] call BIS_fnc_initVehicle;
    [_armedVeh,["APDEscort",0]] remoteExec ["OEC_fnc_colorVehicle",0,true];
    serv_apdEscortData set [7,_armedVeh];
  } else {
    serv_apdEscortData set [7,objNull];
  };

  {deleteVehicle _x;} forEach nearestObjects[getMarkerPos "apd_escort_start",["Car","Air","Ship","Armored","Submarine"],8];

  _classname = switch(_type) do {
    case 0: {"B_T_Truck_01_Repair_F"};
    case 1: {"B_T_Truck_01_ammo_F"};
    case 2: {"B_T_Truck_01_ammo_F"};
  };
  private _vehicle = createVehicle [_classname,getMarkerPos "apd_escort_start",[],0,"CAN_COLLIDE"];
  waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
  _vehicle lock 0;
  clearItemCargoGlobal _vehicle;
  _vehicle allowDamage false;
  _vehicle setDir 180;
  [_vehicle,"civ"] call OEC_fnc_clearVehicleAmmo;

  {
    if !(isNull _x) then {
      _x setVariable ["apdEscort",true,true];
      _x setVariable ["dbinfo",["1234","1234"],true];
      _x setVariable ["side","cop",true];
      _x setVariable ["vehicle_info_owners",["01234","APD Escort Vehicle"],true];
      _x setVariable ["defaultModMass",(getMass _vehicle),true];
      _x setVariable ["modifications",[0,0,0,0,0,0,0,0],true];
      _x setVariable ["insured",0,true];
      if(_forEachIndex isEqualTo 0) then {
        _x setVariable ["isBlackwater",false,true];
      } else {
        _x setVariable ["isBlackwater",true,true];
        _x setVariable ["oev_veh_color",["APDEscort",0],true];
      };
      _x enableRopeAttach false;
      _x enableVehicleCargo false; //Prevents vehicle from being carried in blackfish :)
    };
  } forEach [_vehicle,_armedVeh];

  _vehicle call _lcl_addGear;
  serv_apdEscortData set [1,_vehicle];
  _gearCount = (count(ItemCargo _vehicle))+(count(WeaponCargo _vehicle));
  serv_apdEscortData set [2,_gearCount];
  serv_apdEscortData set [3,1];
  serv_apdEscortData set [5,_player];
  serv_apdEscortData set [6,serverTime+(60*60)];
  serv_apdEscortData set [8,false];
  call _lcl_spawns;
};

_lcl_checkpoint = {
  params [
    ["_checkpoint",-1,[0]],
    ["_player",objNull,[objNull]]
  ];
  if (serv_apdEscortData select 8) exitWith {
    [3,"Checkpoint is already started!"] remoteExec ["OEC_fnc_broadcast",_player,false];
  };
  if !(_checkpoint isEqualTo (serv_apdEscortData select 3)) exitWith {
    [3,"Wrong checkpoint."] remoteExec ["OEC_fnc_broadcast",_player,false];
  };
  if((serv_apdEscortData select 1) distance2D (getMarkerPos format["apd_escort_%1",(serv_apdEscortData select 3)]) < 10) then {
    [3,"Checkpoint started. Hold the vehicle here for 1:30."] remoteExec ["OEC_fnc_broadcast",west,false];
    serv_apdEscortData set [8,true];
    _msg = format["<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>The APD have started holding checkpoint %1",serv_apdEscortData select 3];
    [3,_msg] remoteExec ["OEC_fnc_broadcast",[civilian,independent],false];
    _completed = true;
    _count = 0;
    while {true} do {
        uiSleep 1;
        if(_count >= 90) exitWith {};
        if((serv_apdEscortData select 1) distance2D (getMarkerPos format["apd_escort_%1",serv_apdEscortData select 3]) > 10) exitWith {
          _completed = false;
        };
        _count = _count + 1;
    };
    if(_completed) then {
      (format["apd_escort_%1",serv_apdEscortData select 3]) setMarkerColor "ColorGreen";
      [3,"Checkpoint completed! You may now continue on your path!"] remoteExec ["OEC_fnc_broadcast",-2,false];
      _msg = format["<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>The APD have completed checkpoint %1",serv_apdEscortData select 3];
      [3,_msg] remoteExec ["OEC_fnc_broadcast",[civilian,independent],false];
      serv_apdEscortData set[3,(serv_apdEscortData select 3)+1];
      serv_apdEscortData set [8,false];
    } else {
      [3,"You exceeded the max range of the checkpoint. Try again."] remoteExec ["OEC_fnc_broadcast",_player,false];
      serv_apdEscortData set [8,false];
    };
  } else {
    [3,"Escort vehicle is too far."] remoteExec ["OEC_fnc_broadcast",_player,false];
  };
};

_lcl_dropOff = {
  params [
    ["_type",-1,[0]],
    ["_player",objNull,[objNull]]
  ];
  if (serv_apdEscortData select 8) exitWith {
    [3,"Checkpoint is already started!"] remoteExec ["OEC_fnc_broadcast",_player,false];
  };
  if !(_type isEqualTo (serv_apdEscortData select 0)) exitWith {
    [3,"Wrong dropoff."] remoteExec ["OEC_fnc_broadcast",_player,false];
  };
  if !((serv_apdEscortData select 3) isEqualTo (serv_apdEscortData select 4)) exitWith {
    [3,"The vehicle has not stopped at all checkpoints!"] remoteExec ["OEC_fnc_broadcast",_player,false];
  };
  if !((serv_apdEscortData select 1) distance2D (getMarkerPos "apd_escort_end") < 10) exitWith {
    [3,"The vehicle is not close enough!"] remoteExec ["OEC_fnc_broadcast",_player,false];
  };
  serv_apdEscortData set [8,true];
  [3,"Hold the vehicle here for 1:30"] remoteExec ["OEC_fnc_broadcast",west,false];
  _completed = true;
  _count = 0;
  while {true} do {
      uiSleep 1;
      if(_count >= 90) exitWith {};
      if((serv_apdEscortData select 1) distance2D (getMarkerPos "apd_escort_end") > 10) exitWith {
        _completed = false;
      };
      _count = _count + 1;
  };
  if(_completed) then {
    serv_apdEscortData set [8,false];
    serv_apdEscortCooldown = (serverTime + 1800);
    publicVariable "serv_apdEscortCooldown";
    _gearPercent = (((count(ItemCargo (serv_apdEscortData select 1))))+(count(WeaponCargo (serv_apdEscortData select 1))))/(serv_apdEscortData select 2);
    [3,format["Escort completed! You managed to maintain %1%2 of the gear.",_gearPercent*100,"%"]] remoteExec ["OEC_fnc_broadcast",_player,false];
    _msg = format["<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>The APD have have succesfully dropped off the escort vehicle with %1%2 of the gear.",_gearPercent*100,"%"];
    [3,_msg] remoteExec ["OEC_fnc_broadcast",[civilian,independent],false];

    deleteVehicle (serv_apdEscortData select 1);
    {deleteMarker _x;} forEach (serv_apdEscortData select 9);
    _armed = (serv_apdEscortData select 7);

    serv_apdEscortData = [];
    oev_apdEscort = nil;
    publicVariable "oev_apdEscort";

    _reward = switch(_type) do {
      case 0: {1000000};
      case 1: {1500000};
      case 2: {2000000};
    };
    _reward = _reward * _gearPercent;
    [_player,_reward,1,200] remoteExec ["OEC_fnc_splitPay",_player];

    _costReward = switch(_type) do {
      case 0: {250000};
      case 1: {500000};
      case 2: {750000};
    };
    [
      ["event","APD Escort Drop Off"],
      ["player",name _player],
      ["player_id",getPlayerUID _player],
      ["reward_for_all",_reward],
      ["gear_percent",_gearPercent],
      ["reward_for_starter",_costReward],
      ["position",getPosATL player]
    ] call OES_fnc_logIt;

    uiSleep 20;
    [13,_costReward,name (serv_apdEscortData select 5)] remoteExec ["OEC_fnc_payPlayer",(serv_apdEscortData select 5),false];

    if !(isNull _armed || getDammage _armed isEqualTo 1) then {
      uiSleep 60;
      _msg = "<t color='#0362fc'><t size='2.2'><t align='center'>APD ESCORT<br/><t color='#FFFFFF'><t align='center'><t size='1.2'>The armed vehicle still remains. It will self destruct in 4 minutes.";
      [3,_msg] remoteExec ["OEC_fnc_broadcast",-2,false];
      uiSleep (60*4);
      _armed setDamage 1;
    };
  } else {
    [3,"You exceeded the max range of the dropoff. Try again."] remoteExec ["OEC_fnc_broadcast",_player,false];
  };
};

switch (_mode) do {
    case 0: {[_vars,_player] call _lcl_startEscort};
    case 1: {[_vars,_player] call _lcl_checkpoint};
    case 2: {[_vars,_player] call _lcl_dropOff};
};
