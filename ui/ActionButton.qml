import QtQuick
import qs.Ui

Button {
  property color foregroundColor: Qt.rgba(1, 1, 1, 1)
  property string fontFamilyName: "monospace"

  foreground: foregroundColor
  fontFamily: fontFamilyName
  bordered: true
}
