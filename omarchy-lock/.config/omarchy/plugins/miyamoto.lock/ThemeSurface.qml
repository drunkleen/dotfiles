import QtQuick
import Quickshell
import Quickshell.Io

// Renders the vendored Ryoku qylock "clockwork/orbital" theme inside Omarchy's
// lock Service, exposing the SDDM-ish API the theme expects and mapping it onto
// the Service's PAM/state machine. Falls back to Omarchy's LockView if the
// theme fails to load, so a broken theme can never strand the session.
Item {
  id: surface

  // The lock Service (Service.qml root) that owns PAM and the WlSessionLock.
  property var service: null

  // Ryoku clockwork/orbital theme.conf defaults.
  readonly property var config: ({ themeMode: "dark", enableWindup: true })

  // Fingerprint hint state for the theme: idle | scanning | success | fail.
  property string fpBase: "idle"
  readonly property bool fpReady: service ? service.fingerprintConfigured === true : false
  readonly property bool fpScanning: service ? service.fingerprintAuthenticating === true : false

  property string hostName: "localhost"

  property var keyboard: QtObject {
    property bool numLock: false
  }

  property var userModel: ListModel {
    property string lastUser: Quickshell.env("USER") || "user"
    property int lastIndex: 0
    function rowCount() { return count }
    Component.onCompleted: append({
      name: Quickshell.env("USER") || "user",
      realName: Quickshell.env("USER") || "User"
    })
  }

  property var sessionModel: ListModel {
    property int lastIndex: 0
    property string desktopName: (Quickshell.env("XDG_SESSION_DESKTOP")
      || Quickshell.env("DESKTOP_SESSION")
      || Quickshell.env("XDG_CURRENT_DESKTOP") || "").split(":")[0].toLowerCase()
    function rowCount() { return count }
    Component.onCompleted: append({ name: "Session", file: "" })
  }

  property var sddm: QtObject {
    property string hostName: surface.hostName
    signal loginSucceeded()
    signal loginFailed()
    signal surfaceRevealed()
    readonly property bool fingerprintHint: true
    property bool fingerprintReady: surface.fpReady
    property string fingerprintState: surface.fpScanning ? "scanning" : surface.fpBase
    property bool fingerprintUnlock: false

    function login(user, password, sessionIndex) {
      if (surface.service) surface.service.submitPassword(String(password || ""))
    }
    function reboot() { Quickshell.execDetached(["bash", "-c", "systemctl reboot || loginctl reboot"]) }
    function powerOff() { Quickshell.execDetached(["bash", "-c", "systemctl poweroff || loginctl poweroff"]) }
  }

  Process {
    id: hostnameProc
    command: ["cat", "/etc/hostname"]
    stdout: StdioCollector {
      onStreamFinished: {
        var h = String(text || "").trim()
        if (h !== "") surface.hostName = h
      }
    }
  }

  // Hooks called by Service.qml.
  // The theme plays its entrance reveal on `surfaceRevealed`; defer it until the
  // theme component has actually loaded so a fast lock can't miss the signal.
  property bool revealPending: false

  function announceSurfaceRevealed() {
    surface.revealPending = true
    surface.flushReveal()
  }

  function flushReveal() {
    if (surface.revealPending && themeLoader.status === Loader.Ready) {
      surface.revealPending = false
      surface.sddm.surfaceRevealed()
    }
  }

  function announceLoginSucceeded(fromFingerprint) {
    surface.sddm.fingerprintUnlock = fromFingerprint === true
    surface.fpBase = "success"
    surface.sddm.loginSucceeded()
  }

  function announceLoginFailed() {
    if (!surface.sddm.fingerprintUnlock) surface.fpBase = "fail"
    surface.sddm.loginFailed()
    fpResetTimer.restart()
  }

  function resetThemeState() {
    surface.fpBase = "idle"
    surface.sddm.fingerprintUnlock = false
  }

  Timer {
    id: fpResetTimer
    interval: 1200
    repeat: false
    onTriggered: if (surface.fpBase === "fail") surface.fpBase = "idle"
  }

  // The Service root cannot reference this surface's id (it lives inside the
  // WlSessionLock surface Component), so it emits these instead.
  Connections {
    target: surface.service
    ignoreUnknownSignals: true
    function onLockSecureChanged() { if (surface.service.lockSecure) surface.announceSurfaceRevealed() }
    function onAuthSucceeded(fromFingerprint) { surface.announceLoginSucceeded(fromFingerprint) }
    function onAuthFailed() { surface.announceLoginFailed() }
    function onUnlocked() { surface.resetThemeState() }
  }

  Component.onCompleted: {
    if (surface.service && surface.service.lockSecure) surface.announceSurfaceRevealed()
  }

  Loader {
    id: themeLoader
    anchors.fill: parent
    source: "theme/Main.qml"
    onLoaded: surface.flushReveal()
    onStatusChanged: {
      if (status === Loader.Error) {
        console.warn("miyamoto.lock: theme failed to load; falling back to LockView")
        fallbackLoader.active = true
        themeLoader.active = false
      }
    }
  }

  Loader {
    id: fallbackLoader
    anchors.fill: parent
    active: false

    sourceComponent: Component {
      LockView {
        anchors.fill: parent
        backgroundPath: surface.service ? surface.service.backgroundPath : ""
        backgroundVersion: surface.service ? surface.service.backgroundVersion : 0
        fingerprintConfigured: surface.service ? surface.service.fingerprintConfigured : false
        authenticatingPassword: surface.service ? surface.service.authenticatingPassword : false
        failureMessage: surface.service ? surface.service.failureMessage : ""
        failedAttempts: surface.service ? surface.service.failedAttempts : 0
        inputEnabled: surface.service ? surface.service.lockRequested : false
        loadBackground: surface.service ? surface.service.locked : false
        passwordText: surface.service ? surface.service.enteredPassword : ""
        onPasswordTextEdited: function(password) { if (surface.service) surface.service.enteredPassword = password }
        onSubmitPassword: function(password) { if (surface.service) surface.service.submitPassword(password) }
        onClearFailureRequested: if (surface.service) surface.service.failureMessage = ""
        onWakeRequested: if (surface.service) surface.service.runWake()
      }
    }
  }
}
