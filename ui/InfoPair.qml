import QtQuick
import qs.Commons

Row {
  id: root

  property string label: ""
  property string value: ""
  property color foreground: Qt.rgba(1, 1, 1, 1)
  property string fontFamily: "monospace"
  property int fontSize: 11

  width: parent.width
  spacing: Style.space(8)

  Text {
    text: root.label
    color: root.foreground
    opacity: 0.6
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
  }

  Item {
    width: Math.max(0, parent.width - parent.children[0].implicitWidth - parent.children[2].implicitWidth - parent.spacing * 2)
    height: 1
  }

  Text {
    text: root.value
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    elide: Text.ElideMiddle
    width: Math.min(implicitWidth, Style.space(260))
  }
}
