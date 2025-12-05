class DefaultEventhandlers;
class CfgPatches {
	class life_headless_client {
		units[] = {};
		weapons[] = {};
		requiredAddons[] = {"A3_Data_F"};
		fileName = "life_hc.pbo";
		author[]= {"Booty Ass"};
	};
};

class CfgFunctions {
	class Headless_Client {
		tag = "HC";
		class MySQL {
			file = "\life_hc\Functions\MySQL";
			class asyncCall {};
			class bool {};
			class dateToArray {};
			class insertRequest {};
			class insertVehicle {};
			class mresArray {};
			class mresString {};
			class mresToArray {};
			class numberSafe {};
			class updatePartial {};
			class updateRequest {};
			class updateVehOwnership {};
		};
    class Systems {
      file = "\life_hc\Functions\Systems";
      class logIt {};
			class diagLog {};
    };
	};
};
