function formatInterval(minutes) {
  minutes = Number(minutes || 0)
  if (minutes % 1440 === 0) return (minutes / 1440) + "d"
  if (minutes % 60 === 0) return (minutes / 60) + "h"
  return minutes + "m"
}

function formatRemaining(seconds) {
  seconds = Number(seconds || 0)
  if (seconds <= 0) return "now"

  var minutes = Math.ceil(seconds / 60)
  if (minutes >= 1440) return Math.floor(minutes / 1440) + "d " + Math.floor((minutes % 1440) / 60) + "h"
  if (minutes >= 60) return Math.floor(minutes / 60) + "h " + (minutes % 60) + "m"
  return minutes + "m"
}

function statusLine(info) {
  if (info.catppuccinActive === false) return "DISABLED · THEME: " + (info.currentTheme || "unknown")
  if (info.noInternet === true) return "  NO INTERNET"
  if (info.enabled === false) return "DISABLED"
  return "NEXT: " + formatRemaining(info.remainingSeconds) + "  ·  EVERY " + formatInterval(info.intervalMinutes)
}

function blockedMessage(info) {
  return info.catppuccinActive !== false ? "󰄛 Disabled" : "󰄛 Catppuccin only"
}

function saveFeedback(rawOutput) {
  var cleaned = String(rawOutput || "").trim()
  var path = cleaned.replace(/^Saved current background to: /, "").replace(/^Already saved: /, "")
  var parts = path.split("/")
  var filename = parts.length > 0 ? parts[parts.length - 1] : ""
  return filename !== ""
    ? "󰄛 Saved!  →  Catppuccin backgrounds / " + filename
    : "󰄛 Saved!  →  Catppuccin backgrounds"
}
