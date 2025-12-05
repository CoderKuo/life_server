// fn_AdvancedLog.sqf
// Author: dakuo


params[
	["_player",objNull,[objNull]],
	["_action","",[""]],
	["_actionValue","",[""]]
];


[format["INSERT INTO log(playerid,playername,action,actionvalue) values('%1','%2','%3','%4')",getPlayerUID _player,name _player,_action,_actionValue],1] call OES_fnc_asyncCall; 