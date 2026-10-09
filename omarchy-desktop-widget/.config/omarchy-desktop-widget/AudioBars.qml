pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Shared cava spectrum feed (PipeWire playback monitor). Owner-refcounted, so
// the analyser runs only while a visible surface claims it. Settles flat when
// frames stop arriving. Adapted from Ryoku's AudioBars.qml (GPL-3.0).
QtObject {
  id: root

  property var activeOwners: []
  readonly property bool active: activeOwners.length > 0

  function setActive(owner, enabled) {
    var next = activeOwners.slice();
    var i = next.indexOf(owner);
    if (enabled && i < 0) next.push(owner);
    else if (!enabled && i >= 0) next.splice(i, 1);
    root.activeOwners = next;
  }

  readonly property int bars: Math.max(8, Config.bars)
  readonly property int fps: Math.max(10, Config.fps)
  readonly property real sensitivity: Config.sensitivity

  property var levels: root.flat()
  property real energy: 0
  property real lastReadMs: 0

  function flat() {
    var a = [];
    for (var i = 0; i < root.bars; i++) a.push(0);
    return a;
  }

  property Process cava: Process {
    id: cavaProc
    running: root.active && !cavaProc.backoff
    property bool backoff: false
    command: ["sh", "-c",
      "command -v cava >/dev/null 2>&1 || exit 0; " +
      "cfg=\"${XDG_RUNTIME_DIR:-/tmp}/omarchy-aio-cava.conf\"; " +
      "printf '%s\\n' '[general]' 'framerate = " + root.fps + "' 'bars = " + root.bars + "' '' " +
      "'[input]' 'method = pipewire' 'source = auto' '' " +
      "'[output]' 'method = raw' 'raw_target = /dev/stdout' 'data_format = ascii' " +
      "'ascii_max_range = 100' 'channels = mono' 'mono_option = average' '' " +
      "'[smoothing]' 'noise_reduction = " + Config.smoothing + "' > \"$cfg\"; " +
      "exec cava -p \"$cfg\""]
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: (line) => root.readBars(line)
    }
    onExited: if (root.active) {
      cavaProc.backoff = true;
      restartTimer.restart();
    }
  }

  property Timer restartTimer: Timer {
    interval: 1200
    onTriggered: root.cava.backoff = false
  }

  // cava stops emitting while playback idles; fall back to flat.
  property Timer settle: Timer {
    interval: 140
    running: root.active
    repeat: true
    onTriggered: if (Date.now() - root.lastReadMs > 280) {
      root.levels = root.flat();
      root.energy = 0;
    }
  }

  function norm(v) {
    var n = parseInt(v);
    if (isNaN(n)) return 0;
    var x = (n / 100) * root.sensitivity;
    return Math.max(0, Math.min(1, x));
  }

  function readBars(line) {
    var t = String(line || "").trim();
    if (!t) return;
    var parts = t.split(/[;\s]+/);
    if (parts.length < root.bars) return;
    var out = [];
    var sum = 0;
    for (var i = 0; i < root.bars; i++) {
      var v = root.norm(parts[i]);
      out.push(v);
      sum += v;
    }
    root.levels = out;
    root.energy = sum / root.bars;
    root.lastReadMs = Date.now();
  }

  onActiveChanged: {
    root.levels = root.flat();
    root.energy = 0;
    if (root.active) root.lastReadMs = 0;
  }
}
