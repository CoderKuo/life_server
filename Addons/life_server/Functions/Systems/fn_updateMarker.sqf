//	File: fn_updateMarkers.sqf
//	Author: Jesse "tkcjesse" Schultz
//	Description: Changes the color/text/etc of a map marker server side to update for all current & JIP players.

params [
	["_marker","",[""]],
	["_color","",[""]],
	["_text","",[""]],
	["_type","",[""]]
];

if (_marker isEqualTo "" || {_color isEqualTo ""} || {_text isEqualTo ""} || {_type isEqualTo ""}) exitWith {};

_marker setMarkerColor _color;
_marker setMarkerText _text;
_marker setMarkerType _type;