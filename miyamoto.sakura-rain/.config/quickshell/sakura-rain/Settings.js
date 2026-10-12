.pragma library

// Decodes the resolved settings that `sakura-rain run` exports. Missing fields
// fall back to the Sakura preset so the overlay still renders if the payload is
// absent or malformed.
var FALLBACK = {
  petal_count: 25,
  spawn_rate: 0.5,
  fall_px: 60,
  wind_strength: 0.15,
  depth_spread: 0.6,
  spin: 0.5,
  opacity: 0.75,
  size_min: 12,
  size_max: 28,
  fps: 30,
  pause_on_fullscreen: true,
  avoid_windows: true,
  click_through: true,
  layer: "background",
  palette: {
    petals: [
      { base: "#5C1020", tip: "#A63A50" },
      { base: "#8B1E2D", tip: "#A63A50" },
      { base: "#722F37", tip: "#8B1E2D" },
      { base: "#5C1020", tip: "#722F37" }
    ],
    accent: { base: "#C98E9A", tip: "#EBCFD6" },
    accent_chance: 0.1
  }
}

function parse(json) {
  var parsed = {}
  try {
    parsed = JSON.parse(json || "{}")
  } catch (err) {
    console.warn("sakura-rain: bad SAKURA_RAIN_CONFIG, using defaults:", err)
  }
  var out = {}
  for (var key in FALLBACK) {
    out[key] = (key in parsed) ? parsed[key] : FALLBACK[key]
  }
  return out
}
