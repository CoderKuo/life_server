//	File: fn_wantedAdd.sqf
//	Author: Bryan "Tonic" Boardwine
//	Description: Adds or appends a unit to the wanted list.
params [
	["_uid","",[""]],
	["_name","",[""]],
	["_type","",[""]],
	["_player",objNull,[objNull]],
	["_customBounty",-1,[0]]
];

if(_uid isEqualTo "" || _type isEqualTo "" || _name isEqualTo "") exitWith {};

private _playerNetID = [_uid] call OES_fnc_getPlayer;
if !(_playerNetID isEqualTo 0) then {
	[parseNumber(_type),_uid] remoteExec ["OEC_fnc_updateWanted",_playerNetID,false];
};

//What is the crime?
_type = switch(_type) do {
 	case "1": {["车辆杀人",35000]};
	case "2": {["过失杀人",30000]};
	case "3": {["越狱",56000]};
	case "4": {["攻击",500]};
	case "5": {["强奸未遂",3000]};
	case "6": {["企图盗窃汽车",5000]};
	case "7": {["使用非法爆炸物",8000]};
	case "8": {["抢劫",30000]};
	case "9": {["绑架",11250]};
	case "10": {["绑架未遂",4000]};
	case "11": {["侠盗猎车手",17500]};
	case "12": {["小偷小摸",7000]};
	case "13": {["肇事逃逸",7500]};
	case "14": {["持有违禁品",31500]};
	case "15": {["藏毒",45000]};
	case "16": {["贩毒",34000]};
	case "17": {["盗窃",175000]};
	case "18": {["器官买卖",17000]};
	case "19": {["无驾照驾驶",6250]};
	case "20": {["无灯驾驶",2000]};
	case "21": {["收件人。抢劫",8000]};
	case "22": {["车辆。盗窃", 17500]};
	case "23": {["Attp. Veh. Theft",5000]};
	case "24": {["Attp. Manslaughter",26250]};
	case "25": {["Speeding",1500]};
	case "26": {["Reckless Driving",3000]};
	case "27": {["Pos. of APD Equip.",25500]};
	case "28": {["Ilg. Aerial Veh. Landing",48750]};
	case "29": {["Operating an ilg. veh.",31500]};
	case "30": {["Hit and Run",7500]};
	case "31": {["Resisting Arrest",16500]};
	case "32": {["Verbal Threats",8000]};
	case "33": {["Verbal Insults",3000]};
	case "34": {["Entering a Police Area",6000]};
	case "35": {["Destruction of property",63750]};
	case "36": {["Pos. of firearms w/o license",11000]};
	case "37": {["Pos. of an ilg. weapon",12000]};
	case "38": {["Use of firearms within city",5000]};
	case "39": {["Hostage Situation",86500]};
	case "40": {["Terrorist Acts",93750]};
	case "41": {["Flying/Hovering below 150m",15000]};
	case "42": {["Aiding in jail break",86000]};
	case "43": {["Flying w/o a pilot license",10500]};
	case "44": {["Aiding in Reserve Robbery",112500]};
	case "45": {["Attp. Reserve Robbery",82500]};
	case "46": {["保险欺诈",1500]};
	case "47": {["不服从军官",8000]};
	case "48": {["交通阻塞",4625]};
	case "49": {["武器贩运",15125]};
	case "50": {["避开检查站",30000]};
	case "51": {["公众用药",10000]};
	case "52": {["扰乱治安",1125]};
	case "53": {["利奥过失杀人案",37500]};
	case "54": {["政府网络攻击",30000]};
	case "55": {["破坏政府财产",63750]};
	case "56": {["犯罪的一方",15000]};
	case "57": {["妨碍司法公正",15750]};
	case "58": {["应急系统误用",40000]};
	case "59": {["协助抢劫",112500]};
	case "60": {["抢劫加油站",18750]};
	case "61": {["器官采集",11250]};
	case "62": {["非法器官位置",22500]};
	case "63": {["帮派杀人案",15000]};
	case "64": {["非法使用泰瑟枪",30000]};
	case "65": {["收件人。BW抢劫",82500]};
	case "66": {["收件人。越狱",63750]};
	case "67": {["绑架政府官员",92750]};
	case "68": {["协助药学。抢劫",40000]};
	case "69": {["炸药位置",30000]};
	case "70": {["无碰撞灯飞行",2000]};
	case "71": {["收件人。抢银行",32500]};
	case "72": {["协助抢劫银行",81250]};
	case "73": {["Ilg位置。设备",15000]};
	case "74": {["公共小便",2500]};
  case "75": {["电击枪命中",15000]};
	default {[]};
};

private["_data","_crimes","_val"];

if (count _type isEqualTo 0) exitWith {};
_type set [1,(_type select 1)];
//Is there a custom bounty being sent? Set that as the pricing.
if !(_customBounty isEqualTo -1) then {_type set [1,_customBounty];};
//Search the wanted list to make sure they are not on it.
private _index = [_uid,life_wanted_list] call OEC_fnc_index;
_addedCharge = false;
if !(_index isEqualTo -1) then {
	_data = life_wanted_list select _index;
	_crimes = _data select 2;

	{
		if ((_x select 0) isEqualTo (_type select 0)) then {
			_x set [1,(_x select 1) + 1];
			_addedCharge = true;
		};
	} forEach _crimes;

if !(_addedCharge) then {
	_crimes pushBack [_type select 0,1];
};
	life_wanted_list set [_index,[_name,_uid,_crimes,((_type select 1) + (_data select 3))]];
} else {
	life_wanted_list pushBack [_name,_uid,[[(_type select 0),1]],(_type select 1)];
};
