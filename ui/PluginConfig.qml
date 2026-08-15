import QtQuick
import Quickshell
import qs.Commons

QtObject {
  id: root

  readonly property string pluginId: "pedrodrocha.purrpaper"
  readonly property string home: Quickshell.env("HOME")
  readonly property string pluginDir: home + "/.config/omarchy/plugins/" + pluginId
  readonly property string controlScript: pluginDir + "/scripts/control"
  readonly property string stateDir: home + "/.local/state/omarchy/" + pluginId
  readonly property string currentThemeFile: home + "/.local/state/omarchy/current/theme.name"
  readonly property string savedFavoritesLabel: "~/.config/omarchy/backgrounds/catppuccin"

  // Theme values from Omarchy's shared singletons. Avoid reading root.bar.*:
  // qmlls sees `bar` as a plain QtObject and reports false warnings.
  readonly property color foreground: Color.foreground
  readonly property string fontFamily: Style.fontFamily
  readonly property int fontCaption: Style.fontToken("caption", Style.fontPx(0.833))
  readonly property int fontBodySmall: Style.fontToken("body-small", Style.fontPx(0.917))
  readonly property int fontTitle: Style.fontToken("title", Style.fontPx(1.167))
  readonly property int fontDisplay: Style.fontToken("display", Style.fontPx(2.0))
}
