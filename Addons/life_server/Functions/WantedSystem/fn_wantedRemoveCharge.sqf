//  File: fn_wantedRemoveCharge.sqf
//  Author: Fusah
//	Description: handles ssssssserver ssssside for removal of charge

private["_uid","_crime","_index","_data","_crimes","_val","_customBounty","_name","_playerNetID"];
_uid = param [0,"",[""]];
_name = param [1,"",[""]];
_crime = param [2,"",[""]];

if(_uid == "" || _crime == "" || _name == "") exitWith {}; //okie dokie

_playerNetID = [_uid] call OES_fnc_getPlayer;
if(_playerNetID != 0) then {
	[[_crime,_uid],"OEC_fnc_updateWantedCharge",_playerNetID,false] spawn OEC_fnc_MP; // yea something cool liek this xdDDDdxDxd
};

//What is the crime?
_crime = switch(_crime) do {
 	case "车辆杀人": {["Vehicular Manslaughter",35000]};
	case "Manslaughter": {["Manslaughter",30000]};
	case "Escaping Jail": {["Escaping Jail",56000]};
	case "Assault": {["Assault",500]};
	case "Attempted Rape": {["Attempted Rape",3000]};
	case "Attempted Grand Theft Auto": {["Attempted Grand Theft Auto",5000]};
	case "Use of illegal explosives": {["Use of illegal explosives",8000]};
	case "Robbery": {["Robbery",30000]};
	case "Kidnapping": {["Kidnapping",11250]};
	case "Attempted Kidnapping": {["Attempted Kidnapping",4000]};
	case "Grand Theft Auto": {["Grand Theft Auto",17500]};
	case "Petty Theft": {["Petty Theft",7000]};
	case "Hit and Run": {["Hit and Run",7500]};
	case "Possession of Contraband": {["Possession of Contraband",31500]};
	case "Drug Possession": {["Drug Possession",45000]};
	case "Drug Trafficking": {["Drug Trafficking",34000]};
	case "Burglary": {["Burglary",175000]};
	case "Organ Dealing": {["Organ Dealing",17000]};
	case "Driving w/o license": {["Driving w/o license",6250]};
	case "Driving w/o lights": {["Driving w/o lights",2000]};
	case "Attp. Robbery": {["Attp. Robbery",8000]};
	case "Veh. Theft": {["Veh. Theft", 17500]};
	case "Attp. Veh. Theft": {["Attp. Veh. Theft",5000]};
	case "Attp. Manslaughter": {["Attp. Manslaughter",26250]};
	case "Speeding": {["Speeding",1500]};
	case "Reckless Driving": {["Reckless Driving",3000]};
	case "Pos. of APD Equip.": {["Pos. of APD Equip.",25500]};
	case "Ilg. Aerial Veh. Landing": {["Ilg. Aerial Veh. Landing",48750]};
	case "Operating an ilg. veh.": {["Operating an ilg. veh.",31500]};
	case "Hit and Run": {["Hit and Run",7500]};
	case "Resisting Arrest": {["Resisting Arrest",16500]};
	case "Verbal Threats": {["Verbal Threats",8000]};
	case "Verbal Insults": {["Verbal Insults",3000]};
	case "Entering a Police Area": {["Entering a Police Area",6000]};
	case "Destruction of property": {["Destruction of property",63750]};
	case "Pos. of firearms w/o license": {["Pos. of firearms w/o license",11000]};
	case "Pos. of an ilg. weapon": {["Pos. of an ilg. weapon",12000]};
	case "Use of firearms within city": {["Use of firearms within city",5000]};
	case "Hostage Situation": {["Hostage Situation",86500]};
	case "Terrorist Acts": {["Terrorist Acts",93750]};
	case "Flying/Hovering below 150m": {["Flying/Hovering below 150m",15000]};
	case "Aiding in jail break": {["Aiding in jail break",86000]};
	case "Flying w/o a pilot license": {["Flying w/o a pilot license",10500]};
	case "Aiding in Reserve Robbery": {["Aiding in Reserve Robbery",112500]};
	case "Attp. Reserve Robbery": {["Attp. Reserve Robbery",82500]};
	case "Insurance Fraud": {["Insurance Fraud",1500]};
	case "Disobeying an Officer": {["Disobeying an Officer",8000]};
	case "Obstruction of Traffic": {["Obstruction of Traffic",4625]};
	case "Weapon Trafficking": {["Weapon Trafficking",15125]};
	case "Avoiding a Checkpoint": {["Avoiding a Checkpoint",30000]};
	case "Usage of Drugs in Public": {["Usage of Drugs in Public",10000]};
	case "Disturbing the Peace": {["Disturbing the Peace",1125]};
	case "LEO Manslaughter": {["LEO Manslaughter",37500]};
	case "Gov't Cyber Attack": {["Gov't Cyber Attack",30000]};
	case "Destruction of Gov't Property": {["Destruction of Gov't Property",63750]};
	case "Party to a Crime": {["Party to a Crime",15000]};
	case "Obstruction of Justice": {["Obstruction of Justice",15750]};
	case "Misuse of Emergency System": {["Misuse of Emergency System",40000]};
	case "Aiding in BW Robbery": {["Aiding in BW Robbery",112500]};
	case "Gas Station Robbery": {["Gas Station Robbery",18750]};
	case "Organ Harvesting": {["Organ Harvesting",11250]};
	case "Pos. of Illegal Organ": {["Pos. of Illegal Organ",22500]};
	case "Gang Homicide": {["Gang Homicide",25000]};
	case "Unlawful Taser Usage": {["Unlawful Taser Usage",30000]};
	case "Attp. BW Robbery": {["Attp. BW Robbery",82500]};
	case "Attp. Jail Break": {["Attp. Jail Break",63750]};
	case "Kidnapping Gov't Official": {["Kidnapping Gov't Official",92750]};
	case "Aiding in Pharm. Robbery": {["Aiding in Pharm. Robbery",40000]};
	case "Pos. of Explosives": {["Pos. of Explosives",30000]};
	case "Flying w/o Collision Lights": {["Flying w/o Collision Lights",2000]};
	case "Attp. Bank Robbery": {["Attp. Bank Robbery",32500]};
	case "Aiding in Bank Robbery": {["Aiding in Bank Robbery",81250]};
	case "Pos. of Ilg. Equipment": {["Pos. of Ilg. Equipment",15000]};
	case "Public Urination": {["Public Urination",2500]};
	case "Titan Hit": {["Titan Hit",15000]};
	default {[];};
};

if(count _crime == 0) exitWith {}; //Not our information being passed...
//_crime set[1,(_crime select 1)]; why??
//Search the wanted list to make sure they are not on it.
_index = [_uid,life_wanted_list] call OEC_fnc_index;
if(_index == -1) exitWith {}; //well all that work for nothing...
_data = life_wanted_list select _index;
_crimes = _data select 2;

{
	if ((_x select 0) isEqualTo (_crime select 0)) exitWith {
		if((_x select 1) > 1) then {
			_x set [1,(_x select 1) - 1];
		}else{
			_crimes deleteAt _forEachIndex;
		};
	};
}forEach _crimes;

//if (_crimes find (_crime select 0) == -1) exitWith {}; // prevent 2 retards from pardoning x1 of a crime
//_crimes deleteAt (_crimes find (_crime select 0)); //yeet
_val = (_data select 3) - (_crime select 1);
if (count (_crimes) == 0) then { //jst to make sure someone with no crimes isnt in the database ^___^
	life_wanted_list set[_index,-1];
	life_wanted_list deleteAt (life_wanted_list find -1);
} else {
	life_wanted_list set[_index,[_name,_uid,_crimes,_val]];
};
