//----- DO NOT EDIT THIS MACRO FILE UNLESS IT IS IN THE ROOT MISSION FOLDER. (Olympus_life.Altis) -------
#define __CONST__(var1,var2) var1 = compileFinal (if(var2 isEqualType "") then {var2} else {str(var2)}) //Quick macro for creating a constant variable
#define __GETC__(var) (call var) //Quick clean macro for getting a value of a constant / compileFinal variable. i.e if(__GETC__(numberone) == 1) then {}
#define fileName (__FILE__ select [29, count __FILE__ - 33])
#define scriptAvailable(cooldownTime) (cooldownTime call {_zindex = life_scriptCooldowns find fileName; _zret = false; if(_zindex != -1) then { if((life_scriptCooldowns select (_zindex + 1)) > (time - _this)) then { _zret = true; } else { life_scriptCooldowns set [(_zindex + 1),time];}; } else { life_scriptCooldowns pushBack fileName; life_scriptCooldowns pushBack time;}; _zret;})

//Control (aka dialog) Macros
#define getControl(disp,ctrl) ((findDisplay ##disp) displayCtrl ##ctrl)
#define getSelData(ctrl) (lbData[##ctrl,(lbCurSel ##ctrl)])

//Player based quick macros
#define playerGroup group player
#define steamid getPlayerUID player
#define getName(target) (target getVariable["realname",name target])

//Variable management
#define SUB(var1,var2) var1 = var1 - var2
#define ADD(var1,var2) var1 = var1 + var2

//For update cash, use negative numbers when buying items, positive when selling, location can be bank, cash, or either. It will take or put money in whatever is specified.
#define updateCash(varValue, varDestination) ([varValue,varDestination] call {_modifier = [_this,0,0,[0]] call BIS_fnc_param;_location = [_this,1,"either",[""]] call BIS_fnc_param;_return = true;if(_modifier < 0) then {if(_location == "either") then {if(oev_cash > -(_modifier)) then {oev_cash = oev_cash + _modifier;life_cacheCash = life_cacheCash + _modifier;}else{if(life_bank > -(_modifier)) then {life_bank = life_bank + _modifier;life_cacheBank = life_cacheBank + _modifier;}else{_return = false;};};}else{if(_location == "cash") then {if(oev_cash > -(_modifier)) then {oev_cash = oev_cash + _modifier;life_cacheCash = life_cacheCash + _modifier;}else{_return = false;};}else{if(_location == "bank") then {if(life_bank > -(_modifier)) then {life_bank = life_bank + _modifier;life_cacheBank = life_cacheBank + _modifier;}else{_return = false;};}else{_return = false;};};};}else{if(_location == "either") then {oev_cash = oev_cash + _modifier;life_cacheCash = life_cacheCash + _modifier;}else{if(_location == "cash") then {oev_cash = oev_cash + _modifier;life_cacheCash = life_cacheCash + _modifier;}else{if(_location == "bank") then {life_bank = life_bank + _modifier;life_cacheBank = life_cacheBank + _modifier;}else{_return = false;};};};};_return;})


//make macro for adding and subbing cash, that way it adds to the cache var as well


//Add macros for quickly getting position to debug island, or jail. Also macros for checking common conditions, like is arrested, etc.
#define onDebugIsland(var1) (var1 call {_lret = false; if(isNull _this) exitWith {_lret = false; _lret;}; if((_this distance [8526,25250,0]) > 400) then {_lret = false;} else {_lret = true;}; _lret;})
#define isBadPosition(var1) (var1 call {_lret = false; if(count _this < 2) exitWith {_lret = true; _lret}; if(_this distance [0,0,0] < 500) then {_lret = true;} else {_lret = false;}; _lret;})

//allows for easy setting position of an object. Note that allowdamage is only gonna work if the vehicle is local to you.  POS MUST ME ASL [[ASL POS ARRAY],direction]
#define setPosAndDir(var1,var2) var1 allowDamage false; var1 setPosASL (var2 select 0); var1 setDir (var2 select 1); var1 spawn{sleep 2; _this allowDamage true;}

