import AppKit
// args: out name bg fg cursor selection  + 16 ansi (normal 0-7, bright 0-7)
let a = Array(CommandLine.arguments.dropFirst())
func c(_ h: String) -> Data {
  let v = Int(h.dropFirst(), radix: 16)!
  let col = NSColor(srgbRed: CGFloat((v>>16)&255)/255, green: CGFloat((v>>8)&255)/255, blue: CGFloat(v&255)/255, alpha: 1)
  return try! NSKeyedArchiver.archivedData(withRootObject: col, requiringSecureCoding: false)
}
let font = NSFont(name: "JetBrainsMonoNF-Regular", size: 14)!
var p: [String: Any] = [
  "name": a[1], "type": "Window Settings", "ProfileCurrentVersion": 2.07,
  "Font": try! NSKeyedArchiver.archivedData(withRootObject: font, requiringSecureCoding: false),
  "FontAntialias": true, "UseBrightBold": true, "columnCount": 110, "rowCount": 30,
  "CursorType": 1, "CursorBlink": true,
  "BackgroundColor": c(a[2]), "TextColor": c(a[3]), "TextBoldColor": c(a.count > 22 ? a[22] : a[3]),
  "CursorColor": c(a[4]), "SelectionColor": c(a[5]),
]
let names = ["Black","Red","Green","Yellow","Blue","Magenta","Cyan","White"]
for i in 0..<8 { p["ANSI\(names[i])Color"] = c(a[6+i]); p["ANSIBright\(names[i])Color"] = c(a[14+i]) }
try! PropertyListSerialization.data(fromPropertyList: p, format: .xml, options: 0).write(to: URL(fileURLWithPath: a[0]))
