pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "ui" as PluginUi
import "ui/Model.js" as Model

BarWidget {
  id: root
  moduleName: "pedrodrocha.purrpaper"

  property bool opened: false
  property bool popoutSwitchClosing: false

  function open() { root.opened = true }
  function close() { root.opened = false }
  function toggle() { root.opened ? root.close() : root.open() }
  function closeForPopoutSwitch() {
    root.popoutSwitchClosing = true
    root.close()
    Qt.callLater(function() { root.popoutSwitchClosing = false })
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root, direction)
    return false
  }

  PluginUi.PluginConfig { id: config }
  PluginUi.PluginState {
    id: pluginState
    actionRunning: actionProc.running
  }

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function runAction(args) {
    if (actionProc.running) return
    var action = args.length > 0 ? String(args[0]) : ""
    if ((action === "rotate" || action === "save") && !pluginState.canOperate) {
      pluginState.feedbackText = Model.blockedMessage(pluginState.info)
      feedbackTimer.restart()
      return
    }
    pluginState.pendingAction = action
    if (pluginState.pendingAction !== "save") pluginState.feedbackText = ""
    actionProc.command = [config.controlScript].concat(args)
    actionProc.running = true
  }

  onOpenedChanged: if (root.opened) root.refresh()

  // Keep the widget live when Omarchy/theme/plugin state changes outside the
  // panel, e.g. theme switcher, `make enable`, or a failed background fetch.
  FileView {
    path: config.currentThemeFile
    watchChanges: true
    printErrors: false
    onFileChanged: function() { reload(); root.refresh() }
    onLoaded: function() { root.refresh() }
    onLoadFailed: function() { root.refresh() }
  }

  FileView {
    path: config.stateDir + "/settings"
    watchChanges: true
    printErrors: false
    onFileChanged: function() { reload(); root.refresh() }
    onLoaded: function() { root.refresh() }
    onLoadFailed: function() { root.refresh() }
  }

  FileView {
    path: config.stateDir + "/network-state"
    watchChanges: true
    printErrors: false
    onFileChanged: function() { reload(); root.refresh() }
    onLoaded: function() { root.refresh() }
    onLoadFailed: function() { root.refresh() }
  }

  FileView {
    path: config.stateDir + "/rotation-state"
    watchChanges: true
    printErrors: false
    onFileChanged: function() { reload(); root.refresh() }
    onLoaded: function() { root.refresh() }
    onLoadFailed: function() { root.refresh() }
  }

  Process {
    id: statusProc
    command: [config.controlScript, "status"]
    stdout: StdioCollector {
      id: statusOutput
      waitForEnd: true
      onStreamFinished: function() {
        try { pluginState.info = JSON.parse(statusOutput.text || "{}") } catch (e) {}
      }
    }
  }

  Process {
    id: actionProc
    // Most action output is intentionally ignored; the panel refreshes from
    // state after each command so raw JSON/download details never leak into
    // the UI. Save is the exception: it gives a concise visual clue with the
    // destination path.
    stdout: StdioCollector {
      id: actionOutput
      waitForEnd: true
      onStreamFinished: function() {
        if (pluginState.pendingAction === "save") {
          pluginState.feedbackText = Model.saveFeedback(actionOutput.text)
          feedbackTimer.restart()
        }
      }
    }
    stderr: StdioCollector { waitForEnd: true }
    onRunningChanged: if (!actionProc.running) root.refresh()
  }

  Timer { interval: 30000; running: root.opened; repeat: true; triggeredOnStart: true; onTriggered: function() { root.refresh() } }

  Timer {
    // Safety refresh in case the file watcher misses the idle transition.
    interval: 1000
    running: pluginState.rotating
    repeat: true
    onTriggered: function() { root.refresh() }
  }

  Timer {
    id: feedbackTimer
    interval: 3500
    repeat: false
    onTriggered: function() { pluginState.feedbackText = "" }
  }


  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    tooltipText: "Purrpaper"
    iconComponent: Component {
      Item {
        ThemedCatIcon {
          anchors.centerIn: parent
          size: button.fontSize
        }

      }
    }
    onPressed: function(b) {
      if (b === Qt.RightButton && pluginState.canOperate) root.runAction(["rotate"])
      else if (b === Qt.MiddleButton && pluginState.canOperate) root.runAction(["save"])
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(420))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(14)

        Row {
        width: parent.width
        spacing: Style.space(12)

        ThemedCatIcon { size: config.fontDisplay }

        Column {
          width: parent.width - Style.space(70)
          spacing: Style.space(2)
          Text {
            width: parent.width
            text: "Purrpaper"
            color: config.foreground
            font.family: config.fontFamily
            font.pixelSize: config.fontTitle
            font.bold: true
            elide: Text.ElideRight
          }
          Text {
            width: parent.width
            text: Model.statusLine(pluginState.info)
            color: Qt.darker(config.foreground, 1.35)
            font.family: config.fontFamily
            font.pixelSize: config.fontCaption
            font.bold: true
            elide: Text.ElideRight
          }
        }
      }

      PanelSeparator { foreground: config.foreground }

      ThemedInfoPair { label: "Current"; value: pluginState.info.currentName || "Unknown" }
      ThemedInfoPair { label: "Theme"; value: pluginState.info.currentTheme || "Unknown" }
      ThemedInfoPair { label: "Interval"; value: Model.formatInterval(pluginState.info.intervalMinutes) }
      ThemedInfoPair { label: "Saved favorites"; value: config.savedFavoritesLabel }

      Row {
        visible: pluginState.canOperate
        width: parent.width
        spacing: Style.space(8)
        ActionButton { width: (parent.width - parent.spacing * 2) / 3; text: pluginState.rotating ? "Rotating…" : "Rotate now"; onClicked: root.runAction(["rotate"]) }
        ActionButton { width: (parent.width - parent.spacing * 2) / 3; text: "Save"; onClicked: root.runAction(["save"]) }
        ActionButton { width: (parent.width - parent.spacing * 2) / 3; text: "Disable"; onClicked: root.runAction(["disable"]) }
      }

      Row {
        visible: !pluginState.pluginEnabled && pluginState.catppuccinActive
        width: parent.width
        ActionButton { width: parent.width; text: "Enable"; onClicked: root.runAction(["enable"]) }
      }

      Text {
        visible: !pluginState.catppuccinActive
        width: parent.width
        text: "This plugin only runs on Catppuccin. Switch back to Catppuccin to enable rotation controls."
        color: config.foreground
        opacity: 0.7
        font.family: config.fontFamily
        font.pixelSize: config.fontBodySmall
        wrapMode: Text.WordWrap
      }

      PanelSectionHeader { visible: pluginState.canOperate; text: "ROTATION INTERVAL"; foreground: config.foreground; fontFamily: config.fontFamily }

      Row {
        visible: pluginState.canOperate
        width: parent.width
        spacing: Style.space(8)
        ActionButton { width: (parent.width - parent.spacing * 3) / 4; text: "-1h"; onClicked: root.runAction(["interval-delta", "-60"]) }
        ActionButton { width: (parent.width - parent.spacing * 3) / 4; text: "+1h"; onClicked: root.runAction(["interval-delta", "60"]) }
        ActionButton { width: (parent.width - parent.spacing * 3) / 4; text: "Daily"; onClicked: root.runAction(["interval", "1440"]) }
        ActionButton { width: (parent.width - parent.spacing * 3) / 4; text: "4h"; onClicked: root.runAction(["interval", "240"]) }
      }

      Text {
        visible: pluginState.feedbackText !== ""
        width: parent.width
        text: pluginState.feedbackText
        color: config.foreground
        opacity: 0.8
        font.family: config.fontFamily
        font.pixelSize: config.fontBodySmall
        wrapMode: Text.WordWrap
      }

        Text {
          width: parent.width
          text: pluginState.canOperate ? "Left click opens this panel · right click rotates · middle click saves" : "Left click opens this panel"
          color: config.foreground
          opacity: 0.55
          font.family: config.fontFamily
          font.pixelSize: config.fontCaption
          wrapMode: Text.WordWrap
        }
      }
    }
  }

  component ThemedCatIcon: PluginUi.CatIcon {
    inactive: pluginState.inactive
    rotating: pluginState.rotating
    foreground: config.foreground
    fontFamily: config.fontFamily
  }

  component ActionButton: PluginUi.ActionButton {
    foregroundColor: config.foreground
    fontFamilyName: config.fontFamily
  }

  component ThemedInfoPair: PluginUi.InfoPair {
    foreground: config.foreground
    fontFamily: config.fontFamily
    fontSize: config.fontBodySmall
  }
}
