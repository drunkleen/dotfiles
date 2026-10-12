import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "Settings.js" as Settings

// One click-through layer-shell surface per monitor. Petals never get their
// own window; each surface hosts a single PetalField.
ShellRoot {
  id: root

  readonly property var cfg: Settings.parse(Quickshell.env("SAKURA_RAIN_CONFIG"))

  function layerFor(name) {
    switch (name) {
    case "top": return WlrLayer.Top
    case "bottom": return WlrLayer.Bottom
    default: return WlrLayer.Background
    }
  }

  // Mapped window rectangles in global logical coordinates. Rebuilt only when
  // Hyprland reports an event, so petals never pay for IPC lookups per frame.
  property var windowRects: []

  function refreshWindowRects() {
    const out = []
    const list = Hyprland.toplevels.values
    for (var i = 0; i < list.length; i++) {
      const o = list[i].lastIpcObject
      if (!o || !o.at || !o.size || o.hidden || !o.mapped) continue
      out.push({ x: o.at[0], y: o.at[1], w: o.size[0], h: o.size[1],
                 ws: o.workspace ? o.workspace.id : -1 })
    }
    windowRects = out
  }

  Component.onCompleted: refreshWindowRects()

  Connections {
    target: Hyprland
    function onRawEvent(event) { root.refreshWindowRects() }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win
      required property var modelData

      screen: win.modelData
      color: "transparent"
      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }
      exclusionMode: ExclusionMode.Ignore

      WlrLayershell.namespace: "sakura-rain"
      WlrLayershell.layer: root.layerFor(root.cfg.layer)
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      // Empty region = no input at all, so clicks reach the windows below.
      Region {
        id: noInput
      }
      Region {
        id: fullInput
        width: win.width
        height: win.height
      }
      mask: root.cfg.click_through ? noInput : fullInput

      // Fullscreen on this monitor's active workspace (games, video). Hyprland
      // pushes the change over IPC, so this costs nothing while idle.
      readonly property bool fullscreen: {
        const monitor = Hyprland.monitorFor(win.screen)
        return !!(monitor && monitor.activeWorkspace && monitor.activeWorkspace.hasFullscreen)
      }

      visible: !(root.cfg.pause_on_fullscreen && win.fullscreen)

      // Windows on this monitor's active workspace, in this surface's local
      // coordinates. Petals fade out under them so only the wallpaper shows petals.
      readonly property int activeWorkspaceId: {
        const monitor = Hyprland.monitorFor(win.screen)
        return monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1
      }
      readonly property var obstacles: {
        const out = []
        if (!root.cfg.avoid_windows) return out
        const rects = root.windowRects
        for (var i = 0; i < rects.length; i++) {
          const r = rects[i]
          if (r.ws !== win.activeWorkspaceId) continue
          out.push({ x: r.x - win.screen.x, y: r.y - win.screen.y, w: r.w, h: r.h })
        }
        return out
      }

      PetalField {
        anchors.fill: parent
        settings: root.cfg
        running: win.visible
        obstacles: win.obstacles
      }
    }
  }
}
