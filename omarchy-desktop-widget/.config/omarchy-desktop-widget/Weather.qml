pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "Wmo.js" as Wmo

// Weather via Open-Meteo (no API key). Geocodes the configured city once,
// then polls the forecast on the configured interval. Metric by default.
QtObject {
  id: root

  property bool available: false
  property string status: "loading"        // loading | ready | error
  property string errorText: ""
  property string placeName: ""
  property real lat: NaN
  property real lon: NaN

  property var current: null
  property var daily: []

  readonly property string city: root.placeName !== "" ? root.placeName : Config.city
  readonly property bool isDay: root.current ? (Number(root.current.is_day) === 1) : true
  readonly property int code: root.current ? Number(root.current.weather_code) : 0

  readonly property int tempNow: root.current ? Math.round(Number(root.current.temperature_2m)) : 0
  readonly property string temp: root.current ? (root.tempNow + "\u00b0") : "\u2014\u00b0"
  readonly property int humidity: root.current ? Math.round(Number(root.current.relative_humidity_2m)) : 0
  readonly property int feels: root.current ? Math.round(Number(root.current.apparent_temperature)) : 0
  readonly property real wind: root.current ? Number(root.current.wind_speed_10m) : 0

  readonly property string condition: Wmo.conditionFor(root.code)
  readonly property string glyph: Wmo.symbolFor(root.code, root.isDay)

  function retry() {
    if (isFinite(root.lat) && isFinite(root.lon)) root.forecast();
    else root.geocode();
  }

  function geocode() {
    root.status = "loading";
    root.errorText = "";
    geoProc.running = true;
  }

  function forecast() {
    fcstProc.running = true;
  }

  property Process geoProc: Process {
    command: ["curl", "-fsSL", "--max-time", "12",
      "https://geocoding-api.open-meteo.com/v1/search?count=1&language=en&format=json&name="
        + encodeURIComponent(Config.city)]
    stdout: StdioCollector {
      id: geoOut
      waitForEnd: true
    }
    onExited: function(code, status) {
      if (code !== 0) {
        root.status = "error";
        root.errorText = "Location lookup failed";
        return;
      }
      try {
        var o = JSON.parse(String(geoOut.text || "{}"));
        if (!o.results || o.results.length === 0) {
          root.status = "error";
          root.errorText = "City not found: " + Config.city;
          return;
        }
        var r = o.results[0];
        root.lat = Number(r.latitude);
        root.lon = Number(r.longitude);
        root.placeName = r.name || Config.city;
        root.forecast();
      } catch (e) {
        root.status = "error";
        root.errorText = "Bad location data";
      }
    }
  }

  property Process fcstProc: Process {
    command: ["curl", "-fsSL", "--max-time", "12",
      "https://api.open-meteo.com/v1/forecast?timezone=auto&forecast_days=3"
        + "&latitude=" + root.lat + "&longitude=" + root.lon
        + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m"
        + "&daily=weather_code,temperature_2m_max,temperature_2m_min"
        + (Config.units === "imperial" ? "&temperature_unit=fahrenheit&wind_speed_unit=mph" : "")]
    stdout: StdioCollector {
      id: fcstOut
      waitForEnd: true
    }
    onExited: function(code, status) {
      if (code !== 0) {
        root.status = "error";
        root.errorText = "Weather fetch failed";
        return;
      }
      try {
        var o = JSON.parse(String(fcstOut.text || "{}"));
        root.current = o.current || null;
        var out = [];
        if (o.daily && o.daily.time) {
          for (var i = 0; i < o.daily.time.length; i++) {
            out.push({
              day: Qt.formatDate(new Date(o.daily.time[i]), "ddd"),
              hi: Math.round(Number(o.daily.temperature_2m_max[i])),
              lo: Math.round(Number(o.daily.temperature_2m_min[i])),
              code: Number(o.daily.weather_code[i])
            });
          }
        }
        root.daily = out;
        root.available = root.current !== null;
        root.status = root.available ? "ready" : "error";
        root.errorText = root.available ? "" : "No weather data";
      } catch (e) {
        root.status = "error";
        root.errorText = "Bad weather data";
      }
    }
  }

  property Timer refresh: Timer {
    interval: Math.max(60, Config.refreshSeconds) * 1000
    repeat: true
    running: true
    onTriggered: root.retry()
  }

  property Connections configWatch: Connections {
    target: Config
    function onCityChanged() { root.placeName = ""; root.geocode() }
  }

  Component.onCompleted: root.geocode()
}
