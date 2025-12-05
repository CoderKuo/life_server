//	File: fn_copSeizeVeh.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Will seize the car

private["_unit","_vehicle","_gangID"];
_unit = param [0,objNull,[objNull]];
_vehicle = param [1,objNull,[objNull]];
_seizerUID = getPlayerUID _unit;
_gangID = _vehicle getVariable ["gangID",0];
//Error checks
if(isNull _unit) exitWith {};
_unit = owner _unit;
if(isNull _vehicle) exitWith {
	[["oev_action_inUse",false],"OEC_fnc_netSetVar",_unit,false] spawn OEC_fnc_MP;
};

_dbInfo = _vehicle getVariable["dbInfo",[]];

_uid = _dbInfo select 0;
_plate = _dbInfo select 1;

if([_vehicle] call OEC_fnc_skinName isEqualTo "APD Vandal" && _gangID isEqualTo 0 && typeOf _vehicle isEqualTo "C_Hatchback_01_sport_F") then {
	// APD vandal skins in personal garages get transferred on seize
	_color = '"[Police,0]"'; // normal apd skin
	_query = format ["UPDATE "+dbColumVehicle+" SET active='0', persistentServer='0', pid='%1', color='%2', side='cop' WHERE pid='%3' AND plate='%4'",_seizerUID,_color,_uid,_plate];
	[_query,1] call OES_fnc_asyncCall;
} else {
	if((typeof _vehicle) in ["B_Heli_Transport_01_F"]) then {
		//_query = format["UPDATE "+dbColumVehicle+" SET active='0' WHERE pid='%1' AND plate='%2'",_uid,_plate];
		//_sql = [_query,1] call OES_fnc_asyncCall;
	}else{
		if !(_gangID isEqualTo 0) then {
			_query = format["UPDATE "+dbColumGangVehicle+" SET alive='0' WHERE gang_id='%1' AND plate='%2'",_gangID,_plate];
			_sql = [_query,1] call OES_fnc_asyncCall;
		} else {
			_query = format["UPDATE "+dbColumVehicle+" SET alive='0' WHERE pid='%1' AND plate='%2'",_uid,_plate];
			_sql = [_query,1] call OES_fnc_asyncCall;
		};
	};
};

deleteVehicle _vehicle;
[["oev_action_inUse",false],"OEC_fnc_netSetVar",_unit,false] spawn OEC_fnc_MP;
