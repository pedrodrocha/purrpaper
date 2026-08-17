import Quickshell
import Quickshell.Io
import QtQuick

Item {
  id: root

  // Check every minute; the script itself honors the configured rotation interval.
  readonly property int checkIntervalMs: 60 * 1000

  readonly property string pluginDir: Quickshell.env("HOME") + "/.config/omarchy/plugins/pedrodrocha.purrpaper"

  function runDailyPicker() {
    if (!dailyPicker.running) dailyPicker.running = true
  }

  Process {
    id: startup
    command: [root.pluginDir + "/scripts/control", "init"]
  }

  Process {
    id: dailyPicker
    command: [root.pluginDir + "/scripts/rotate-background"]
  }

  Timer {
    interval: root.checkIntervalMs
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.runDailyPicker()
  }

  Component.onCompleted: startup.running = true
}
