import Quickshell
import Quickshell.Io
import QtQuick

Item {
  id: root

  // Check every minute; the script itself honors the configured rotation interval.
  readonly property int checkIntervalMs: 60 * 1000

  function runDailyPicker() {
    if (!dailyPicker.running) dailyPicker.running = true
  }

  Process {
    id: dailyPicker
    command: [Quickshell.env("HOME") + "/.config/omarchy/plugins/pedrodrocha.purrpaper/scripts/rotate-background"]
  }

  Timer {
    interval: root.checkIntervalMs
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.runDailyPicker()
  }
}
