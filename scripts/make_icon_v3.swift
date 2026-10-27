import AppKit

// Candidate artwork only; does not replace the selected icon or bundle asset.
let side = 1024
let output = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    .deletingLastPathComponent().appendingPathComponent("Resources")

func color(_ hex: UInt32) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 255) / 255,
            green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255, alpha: 1)
}

func rounded(_ rect: NSRect, _ radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func triangle(_ a: NSPoint, _ b: NSPoint, _ c: NSPoint) {
    let path = NSBezierPath()
    path.move(to: a)
    path.line(to: b)
    path.line(to: c)
    path.close()
    path.fill()
}

func render(_ name: String, top: UInt32, bottom: UInt32, artwork: () -> Void) {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: side,
        pixelsHigh: side, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
        isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let tile = rounded(NSRect(x: 80, y: 80, width: 864, height: 864), 196)
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
    shadow.shadowOffset = NSSize(width: 0, height: -12)
    shadow.shadowBlurRadius = 24
    NSGraphicsContext.saveGraphicsState()
    shadow.set()
    color(bottom).setFill()
    tile.fill()
    NSGraphicsContext.restoreGraphicsState()
    NSGradient(starting: color(bottom), ending: color(top))!.draw(in: tile, angle: 65)
    NSGraphicsContext.saveGraphicsState()
    tile.addClip()
    NSColor.white.withAlphaComponent(0.08).setFill()
    NSBezierPath(ovalIn: NSRect(x: -160, y: 570, width: 1180, height: 620)).fill()
    NSGraphicsContext.restoreGraphicsState()
    artwork()
    NSGraphicsContext.restoreGraphicsState()
    assert(bitmap.pixelsWide == side && bitmap.pixelsHigh == side)
    let png = bitmap.representation(using: .png, properties: [:])!
    try! png.write(to: output.appendingPathComponent(name + ".png"))
    assert(NSBitmapImageRep(data: png)?.pixelsWide == side)
    print("Rendered \(name).png: \(side)x\(side)")
}

// A: emerald tile, soft white bubble, deep-green letterform.
render("icon-v3-a", top: 0x32D9A0, bottom: 0x078E73) {
    let shadow = NSShadow()
    shadow.shadowColor = color(0x00523F).withAlphaComponent(0.22)
    shadow.shadowOffset = NSSize(width: 0, height: -14)
    shadow.shadowBlurRadius = 24
    NSGraphicsContext.saveGraphicsState()
    shadow.set()
    let bubble = rounded(NSRect(x: 224, y: 302, width: 576, height: 460), 164)
    let tail = NSBezierPath()
    tail.move(to: NSPoint(x: 295, y: 390))
    tail.line(to: NSPoint(x: 258, y: 234))
    tail.curve(to: NSPoint(x: 466, y: 334),
               controlPoint1: NSPoint(x: 346, y: 254), controlPoint2: NSPoint(x: 397, y: 292))
    tail.close()
    bubble.append(tail)
    NSColor.white.setFill()
    bubble.fill()
    NSGraphicsContext.restoreGraphicsState()
    let letter = NSAttributedString(string: "G", attributes: [
        .font: NSFont.systemFont(ofSize: 390, weight: .bold),
        .foregroundColor: color(0x089879)
    ])
    let size = letter.size()
    letter.draw(at: NSPoint(x: (1024 - size.width) / 2, y: 532 - size.height / 2))
}

// B: cobalt tile, one continuous G-shaped signal with an integrated message tail.
render("icon-v3-b", top: 0x438BFF, bottom: 0x1747CB) {
    NSColor.white.setStroke()
    NSColor.white.setFill()
    let mark = NSBezierPath()
    mark.appendArc(withCenter: NSPoint(x: 512, y: 550), radius: 232,
                   startAngle: 42, endAngle: 318, clockwise: false)
    mark.curve(to: NSPoint(x: 744, y: 478),
               controlPoint1: NSPoint(x: 725, y: 434), controlPoint2: NSPoint(x: 744, y: 450))
    mark.line(to: NSPoint(x: 744, y: 546))
    mark.line(to: NSPoint(x: 535, y: 546))
    mark.lineWidth = 96
    mark.lineCapStyle = .round
    mark.lineJoinStyle = .round
    mark.stroke()
    triangle(NSPoint(x: 354, y: 392), NSPoint(x: 305, y: 236), NSPoint(x: 532, y: 320))
}

let preview = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1200, pixelsHigh: 680,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: preview)
color(0xF0F2F6).setFill()
NSRect(x: 0, y: 0, width: 1200, height: 680).fill()
for (index, name) in ["icon-v3-a", "icon-v3-b"].enumerated() {
    let x = CGFloat(index * 580 + 54)
    NSImage(contentsOf: output.appendingPathComponent(name + ".png"))!
        .draw(in: NSRect(x: x, y: 100, width: 512, height: 512))
    let label = index == 0 ? "A · Emerald" : "B · Cobalt"
    let text = NSAttributedString(string: label, attributes: [
        .font: NSFont.systemFont(ofSize: 28, weight: .semibold),
        .foregroundColor: color(0x263147)
    ])
    text.draw(at: NSPoint(x: x + (512 - text.size().width) / 2, y: 66))
}
NSGraphicsContext.restoreGraphicsState()
try! preview.representation(using: .png, properties: [:])!
    .write(to: output.appendingPathComponent("icon-v3-comparison.png"))
