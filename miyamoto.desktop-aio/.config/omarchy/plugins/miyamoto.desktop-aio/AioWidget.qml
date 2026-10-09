pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes

// All-in-one desktop face: weather cluster, weekday, time card, date line and
// a live cava spectrum, in Ryoku's "wide" layout (design box 708 x 454),
// scaled by `s`. Ported from Ryoku's AioWidget.qml (GPL-3.0); see NOTICE.
Item {
  id: root

  property real s: Config.scale
  property bool active: true

  implicitWidth: box.width * root.s
  implicitHeight: box.height * root.s

  Loader {
    id: box
    width: 708
    height: 454
    active: true
    sourceComponent: wideCard
    transform: Scale { xScale: root.s; yScale: root.s }
    visible: root.active
  }

  Component {
    id: wideCard
    Item {
      id: w
      implicitWidth: 708
      implicitHeight: 454

      readonly property color ink: Theme.ink
      readonly property color dim: Theme.inkDim

      readonly property var day0: (Weather.daily && Weather.daily.length > 0) ? Weather.daily[0] : null
      readonly property bool hasHiLo: w.day0 !== null

      readonly property string dateLine: {
        var parts = [Qt.formatDate(Now.now, "MMMM").toUpperCase(),
                     Qt.formatDate(Now.now, "dd"),
                     Qt.formatDate(Now.now, "yyyy")];
        var out = [];
        for (var i = 0; i < parts.length; i++)
          out.push(parts[i].split("").join(" "));
        return out.join("   ");
      }

      // ---- diagonal divider ----
      Shape {
        anchors.fill: parent
        ShapePath {
          strokeColor: w.ink; strokeWidth: 2; fillColor: "transparent"
          startX: 360; startY: 20
          PathLine { x: 314; y: 150 }
        }
      }

      // ---- weather cluster (top-left) ----
      Item {
        id: weatherCluster
        visible: Config.showWeather
        x: 44; y: 34; width: 340; height: 130

        GlyphIcon {
          id: glyph
          x: 0; y: 6
          size: 46
          name: Weather.available ? Weather.glyph : "cloud"
          color: w.ink
        }
        Text {
          id: temp
          x: 106; y: 0
          text: Weather.available ? (Weather.tempNow + "\u00b0") : "\u2014\u00b0"
          color: w.ink
          font.family: Theme.display; font.weight: Font.DemiBold; font.pixelSize: 52
        }
        Row {
          x: 106; y: 62; spacing: 14
          visible: w.hasHiLo
          Row { spacing: 2
            Text { text: "\u2191"; color: "#e0564b"; font.pixelSize: 22; font.family: Theme.display; font.weight: Font.Bold }
            Text { text: w.hasHiLo ? w.day0.hi + "\u00b0" : ""; color: w.dim; font.pixelSize: 22; font.family: Theme.display; font.weight: Font.Medium }
          }
          Row { spacing: 2
            Text { text: "\u2193"; color: "#4a90d9"; font.pixelSize: 22; font.family: Theme.display; font.weight: Font.Bold }
            Text { text: w.hasHiLo ? w.day0.lo + "\u00b0" : ""; color: w.dim; font.pixelSize: 22; font.family: Theme.display; font.weight: Font.Medium }
          }
        }
        Text {
          x: 106; y: 94
          text: Weather.available ? Weather.condition : (Weather.status === "loading" ? "Loading…" : Weather.errorText)
          color: w.dim
          font.family: Theme.display; font.pixelSize: 24; font.weight: Font.Medium
        }
      }

      // ---- big weekday ----
      Text {
        x: 34; y: 150
        text: Qt.formatDate(Now.now, "ddd").toUpperCase(); color: w.ink
        font.family: Theme.display; font.weight: Font.Black
        font.pixelSize: 200; font.letterSpacing: -6
      }

      // ---- time card (top-right): white parallelogram, upright dark clock ----
      Item {
        id: card
        visible: Config.showClock
        x: 392; y: 74; width: 296; height: 74
        Shape {
          anchors.fill: parent
          ShapePath {
            strokeColor: "transparent"; strokeWidth: 0; fillColor: Theme.ink
            startX: 20.72; startY: 0
            PathLine { x: 316.72; y: 0 }
            PathLine { x: 296; y: 74 }
            PathLine { x: 0; y: 74 }
            PathLine { x: 20.72; y: 0 }
          }
        }
        Text {
          anchors.centerIn: parent
          text: Qt.formatTime(Now.now, Config.clock24h ? "HH:mm" : "hh:mm AP")
          color: Theme.background
          font.family: Theme.display; font.weight: Font.Black; font.pixelSize: 46; font.letterSpacing: 1
        }
      }

      // ---- date line ----
      Text {
        visible: Config.showDate
        x: 392; y: 168
        text: w.dateLine; color: w.dim
        font.family: Theme.display; font.weight: Font.Medium; font.pixelSize: 17; font.letterSpacing: 3
      }

      // ---- now playing ----
      Text {
        visible: Config.showMedia && Media.available && Config.showDate
        x: 392; y: 198; width: Config.mediaMaxWidth
        text: Media.available ? (Media.artist !== "" ? Media.title + " — " + Media.artist : Media.title) : ""
        color: w.dim
        elide: Text.ElideRight
        font.family: Theme.display; font.weight: Font.Medium; font.pixelSize: 15; font.letterSpacing: 1
      }

      // ---- audio spectrum (bottom-right) ----
      Item {
        id: vizW
        visible: Config.showSpectrum
        x: 330; y: 300
        width: 302; height: 120
        readonly property bool wanted: root.active && root.visible && Config.showSpectrum
        onWantedChanged: AudioBars.setActive(vizW, vizW.wanted)
        Component.onCompleted: AudioBars.setActive(vizW, vizW.wanted)
        Component.onDestruction: AudioBars.setActive(vizW, false)

        Row {
          anchors.fill: parent
          spacing: 4
          Repeater {
            model: 34
            Rectangle {
              id: barW
              required property int index
              readonly property int band: Math.round(barW.index * (AudioBars.bars - 1) / 33)
              readonly property real lvl: AudioBars.active ? (AudioBars.levels[barW.band] || 0) : 0
              width: 5; radius: 2.5; color: Theme.accent
              anchors.bottom: parent.bottom
              height: Math.max(6, Math.min(120, barW.lvl * 120))
              Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutSine } }
            }
          }
        }
      }
    }
  }
}
