//  File: fn_handleDisc.sqf
//	Author: Fusah
//	Description: ZnVjayB5b3U=

params [
	["_switch",0],
	["_unit",objNull],
	["_data",[]]
];

private _event = '';
private _cust1 = ['',''];
private _cust2 = ['',''];
private _uid = getPlayerUID _unit;

switch (_switch) do {
	case 1: {
		_event = "Hacked Currency Flagged";
		_cust1 = ['hacked cash',_data select 0];
		_cust2 = ['hacked bank',_data select 1];
	};
	case 2: {
		_event = "Spoofed UID Flagged";
		_cust1 = ['spoofed id',_data select 0];
	};
	case 3: {
		_event = _data select 0;
	};
	case 4: {
		_event = "Mass Death Event Trigger";
		_cust1 = ['players alive',_data select 0];
		_cust2 = ['players dead',_data select 1];
		_uid = 'nil';
	};
	case 5: {
		_event = "Hacked Selling Price Flagged";
		_cust1 = ['hacked item',_data select 0];
		_cust2 = ['hacked price',_data select 1];
	};
	case 6: {
		_event = "Potential Hack Menu";
		_cust1 = ['menu', _data select 0];
		_cust2 = ['controls', _data select 1];
	};
	case 7: {
		_event = "Potential Variable Spoof";
		_cust1 = ['count', _data select 0];
	};
	case 8: {
		_event = "Bad Variable";
		_cust1 = ['variable', _data select 0];
	};
	case 9: {
		_event = "Bad Event Handler Count";
		_cust1 = ['', _data select 1];
	};
	case 9: {
		_event = "Bad Aim Coefficient";
		_cust1 = ['coef', _data select 0];
	};
	case 10: {
		_event = "Bad Command";
		_cust1 = ['command', _data select 0];
		_cust2 = ['rank', _data select 1];
	};
	case 11: {
		_event = "Potential Silent Aim";
		_cust1 = ['projectile velocity',_data select 0];
		_cust2 = ['max velocity',_data select 1];
	};
};

private _bm = 'https:/' + '/www.battlemetrics.com/rcon/players?fil'+'ter%5Bsearch%5D=' + _uid + '&fi'+'lter%5Bservers%5D=226555%2C226557%2C911972%2C2301919&sort=score&showServers=true';
private _hlink = format['[%1](%2)',_uid,_bm];

// ["prod",[
// "",
// "",
// _event,
// format["Players: %1/110 | FPS: %2",count playableUnits,diag_fps],
// name _unit,
// _hlink,
// format["%1",_cust1 select 0],
// format["%1",_cust1 select 1],
// format["%1",_cust2 select 0],
// format["%1",_cust2 select 1]
// ]] call DiscordEmbedBuilder_fnc_buildCfg;
