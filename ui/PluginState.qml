import QtQuick

QtObject {
  property var info: ({
    enabled: true,
    intervalMinutes: 1440,
    currentName: "",
    remainingSeconds: 0,
    currentTheme: "",
    catppuccinActive: true,
    noInternet: false,
    rotating: false
  })

  property bool actionRunning: false
  property string pendingAction: ""
  property string feedbackText: ""

  readonly property bool noInternet: info.noInternet === true
  readonly property bool catppuccinActive: info.catppuccinActive !== false
  readonly property bool pluginEnabled: info.enabled !== false
  readonly property bool canOperate: pluginEnabled && catppuccinActive
  readonly property bool inactive: !canOperate
  readonly property bool rotating: info.rotating === true || (actionRunning && pendingAction === "rotate")
}
