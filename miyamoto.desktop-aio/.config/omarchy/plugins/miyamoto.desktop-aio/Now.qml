pragma Singleton
import QtQuick

// A single shared clock tick for every surface.
QtObject {
  id: root

  property date now: new Date()

  property Timer tick: Timer {
    interval: 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.now = new Date()
  }
}
