(_this select 0) spawn{
  switch(_this) do {
    case 0: {
      //skipTime (8 - daytime + 24 ) % 24;
      setDate[date select 0, date select 1, date select 2, 8, 0];
    };
    case 1: {
      0 setOvercast 0;
      0 setRain 0;
      forceWeatherChange;
    };
    case 2: {
      0 setFog 0;
      forceWeatherChange;
    };
    //cases 0-2 combined, ideal weather with only one forceWeatherChange
    case 3: {
      [6, "ATTENTION: Server setting time to day..."] remoteExec ["OEC_fnc_broadcast", civilian];
    	uiSleep 7;
      setDate[date select 0, date select 1, date select 2, 8, 0];
      0 setOvercast 0;
      0 setRain 0;
      0 setFog 0;
      forceWeatherChange;
    };
  };
};
