//  File: fn_bankDeaths.sqf
//	Author: Fraali
//	Description: Increases how many cops have died at the current bank
//  Adds 1 to how many unique cops have died at the bank, and waits until it is no longer active to reset itself

oev_bankDeaths = oev_bankDeaths + 1;
[] spawn{
  if (oev_bankDeaths <= 1) then {
    waitUntil {
      uiSleep 5;
      (((altis_bank getVariable ["bankCooldown", 0]) <= serverTime) && ((altis_bank_1 getVariable ["bankCooldown", 0]) <= serverTime) && ((altis_bank_2 getVariable ["bankCooldown", 0]) <= serverTime) &&
      !((altis_bank getVariable ["chargeplaced",false]) || (altis_bank_1 getVariable ["chargeplaced",false]) || (altis_bank_2 getVariable ["chargeplaced",false])));
    };
    oev_bankDeaths = 0;
  };
};
