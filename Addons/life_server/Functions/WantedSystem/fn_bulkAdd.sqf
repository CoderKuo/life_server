//	File: fn_bulkAdd.sqf
//	Author: Poseidon
//	Description: Adds all the players saved crimes to the wanted list

private["_uid","_crimes","_name","_index","_bounty","_counter","_crimeString","_crimesOnly","_type","_i"];
_uid = param [0,"",[""]];
_name = param [1,"",[""]];
_crimes = param [2,[],[[]]];
if(_uid == "" || _name == "") exitWith {};

//check to see if wanted, then wipe them so you can add back all crimes, or add back none if pardoned on a diff server
_index = [_uid,life_wanted_list] call OEC_fnc_index;

if(_index != -1) then {
	life_wanted_list set[_index,-1];
	life_wanted_list = life_wanted_list - [-1];
};

_bounty  = _crimes select 0;
if(_bounty < 1) exitWith {};

_crimes set[0,-1];
_crimes = _crimes - [-1];
_counter = 1;
_crimeString = [];
_type = "";
{
	_type = switch(_counter) do	{
		case 1: {"车辆杀人"};
		case 2: {"过失杀人"};
		case 3: {"越狱"};
		case 4: {"攻击"};
		case 5: {"强奸未遂"};
		case 6: {"企图盗窃汽车"};
		case 7: {"使用非法爆炸物"};
		case 8: {"抢劫"};
		case 9: {"绑架"};
		case 10: {"绑架未遂"};
		case 11: {"侠盗猎车手"};
		case 12: {"小偷小摸"};
		case 13: {"肇事逃逸"};
		case 14: {"持有违禁品"};
		case 15: {"藏毒"};
		case 16: {"贩毒"};
		case 17: {"盗窃"};
		case 18: {"器官买卖"};
		case 19: {"无驾照驾驶"};
		case 20: {"无灯驾驶"};
		case 21: {"收件人。抢劫"};
		case 22: {"车辆。盗窃"};
		case 23: {"收件人。车辆。盗窃"};
		case 24: {"收件人。过失杀人"};
		case 25: {"超速行驶"};
		case 26: {"鲁莽驾驶"};
		case 27: {"APD设备位置."};
		case 28: {"伊尔格。空中车辆。着陆"};
		case 29: {"操作ilg。车辆."};
		case 30: {"肇事逃逸"};
		case 31: {"拒捕"};
		case 32: {"口头威胁"};
		case 33: {"言语侮辱"};
		case 34: {"进入警区"};
		case 35: {"毁坏财产"};
		case 36: {"枪支w.o许可证位置"};
		case 37: {"ilg的位置。武器"};
		case 38: {"在城市内使用枪支"};
		case 39: {"人质事件"};
		case 40: {"恐怖行为"};
		case 41: {"飞行/悬停在150米以下"};
		case 42: {"协助越狱"};
		case 43: {"无飞行员执照飞行"};
		case 44: {"协助预备队抢劫"};
		case 45: {"收件人。预备抢劫"};
		case 46: {"保险欺诈"};
		case 47: {"不服从军官"};
		case 48: {"交通阻塞"};
		case 49: {"武器贩运"};
		case 50: {"避开检查站"};
		case 51: {"公众用药"};
		case 52: {"扰乱治安"};
		case 53: {"利奥过失杀人案"};
		case 54: {"政府网络攻击"};
		case 55: {"破坏政府财产"};
		case 56: {"犯罪的一方"};
		case 57: {"妨碍司法公正"};
		case 58: {"应急系统误用"};
		case 59: {"协助抢劫"};
		case 60: {"抢劫加油站"};
		case 61: {"器官采集"};
		case 62: {"非法器官位置"};
		case 63: {"帮派杀人案"};
		case 64: {"非法使用泰瑟枪"};
		case 65: {"收件人。BW抢劫"};
		case 66: {"收件人。越狱"};
		case 67: {"绑架政府官员"};
		case 68: {"协助药学。抢劫"};
		case 69: {"炸药位置"};
		case 70: {"无碰撞灯飞行"};
		case 71: {"收件人。抢银行"};
		case 72: {"协助抢劫银行"};
		case 73: {"Ilg位置。设备"};
		case 74: {"公共小便"};
		case 75: {"泰坦命中"};
	};

	if (_x > 0) then {
		_crimeString pushBack [_type,_x];
	};
	_counter = _counter + 1;

} forEach _crimes;

life_wanted_list pushBack [_name,_uid,_crimeString,_bounty];
