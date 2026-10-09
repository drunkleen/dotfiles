import QtQuick

// Material Symbols glyph.
Item {
  id: root
  property string name: ""
  property color color: "white"
  property real size: 32

  implicitWidth: size
  implicitHeight: size
  visible: name.length > 0

  Text {
    anchors.centerIn: parent
    text: root.name
    color: root.color
    font.family: Theme.icon
    font.pixelSize: root.size
    font.preferShaping: true
    textFormat: Text.PlainText
    renderType: Text.NativeRendering
  }
}
