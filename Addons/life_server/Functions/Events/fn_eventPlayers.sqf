// File: fn_inEvent
// Author: Fraali
// Increments/decrements when player joins or leaves an event serverside

params [
  ["_unit", objNull,[objNull]],
  ["_increment","",[""]],
  ["_count", -1,[]]
];
_curEvent = missionNamespace getVariable ["currentEvent", "no"];
switch (_increment) do{
  case "join": {
    if (life_eventPlayers >= 24) exitWith {"Sorry, the event is full!" remoteExec ["hint", owner _unit];};
    _unit setVariable ["isInEvent",[_curEvent],true];
    hint "You have joined the event!";
    systemChat "You have joined the event!";
    life_eventPlayers = life_eventPlayers + 1;
  }; // Join the player to event, the check is just a failsafe

  case "leave": {
    _unit setVariable ["isInEvent",["no"],true];
    hint "You have left the event!";
    systemChat "You have left the event!";
    life_eventPlayers = life_eventPlayers - 1;
  }; //Leave the player from the event
  
  case "remSel": {life_eventPlayers = life_eventPlayers - _count;}; //Removes selected people from event
  case "remAll": {life_eventPlayers = 0;}; //Removes all players from event
  default{};
};
