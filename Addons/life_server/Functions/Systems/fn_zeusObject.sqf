private["_mode","_object"];
_mode = _this select 0;
_object = _this select 1;

switch(_mode) do {
	case "add": {zeus addCuratorEditableObjects [[_object],true];};
	case "remove": {zeus removeCuratorEditableObjects [[_object],true]};
	case "addAll": {
		{
			zeus addCuratorEditableObjects [[_x],true]
		}foreach playableUnits
	};
	case "removeAll": {
		{
			zeus removeCuratorEditableObjects [[_x],true]
		}foreach curatorEditableObjects zeus;
	};
};