import AppKit

// Renders three Gtext icon concepts (1024x1024) into Resources/.
// A: midnight signal — dark indigo, gradient-stroke bubble outline.
// B: paper — light background, single bold blue bubble.
// C: aurora — vivid diagonal gradient, overlapping white bubbles.
// Run: swift scripts/make_icon_v2.swift

let S = 1024.0

func canvas() -> NSImage {
    NSImage(size: NSSize(width: S, height: S))
}

func squircle(_ rect: NSRect, _ r: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: r, yRadius: r)
}

func fillVertical(_ path: NSBezierPath, _ top: NSColor, _ bottom: NSColor) {
    NSGradient(starting: top, ending: bottom)!.draw(in: path, angle: 90)
}

func save(_ image: NSImage, _ name: String) {
    image.unlockFocus()
    let url = URL(fileURLWithPath: "Resources/\(name).png")
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        fputs("render failed for \(name)\n", stderr)
        exit(1)
    }
    try! png.write(to: url)
    print("wrote \(url.path)")
}

// MARK: - A: midnight signal

do {
    let img = canvas()
    img.lockFocus()
    fillVertical(
        squircle(NSRect(x: 0, y: 0, width: S, height: S), 240),
        NSColor(red: 0.13, green: 0.13, blue: 0.25, alpha: 1.0),
        NSColor(red: 0.03, green: 0.03, blue: 0.10, alpha: 1.0)
    )
    // Gradient-stroke bubble: build one path (rounded body + tail), stroke it.
    let body = NSBezierPath(roundedRect: NSRect(x: 232, y: 330, width: 560, height: 400), xRadius: 130, yRadius: 130)
    let tail = NSBezierPath()
    tail.move(to: NSPoint(x: 330, y: 360))
    tail.line(to: NSPoint(x: 285, y: 240))
    tail.line(to: NSPoint(x: 450, y: 350))
    let combined = NSBezierPath()
    combined.append(body)
    combined.append(tail)
    combined.lineWidth = 64
    combined.lineJoinStyle = .round
    combined.lineCapStyle = .round
    // Stroke with gradient via clipping to the stroked shape.
    NSGraphicsContext.saveGraphicsState()
    combined.addClip()
    NSGradient(
        starting: NSColor(red: 0.45, green: 0.90, blue: 1.0, alpha: 1.0),
        ending: NSColor(red: 0.25, green: 0.45, blue: 1.0, alpha: 1.0)
    )!.draw(in: squircle(NSRect(x: 200, y: 200, width: 624, height: 600), 160), angle: 90)
    NSGraphicsContext.restoreGraphicsState()
    save(img, "icon-v2-a")
}

// MARK: - B: paper

do {
    let img = canvas()
    img.lockFocus()
    fillVertical(
        squircle(NSRect(x: 0, y: 0, width: S, height: S), 240),
        NSColor(red: 0.99, green: 0.99, blue: 1.0, alpha: 1.0),
        NSColor(red: 0.85, green: 0.89, blue: 0.95, alpha: 1.0)
    )
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(red: 0.1, green: 0.25, blue: 0.6, alpha: 0.35)
    shadow.shadowOffset = NSSize(width: 0, height: -16)
    shadow.shadowBlurRadius = 40
    shadow.set()
    NSColor(red: 0.10, green: 0.45, blue: 0.95, alpha: 1.0).setFill()
    NSBezierPath(roundedRect: NSRect(x: 232, y: 320, width: 560, height: 400), xRadius: 140, yRadius: 140).fill()
    let tail = NSBezierPath()
    tail.move(to: NSPoint(x: 660, y: 350))
    tail.line(to: NSPoint(x: 740, y: 235))
    tail.line(to: NSPoint(x: 560, y: 340))
    tail.close()
    tail.fill()
    save(img, "icon-v2-b")
}

// MARK: - C: aurora

do {
    let img = canvas()
    img.lockFocus()
    let bg = squircle(NSRect(x: 0, y: 0, width: S, height: S), 240)
    NSGraphicsContext.saveGraphicsState()
    bg.addClip()
    NSGradient(starting: NSColor(red: 0.20, green: 0.50, blue: 1.0, alpha: 1.0),
               ending: NSColor(red: 0.55, green: 0.30, blue: 0.95, alpha: 1.0))!
        .draw(in: bg.bounds, angle: 45)
    NSColor(red: 0.95, green: 0.30, blue: 0.55, alpha: 0.45).setFill()
    squircle(NSRect(x: 420, y: -140, width: 760, height: 760), 380).fill()
    NSGraphicsContext.restoreGraphicsState()
    // Back bubble: translucent white, offset up-right.
    NSColor(white: 1.0, alpha: 0.45).setFill()
    NSBezierPath(roundedRect: NSRect(x: 430, y: 430, width: 380, height: 300), xRadius: 90, yRadius: 90).fill()
    // Front bubble: solid white with tail.
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(white: 0.0, alpha: 0.25)
    shadow.shadowOffset = NSSize(width: 0, height: -14)
    shadow.shadowBlurRadius = 30
    shadow.set()
    NSColor.white.setFill()
    let front = NSBezierPath(roundedRect: NSRect(x: 214, y: 280, width: 440, height: 340), xRadius: 100, yRadius: 100)
    front.fill()
    let tail = NSBezierPath()
    tail.move(to: NSPoint(x: 300, y: 310))
    tail.line(to: NSPoint(x: 258, y: 200))
    tail.line(to: NSPoint(x: 410, y: 300))
    tail.close()
    tail.fill()
    save(img, "icon-v2-c")
}
