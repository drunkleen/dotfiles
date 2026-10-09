pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "Toml.js" as Toml

// Ink and accent for the widget, following the current Omarchy theme
// (~/.local/state/omarchy/current/theme/colors.toml). Overridable from config.
QtObject {
  id: root

  readonly property string path: (Quickshell.env("HOME") || "") + "/.local/state/omarchy/current/theme/colors.toml"

  property var colors: ({})

  property FileView file: FileView {
    path: root.path
    watchChanges: true
    printErrors: false
    onLoaded: root.colors = Toml.parse(text())
    onFileChanged: reload()
  }

  readonly property color accent: Config.accent !== "" ? Config.accent : (colors.accent || "#33b8a8")
  readonly property color foreground: colors.foreground || "#d8e3e0"
  readonly property color background: colors.background || "#0b1113"

  readonly property color ink: Config.ink !== "" ? Config.ink : foreground
  readonly property color inkDim: Qt.rgba(ink.r, ink.g, ink.b, 0.62)
  readonly property color inkFaint: Qt.rgba(ink.r, ink.g, ink.b, 0.35)

  readonly property string font: Config.fontDisplay
  readonly property string display: Config.fontDisplay
  readonly property string icon: Config.fontIcon
}
