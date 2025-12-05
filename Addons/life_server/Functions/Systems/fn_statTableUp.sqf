// File: fn_statTableUp.sqf
// Author: Jesse "tkcjesse" Schultz
// Description: Sends data to stored procedure to update the stats table in DB
params [
	["_uid","",[""]],
	["_arr",[],[[]]]
];

private _check = (_uid find "'" != -1);
if (_check) exitWith {};


if (count _arr isEqualTo 0 || _uid isEqualTo "") exitWith {};

{
	if (_x > 999999) then {
		_arr set [_forEachIndex,([_x] call OES_fnc_numberSafe)];
	};
} forEach _arr;

[format["CALL insertStatM(%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20,%21,%22,%23,%24,%25,%26,%27,%28,%29,%30,%31,%32,%33,%34,%35,%36,%37,%38,%39,%40,%41,%42,%43,%44,%45,%46,%47,%48,%49,%50,%51,%52,%53,%54,%55,%56,%57,%58,%59,%60,%61,%62,%63,%64,%65,%66,%67,%68,%69,%70,%71,%72,%73,%74,%75,%76,%77,%78,%79)",_uid,(_arr select 0),(_arr select 1),(_arr select 2),(_arr select 3),(_arr select 4),(_arr select 5),(_arr select 6),(_arr select 7),(_arr select 8),(_arr select 9),(_arr select 10),(_arr select 11),(_arr select 12),(_arr select 13),(_arr select 14),(_arr select 15),(_arr select 16),(_arr select 17),(_arr select 18),(_arr select 19),(_arr select 20),(_arr select 21),(_arr select 22),(_arr select 23),(_arr select 24),(_arr select 25),(_arr select 26),(_arr select 27),(_arr select 28),(_arr select 29),(_arr select 30),(_arr select 31),(_arr select 32),(_arr select 33),(_arr select 34),(_arr select 35),(_arr select 36),(_arr select 37),(_arr select 38),(_arr select 39),(_arr select 40),(_arr select 41),(_arr select 42),(_arr select 43),(_arr select 44),(_arr select 45),(_arr select 46),(_arr select 47),(_arr select 48),(_arr select 49),(_arr select 50),(_arr select 51),(_arr select 52),(_arr select 53),(_arr select 54),(_arr select 55),(_arr select 56),(_arr select 57),(_arr select 58),(_arr select 59),(_arr select 60),(_arr select 61),(_arr select 62),(_arr select 63),(_arr select 64),(_arr select 65),(_arr select 66),(_arr select 67),(_arr select 68),(_arr select 69),(_arr select 70),(_arr select 71),(_arr select 72),(_arr select 73),(_arr select 74),(_arr select 75),(_arr select 76),(_arr select 77)],1] spawn OES_fnc_asyncCall;
