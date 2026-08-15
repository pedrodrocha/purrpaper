import QtQuick

Text {
  id: root

  property real size: 24
  property bool inactive: false
  property bool rotating: false
  property color foreground: Qt.rgba(1, 1, 1, 1)
  property string fontFamily: "monospace"

  text: "󰄛"
  color: inactive ? "transparent" : foreground
  style: inactive ? Text.Outline : Text.Normal
  styleColor: foreground
  font.family: fontFamily
  font.pixelSize: size
  renderType: Text.NativeRendering
  transformOrigin: Item.Center

  RotationAnimation on rotation {
    running: root.rotating
    from: 0
    to: 360
    duration: 850
    loops: Animation.Infinite
    // Complete the current spin instead of snapping the cat sideways.
    alwaysRunToEnd: true
  }
}
