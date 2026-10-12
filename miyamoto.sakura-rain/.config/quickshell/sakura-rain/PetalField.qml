import QtQuick

// Owns the petal pool for one monitor and advances it from a single timer.
// Dormant petals are neither stepped nor drawn. A spawn timer releases them
// from above the top edge at settings.spawn_rate per second.
Item {
  id: field

  required property var settings
  // False while the surface is hidden (fullscreen, pause): the timer stops, so
  // nothing wakes up or redraws.
  property bool running: true
  // Window rectangles to keep petals out from under, in this field's coordinates.
  property var obstacles: []

  readonly property int count: settings.petal_count
  // Motion is tuned at 1440 px of height and scaled to each monitor.
  readonly property real scaleY: height / 1440

  property real clock: 0
  property real spawnCooldown: 0
  property real lastMs: 0
  property bool seeded: false

  onWidthChanged: seedOnce()
  onHeightChanged: seedOnce()

  // Start with most of the pool already in flight so the first frame isn't empty.
  function seedOnce() {
    if (seeded || width <= 0 || height <= 0) return
    seeded = true
    const initial = Math.max(1, Math.round(count * 0.8))
    for (var i = 0; i < initial; i++) {
      const petal = petals.itemAt(i)
      if (petal) petal.spawn(true)
    }
  }

  function spawnOne() {
    for (var i = 0; i < count; i++) {
      const petal = petals.itemAt(i)
      if (petal && !petal.alive) {
        petal.spawn(false)
        return
      }
    }
  }

  function step() {
    const now = Date.now()
    // Measured dt keeps motion true if the timer fires late; clamped so a
    // stall never teleports petals.
    const dt = lastMs === 0 ? 1 / settings.fps : Math.min((now - lastMs) / 1000, 0.1)
    lastMs = now
    clock += dt

    // Wind swells slowly; two incommensurate sines keep it from looking periodic.
    const wind = settings.wind_strength
      * (0.7 + 0.2 * Math.sin(clock * 0.09) + 0.1 * Math.sin(clock * 0.23 + 1.3))

    for (var i = 0; i < count; i++) {
      const petal = petals.itemAt(i)
      if (petal && petal.alive) petal.advance(dt, wind, width, height, obstacles)
    }

    if (settings.spawn_rate > 0) {
      spawnCooldown -= dt
      if (spawnCooldown <= 0) {
        spawnOne()
        // Jittered interval so releases never fall into a visible rhythm.
        spawnCooldown = (1 / settings.spawn_rate) * (0.5 + Math.random())
      }
    }
  }

  Timer {
    id: ticker
    interval: Math.round(1000 / field.settings.fps)
    repeat: true
    running: field.running && field.width > 0 && field.height > 0
    onRunningChanged: field.lastMs = 0
    onTriggered: field.step()
  }

  Repeater {
    id: petals
    model: field.count

    Petal {
      owner: field
    }
  }
}
