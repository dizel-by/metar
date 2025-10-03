import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.PersistedContent;
import Toybox.Application;
using Toybox.System;

class METARView extends WatchUi.View {

    var metarLabel;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

        metarLabel = findDrawableById("id_metarLabel") as WatchUi.Text;

        if (metarLabel != null) {
            metarLabel.setFont(Graphics.FONT_XTINY);
            metarLabel.setText("Loading METAR…");
        }
    }

    function onShow() as Void {
        fetchMetar();
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    function onHide() as Void {
    }

    function fetchMetar() as Void {
        var code = Application.Properties.getValue("airport_code") as Lang.String or Null;
        code = code.toUpper();
        if (code.length() != 4) {
            code = "LBWN";
        }

        var url = "https://metar.vatsim.net/" + code;
        Communications.makeWebRequest(url, null, { :headers => { "Accept" => "text/plain" } }, method(:onMetarResponse));
    }

    function onMetarResponse(responseCode as Lang.Number, data as Null or Lang.Dictionary or Lang.String or PersistedContent.Iterator) as Void {
        var text;
        if (responseCode == 200 && data != null) {
            var s = data.toString();
            text = wrapText(s);
        } else {
            text = "Failed to load (" + responseCode + ")";
        }

        if (metarLabel != null) {
            metarLabel.setText(text);
        }

        WatchUi.requestUpdate();
    }
}

function wrapText(s as Lang.String) as Lang.String {
    var n = s.length();
    var res = "";
    var i = 0;
    var o = 0;

    var arr = s.toCharArray();

    while (i < n) {
        if (arr[i].toNumber() == 32) {
            if (o == 1) {
            res += "\n";
            } else {
                res += " ";
            }
            o = 1 - o;
        } else {
        res += arr[i];
        }
        System.println(arr[i].toNumber());
        i++;
    }

    return res;
}
