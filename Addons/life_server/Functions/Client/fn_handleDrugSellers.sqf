_mode = _this select 0;

switch(_mode) do {
  case 0: {
    _dealerIndex = _this select 1;
    _names = "";
    {
      if(serverTime - (_x select 2) < 1800 && (getPlayerUID (_x select 0) isEqualTo (_x select 1))) then {
        [(_x select 1), name (_x select 0), "16", (_x select 0)] spawn OES_fnc_wantedAdd;
        _names = _names + format["%1<br/>",name (_x select 0)];
      };
    } forEach (oev_drug_sellers select _dealerIndex);
    
    if(_names isEqualTo "") then {
      [localize "STR_Cop_DealerQuestion"] remoteExec["hint",remoteExecutedOwner];
    } else {
      [parseText format[(localize "STR_Cop_DealerMSG")+ "<br/><br/>%1",_names]] remoteExec["hint",remoteExecutedOwner];
    };
    
    oev_drug_sellers set[_dealerIndex, []];
  };
  case 1: {
    _playerObj = _this select 1;
    _playerUID = _this select 2;
    _timeSold = _this select 3;
    _dealerIndex = _this select 4;
    _index = -1;
    {
      if((_x select 1) isEqualTo _playerUID) exitWith {
        _index = _forEachIndex;
      };
    } forEach (oev_drug_sellers select _dealerIndex);
    if(_index isEqualTo -1) then {
      (oev_drug_sellers select _dealerIndex) pushBack [_playerObj, _playerUID, _timeSold, _dealerIndex];
    } else {
      (oev_drug_sellers select _dealerIndex) set[_index,[_playerObj, _playerUID, _timeSold, _dealerIndex]]; 
    };
  };
};