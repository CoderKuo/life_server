private ["_object","_score"];
_object = param [0,objnull,[objnull]];
_score = param [1,0,[0]];

_object addscore _score;
_score