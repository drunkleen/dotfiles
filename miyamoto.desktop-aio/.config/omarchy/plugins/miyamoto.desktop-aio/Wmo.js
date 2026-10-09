.pragma library

// WMO weather interpretation codes -> human condition + Material Symbols name.
// Adapted from Ryoku's lib/weather.js (GPL-3.0). See NOTICE.

function conditionFor(code) {
  code = Number(code);
  if (code === 0) return "Clear";
  if (code === 1) return "Mainly clear";
  if (code === 2) return "Partly cloudy";
  if (code === 3) return "Overcast";
  if (code === 45 || code === 48) return "Fog";
  if (code >= 51 && code <= 57) return "Drizzle";
  if (code >= 61 && code <= 67) return "Rain";
  if (code >= 71 && code <= 77) return "Snow";
  if (code >= 80 && code <= 82) return "Showers";
  if (code >= 85 && code <= 86) return "Snow showers";
  if (code === 95) return "Thunderstorm";
  if (code === 96 || code === 99) return "Thunderstorm";
  return "—";
}

function glyphFor(code) {
  code = Number(code);
  if (code === 0) return "sunny";
  if (code === 1) return "clear_day";
  if (code === 2) return "partly_cloudy_day";
  if (code === 3) return "cloud";
  if (code === 45 || code === 48) return "foggy";
  if (code >= 51 && code <= 57) return "rainy";
  if (code >= 61 && code <= 67) return "rainy";
  if (code >= 71 && code <= 77) return "weather_snowy";
  if (code >= 80 && code <= 82) return "rainy";
  if (code >= 85 && code <= 86) return "weather_snowy";
  if (code === 95 || code === 96 || code === 99) return "thunderstorm";
  return "cloud";
}

function symbolFor(code, isDay) {
  var g = glyphFor(code);
  if (isDay === false || isDay === 0) {
    if (g === "sunny") return "bedtime";
    if (g === "clear_day") return "clear_night";
    if (g === "partly_cloudy_day") return "partly_cloudy_night";
  }
  return g;
}
