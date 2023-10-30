import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;

using Toybox.UserProfile;

class Helper
{
    public static function getPowerColor(info as Activity.Info)
    {
        var ftp = 200;

        if(info has :currentPower && info.currentPower != null){
            var power = info.currentPower;
            
            var percent = (power * 100) / ftp;

            if(percent < 60)
            {
                return Graphics.COLOR_LT_GRAY;
            }
            if(percent < 80)
            {
                return Graphics.COLOR_BLUE;
            }
            if(percent < 91)
            {
                return Graphics.COLOR_GREEN;
            }
            if(percent < 105)
            {
                return Graphics.COLOR_ORANGE;
            }
            
            return Graphics.COLOR_RED;
        }

        return Graphics.COLOR_LT_GRAY;
    }

    public static function getHeartRateColor(info as Activity.Info)
    {
        var hrZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_BIKING);

        var hrZoneColors = [Graphics.COLOR_LT_GRAY,
            Graphics.COLOR_BLUE,
            Graphics.COLOR_GREEN, 
            Graphics.COLOR_ORANGE,
            Graphics.COLOR_RED,
            Graphics.COLOR_RED];

        if(info has :currentHeartRate && info.currentHeartRate != null){
            var hr = info.currentHeartRate;

            for( var i = 0; i < hrZones.size(); i++ ) {
                var zone = hrZones[i];
                if(hr <= zone)
                {
                    return hrZoneColors[i];
                }
            }
        }

        return hrZoneColors[0];
    }
}