//  File: fn_gangBank
//	Author: Poseidon

private["_query"];
params [
	["_mode",0,[0]],
	["_gangID",-1,[0]],
	["_unit",objNull,[objNull]],
	["_change",0,[0]],
	["_cash",0,[0]],
	["_cashRand",0,[0]],
	["_armsTax",false,[false]],
	["_gangName", "",[""]]
];
if(isNull _unit || _gangID isEqualTo -1) exitWith {};

switch (_mode) do {
	case 0: {
		_query = format["SELECT bank FROM gangs WHERE id='%1'",_gangID];
		_queryResult = [_query,2] call OES_fnc_asyncCall;

		["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
		["oev_gangfund_ready",true] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
		["oev_gang_funds",(_queryResult select 0)] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
	};

	case 1: {
		if(_change <= 0) then {
			//random uiSleep times to prevent multiple players from withdrawing funds at the same time to dupe money
			uiSleep round(random(3));
			uiSleep round(random(6));
			uiSleep round(random(3));
		};

		_query = format["SELECT bank FROM gangs WHERE id='%1'",_gangID];
		_queryResult = [_query,2] call OES_fnc_asyncCall;

		if(((_queryResult select 0) + _change) >= 0) then {
			if(isNull _unit) exitWith {};

			_query = format["UPDATE gangs SET bank='%1' WHERE id='%2'",((_queryResult select 0) + _change),_gangID];

			if(_change > 0) then {
				[
					["event","Gang Bank Deposit"],
					["player",name _unit],
					["player_id",getPlayerUID _unit],
					["value",_change],
					["gang_name",_gangName],
					["gang_id",_gangID],
					["new_gang_bank",(_queryResult select 0) + _change],
					["new_player_cash",_cash - _change]
				] call OES_fnc_logIt;

				private _logHistory = format ["INSERT INTO gangbankhistory (name,playerid,type,amount,gangid) VALUES('%1','%2','1','%3','%4')",name _unit,getPlayerUID _unit,_change,_gangID];
				[_logHistory,1] call OES_fnc_asyncCall;
			} else {
				[
					["event","Gang Bank Withdraw"],
					["player",name _unit],
					["player_id",getPlayerUID _unit],
					["value",_change],
					["gang_name",_gangName],
					["gang_id",_gangID],
					["new_gang_bank",(_queryResult select 0) + _change],
					["new_player_cash",_cash - _change]
				] call OES_fnc_logIt;

				private _logHistory = format ["INSERT INTO gangbankhistory (name,playerid,type,amount,gangid) VALUES('%1','%2','2','%3','%4')",name _unit,getPlayerUID _unit,(_change * -1),_gangID];
				[_logHistory,1] call OES_fnc_asyncCall;
			};

			[_query,1] call OES_fnc_asyncCall;

			if(isNull _unit) exitWith {};
			if(_change <= 0) then {
				["oev_cash",(_cash - _change)] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
			};
			["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
		} else {
			if(isNull _unit) exitWith {};

			if(_change >= 0) then {
				["oev_cash",_cash] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
			};
			["oev_cache_cash",_cashRand] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];


			[1,"Transaction failed to process. Insufficient funds."] remoteExec ["OEC_fnc_broadcast",(owner _unit),false];
			["oev_action_inUse",false] remoteExec ["OEC_fnc_netSetVar",(owner _unit),false];
		};
	};

	case 2: {
		if(isNull _unit) exitWith {};

		_query = format["SELECT bank FROM gangs WHERE id='%1'",_gangID];
		_queryResult = [_query,2] call OES_fnc_asyncCall;

		if(_change > 0) then {
			if (_armsTax) then {
				format["Due to a purchase by %1(%2), $%5 was deposited into gang funds for GangID: %6. Previous Gang funds: $%3, New Gang funds: $%4", name _unit, getPlayerUID _unit, [(_queryResult select 0)] call OEC_fnc_numberText, [((_queryResult select 0) + _change)] call OEC_fnc_numberText, [_change] call OEC_fnc_numberText, _gangID] call OES_fnc_diagLog;
			} else {
				format["Player %1(%2) deposited funds to gang. Previous Gang funds: $%3, New Gang funds: $%4, Total Change: $%5, GangID: %6", name _unit, getPlayerUID _unit, [(_queryResult select 0)] call OEC_fnc_numberText, [((_queryResult select 0) + _change)] call OEC_fnc_numberText, [_change] call OEC_fnc_numberText, _gangID] call OES_fnc_diagLog;
			};
		} else {
			format["Player %1(%2) withdrew funds to gang. Previous Gang funds: $%3, New Gang funds: $%4, Total Change: $%5, GangID: %6", name _unit, getPlayerUID _unit, [(_queryResult select 0)] call OEC_fnc_numberText, [((_queryResult select 0) + _change)] call OEC_fnc_numberText, [_change] call OEC_fnc_numberText, _gangID] call OES_fnc_diagLog;
		};

		if(((_queryResult select 0) + _change) >= 0) then {
			_query = format["UPDATE gangs SET bank='%1' WHERE id='%2'",((_queryResult select 0) + _change),_gangID];

			[_query,1] call OES_fnc_asyncCall;
		};
	};
};
