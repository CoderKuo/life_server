//	Author:
//		Joris-Jan van 't Land, optimized by Karel Moricky, optimised by Killzone_Kid
//
//	Description:
//		Select a random item from an array, taking into account item weight
//
//	Parameters:
//		0: ARRAY - items array (Array of ANYTHING)
//		1: ARRAY - weights array (Array of NUMBERS)
//
//	Returns:
//		ANYTHING - selected item
//
//	Example:
//		[["apples","pears","bananas","diamonds"],[0.3,0.2,0.4,0.1]] call BIS_fnc_selectRandomWeighted
//
//	NOTE:
//		The weights don't have to total to 1
//		The length of weights and items arrays may not match, in which case the shortest array is used for length


/// --- validate general input
#define paramsCheck(input,method,template) if !(input method template) exitWith {[input, #method, template] call (missionNamespace getVariable "BIS_fnc_errorParamsType")};
#define arr [[],[]]
paramsCheck(_this,isEqualTypeParams,arr)

params ["_items", "_weights"];
if !(_weights isEqualTypeAll 0) exitWith {"Weights (1) must be an array of Numbers" call BIS_fnc_error; nil};

_weights = _weights select [0, count _weights min count _items];

private _totalWeight = 0;
{_totalWeight = _totalWeight + (_x max 0)} count _weights;
if (_totalWeight isEqualTo 0) exitWith {["The sum of Weights (1) must be larger than 0"] call BIS_fnc_error; nil};

private _random = random _totalWeight;
{
	_random = _random - (_x max 0);
	if (_random <= 0) exitWith {[_items select _forEachIndex, _forEachIndex]};//small addition to return the items index that was selected
}
forEach _weights;