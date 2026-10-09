pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Now-playing from MPRIS (optional, toggled by show_media in config).
QtObject {
  id: root

  readonly property var players: (Mpris.players && Mpris.players.values) ? Mpris.players.values : []

  readonly property var player: {
    var ps = root.players;
    for (var i = 0; i < ps.length; i++)
      if (ps[i] && ps[i].isPlaying) return ps[i];
    return ps.length > 0 ? ps[0] : null;
  }

  readonly property bool playing: root.player !== null && root.player.isPlaying === true
  readonly property string title: root.player ? String(root.player.trackTitle || "") : ""
  readonly property string artist: root.player ? String(root.player.trackArtist || "") : ""
  readonly property bool available: root.title.length > 0
}
