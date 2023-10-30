import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.UserProfile;
using Toybox.WatchUi;
using Toybox.Weather;

class DataFieldSection
{
    public var current as DataInfo;
    public var data as Lang.Array = [];
    private var counter;

    function initialize(data) {
        self.data = data as Lang.Array;
        self.counter = 0;
        self.current = self.data[self.counter];
    }

    public function next()
    {
        self.counter++;
        self.counter = self.counter >= self.data.size() ? 0 : self.counter;
        self.current = self.data[self.counter];
    }
}

class DataInfo {
    public var text;
    public var icon;
    public var color = Graphics.COLOR_BLACK;
    public var unit = "";

    function initialize(text, icon) {
        self.text = text;
        self.icon = icon;
    }

    function Update(info as Activity.Info)
    {
    }
}

class HeartRateDataInfo extends DataInfo
{
    function initialize() {
        DataInfo.initialize("0", WatchUi.loadResource(Rez.Drawables.HeartIcon));
        self.unit = "bpm";
    }

    function Update(info as Activity.Info)
    {
        self.text = "0";
        if(info has :currentHeartRate && info.currentHeartRate != null){
            self.text = info.currentHeartRate.format("%d");
        }
    }
}

class PowerDataInfo extends DataInfo
{
    function initialize() {
        DataInfo.initialize("0", WatchUi.loadResource(Rez.Drawables.BoltIcon));
        self.unit = "W";
    }

    function Update(info as Activity.Info)
    {
        self.text = "0";
        if(info has :currentPower && info.currentPower != null){
            self.text = info.currentPower.format("%d");
        }
    }
}

class SpeedDataInfo extends DataInfo
{
    function initialize() {
        DataInfo.initialize("0", WatchUi.loadResource(Rez.Drawables.BoltIcon));
        self.unit = "km/h";
    }

    function Update(info as Activity.Info)
    {
        self.text = "0";
        if(info has :currentSpeed && info.currentSpeed != null){
            self.text = info.currentSpeed.format("%d");
        }
    }
}

class TempDataInfo extends DataInfo
{
    function initialize() {
        DataInfo.initialize("0", WatchUi.loadResource(Rez.Drawables.BoltIcon));
        self.unit = "°C";
    }

    function Update(info as Activity.Info)
    {
        var weather = Weather.getCurrentConditions();

        self.text = "0";
        if(weather != null && weather.temperature != null){
            self.text = weather.temperature.format("%d");
        }
    }
}

class DataChampView extends WatchUi.DataField {

    var CHANGE_INTERVAL = 3;

    var width = 0;
    var height = 0;
    var cellWidth = 0;
    var heartRateColor = Graphics.COLOR_LT_GRAY;
    var powerColor = Graphics.COLOR_LT_GRAY;
    var lastFieldChange = System.getTimer();

    var sections as Lang.Array = [
        new DataFieldSection([new HeartRateDataInfo(),new PowerDataInfo()]),
        new DataFieldSection([new TempDataInfo(),new SpeedDataInfo()]),
        new DataFieldSection([new PowerDataInfo()])
    ];

    function initialize() {
        DataField.initialize();
    }

    function onLayout(dc) {
        self.width = dc.getWidth();
        self.height = dc.getHeight();
        self.cellWidth = self.width / 3;
    }

    function compute(info as Activity.Info) as Void { 
        for( var i = 0; i < self.sections.size(); i++ ) {
            var field = self.sections[i] as DataFieldSection;
            for( var z = 0; z < field.data.size(); z++ ) {
                var data = field.data[z];
                data.Update(info);
            }
        }

        self.heartRateColor = Helper.getHeartRateColor(info);
        self.powerColor = Helper.getPowerColor(info);

        var now = System.getTimer();
        var elapsed = now - self.lastFieldChange;

        if(elapsed >= self.CHANGE_INTERVAL * 1000)
        {
            for( var i = 0; i < self.sections.size(); i++ ) {
                var section = self.sections[i];
                section.next();
            }

            self.lastFieldChange = System.getTimer();
        }
    }

    function getTextWidth(text as String, dc as Dc, font) {
        return dc.getTextDimensions(text, font)[0];
    }

    function getTextHeight(text as String, dc as Dc, font) {
        return dc.getTextDimensions(text, font)[1];
    }

    function drawDataFieldSections(dc as Dc)
    {
        for( var i = 0; i < self.sections.size(); i++ ) {
            var data = self.sections[i].current as DataInfo;

            var fontSize = Graphics.FONT_SYSTEM_NUMBER_HOT;
            var textWidth = self.getTextWidth(data.text, dc, fontSize);
            var textHeight = self.getTextHeight(data.text, dc, fontSize);

            if(textWidth > self.cellWidth)
            {
                fontSize = Graphics.FONT_SYSTEM_NUMBER_MEDIUM;
                textWidth = self.getTextWidth(data.text, dc, fontSize);
                textHeight = self.getTextHeight(data.text, dc, fontSize);
            }

            dc.drawText((self.cellWidth * i) + (self.cellWidth / 2) - (textWidth / 2), 
                (self.height / 2) - (textHeight / 2), 
                fontSize, 
                data.text, 
                Graphics.TEXT_JUSTIFY_LEFT);

            dc.drawText((self.cellWidth * i) + 4, 
                self.height - 14, 
                Graphics.FONT_SYSTEM_TINY, 
                data.unit, 
                Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);

        dc.fillRectangle(0, 0, self.width, self.height);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);

        self.drawDataFieldSections(dc);

        //var transform = new Graphics.AffineTransform();
        //transform.setToScale(0.5, 0.5);

        dc.setColor(self.heartRateColor, Graphics.COLOR_WHITE);
        dc.fillRectangle(1 * self.cellWidth, 16, 2, self.height);
        dc.setColor(self.powerColor, Graphics.COLOR_WHITE);
        dc.fillRectangle(2 * self.cellWidth, 16, 2, self.height);

        var heartIcon = WatchUi.loadResource(Rez.Drawables.HeartIcon);
        var boltIcon = WatchUi.loadResource(Rez.Drawables.BoltIcon);

        dc.drawBitmap2((1 * self.cellWidth) - (heartIcon.getWidth() / 2), 0, heartIcon, {
            :tintColor => self.heartRateColor,
            //:transform => transform
        });

        dc.drawBitmap2((2 * self.cellWidth) - (boltIcon.getWidth() / 2), 0, boltIcon, {
            :tintColor => self.powerColor,
            //:transform => transform
        });
    }
}

// TODO: 
// grade, altitude, cadence, ascent, time, gears, 
// combined battery icon section
// power 3s section