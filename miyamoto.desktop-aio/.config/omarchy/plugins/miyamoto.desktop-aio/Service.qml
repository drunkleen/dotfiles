import QtQuick
import Quickshell
import Quickshell.Wayland

// Service plugin entry point. One bottom-layer surface per selected monitor,
// carrying the AIO widget. The surface is click-through (empty input region),
// so it never interferes with windows, workspaces, keybinds or fullscreen apps.
Item {
  id: root

  function placeX(anchor, w, total, m) {
    if (anchor.indexOf("left") >= 0) return m;
    if (anchor.indexOf("right") >= 0) return total - w - m;
    return Math.round((total - w) / 2);
  }
  function placeY(anchor, h, total, m) {
    if (anchor.indexOf("top") >= 0) return m;
    if (anchor.indexOf("bottom") >= 0) return total - h - m;
    return Math.round((total - h) / 2);
  }

  Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
      id: win
      required property var modelData

      screen: modelData
      visible: {
        var m = String(Config.monitor || "all");
        if (m === "all") return true;
        var list = m.split(",");
        for (var i = 0; i < list.length; i++)
          if (list[i].trim() === modelData.name) return true;
        return false;
      }

      color: "transparent"
      anchors { top: true; left: true; right: true; bottom: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.namespace: "miyamoto.desktop-aio"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      // Empty input region: everything passes through to windows/desktop.
      mask: Region {}

      AioWidget {
        id: widget
        active: win.visible
        opacity: Config.opacity
        s: Config.scale
        x: Config.anchor === "free"
          ? Config.freeX
          : root.placeX(Config.anchor, widget.implicitWidth, win.width, Config.marginX)
        y: Config.anchor === "free"
          ? Config.freeY
          : root.placeY(Config.anchor, widget.implicitHeight, win.height, Config.marginY)
        width: implicitWidth
        height: implicitHeight
      }
    }
  }
}
