import AppKit

let canvasWidth: CGFloat = 2480
let canvasHeight: CGFloat = 3508

func hex(_ value: Int, alpha: CGFloat = 1) -> NSColor {
    NSColor(
        calibratedRed: CGFloat((value >> 16) & 0xff) / 255,
        green: CGFloat((value >> 8) & 0xff) / 255,
        blue: CGFloat(value & 0xff) / 255,
        alpha: alpha
    )
}

func koreanFont(_ size: CGFloat, _ weight: NSFont.Weight = .regular) -> NSFont {
    let name: String
    switch weight {
    case .black, .heavy:
        name = "AppleSDGothicNeo-Heavy"
    case .bold, .semibold:
        name = "AppleSDGothicNeo-Bold"
    case .medium:
        name = "AppleSDGothicNeo-Medium"
    default:
        name = "AppleSDGothicNeo-Regular"
    }
    return NSFont(name: name, size: size) ?? NSFont.systemFont(ofSize: size, weight: weight)
}

func englishFont(_ size: CGFloat, _ weight: NSFont.Weight = .regular, condensed: Bool = false) -> NSFont {
    let preferred = condensed ? "AvenirNextCondensed-Bold" : "AvenirNext-DemiBold"
    return NSFont(name: preferred, size: size) ?? NSFont.systemFont(ofSize: size, weight: weight)
}

func topY(_ y: CGFloat, height: CGFloat) -> CGFloat {
    canvasHeight - y - height
}

@discardableResult
func drawText(
    _ text: String,
    x: CGFloat,
    y: CGFloat,
    width: CGFloat? = nil,
    font: NSFont,
    color: NSColor,
    kern: CGFloat = 0,
    lineHeight: CGFloat? = nil,
    alignment: NSTextAlignment = .left
) -> NSSize {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byWordWrapping
    if let lineHeight {
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
    }

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .kern: kern,
        .paragraphStyle: paragraph
    ]
    let attributed = NSAttributedString(string: text, attributes: attributes)
    let maxWidth = width ?? 4000
    let bounds = attributed.boundingRect(
        with: NSSize(width: maxWidth, height: 10000),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    ).integral
    let drawRect = NSRect(x: x, y: topY(y, height: bounds.height), width: maxWidth, height: bounds.height)
    attributed.draw(with: drawRect, options: [.usesLineFragmentOrigin, .usesFontLeading])
    return bounds.size
}

func measureText(
    _ text: String,
    width: CGFloat? = nil,
    font: NSFont,
    kern: CGFloat = 0,
    lineHeight: CGFloat? = nil
) -> NSSize {
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineBreakMode = .byWordWrapping
    if let lineHeight {
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
    }
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .kern: kern,
        .paragraphStyle: paragraph
    ]
    let attributed = NSAttributedString(string: text, attributes: attributes)
    let maxWidth = width ?? 4000
    return attributed.boundingRect(
        with: NSSize(width: maxWidth, height: 10000),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    ).integral.size
}

func fillRoundedRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, radius: CGFloat, color: NSColor) {
    color.setFill()
    NSBezierPath(roundedRect: NSRect(x: x, y: topY(y, height: height), width: width, height: height), xRadius: radius, yRadius: radius).fill()
}

func strokeRoundedRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, radius: CGFloat, color: NSColor, lineWidth: CGFloat) {
    color.setStroke()
    let path = NSBezierPath(roundedRect: NSRect(x: x, y: topY(y, height: height), width: width, height: height), xRadius: radius, yRadius: radius)
    path.lineWidth = lineWidth
    path.stroke()
}

func fillRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: NSColor) {
    color.setFill()
    NSRect(x: x, y: topY(y, height: height), width: width, height: height).fill()
}

func strokeLine(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, color: NSColor, width: CGFloat) {
    color.setStroke()
    let path = NSBezierPath()
    path.lineWidth = width
    path.lineCapStyle = .round
    path.move(to: NSPoint(x: x1, y: canvasHeight - y1))
    path.line(to: NSPoint(x: x2, y: canvasHeight - y2))
    path.stroke()
}

func fillCircle(cx: CGFloat, cy: CGFloat, radius: CGFloat, color: NSColor) {
    color.setFill()
    let rect = NSRect(x: cx - radius, y: topY(cy - radius, height: radius * 2), width: radius * 2, height: radius * 2)
    NSBezierPath(ovalIn: rect).fill()
}

func strokeCircle(cx: CGFloat, cy: CGFloat, radius: CGFloat, color: NSColor, width: CGFloat, dash: [CGFloat] = []) {
    color.setStroke()
    let rect = NSRect(x: cx - radius, y: topY(cy - radius, height: radius * 2), width: radius * 2, height: radius * 2)
    let path = NSBezierPath(ovalIn: rect)
    path.lineWidth = width
    if !dash.isEmpty {
        path.setLineDash(dash, count: dash.count, phase: 0)
    }
    path.stroke()
}

func drawGradientRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, radius: CGFloat = 0, colors: [NSColor], angle: CGFloat = 90) {
    guard let gradient = NSGradient(colors: colors) else { return }
    let rect = NSRect(x: x, y: topY(y, height: height), width: width, height: height)
    if radius > 0 {
        gradient.draw(in: NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius), angle: angle)
    } else {
        gradient.draw(in: rect, angle: angle)
    }
}

func drawGrid(step: CGFloat, line: NSColor, dots: NSColor, dotStep: CGFloat) {
    for x in stride(from: CGFloat(0), through: canvasWidth, by: step) {
        strokeLine(x1: x, y1: 0, x2: x, y2: canvasHeight, color: line, width: 2)
    }
    for y in stride(from: CGFloat(0), through: canvasHeight, by: step) {
        strokeLine(x1: 0, y1: y, x2: canvasWidth, y2: y, color: line, width: 2)
    }
    for x in stride(from: CGFloat(18), to: canvasWidth, by: dotStep) {
        for y in stride(from: CGFloat(18), to: canvasHeight, by: dotStep) {
            fillCircle(cx: x, cy: y, radius: 1.3, color: dots)
        }
    }
}

func drawFieldBlock(title: String, value: String, x: CGFloat, y: CGFloat, width: CGFloat, accent: NSColor) {
    drawText(title, x: x, y: y, font: englishFont(40, .bold), color: accent, kern: 3)
    drawText(value, x: x, y: y + 74, width: width, font: koreanFont(100, .bold), color: hex(0x0F1B2D), kern: -3)
    strokeLine(x1: x, y1: y + 158, x2: x + width, y2: y + 158, color: hex(0xD2D8E1), width: 6)
}

func drawMockExamCover() {
    drawGradientRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight, colors: [hex(0x14233A), hex(0x0A1221)], angle: 270)
    drawGrid(step: 180, line: hex(0x20324D, alpha: 0.58), dots: hex(0x223654, alpha: 0.38), dotStep: 28)

    let accent = NSBezierPath()
    accent.move(to: NSPoint(x: 1490, y: canvasHeight - 650))
    accent.curve(to: NSPoint(x: 1670, y: canvasHeight - 430), controlPoint1: NSPoint(x: 1550, y: canvasHeight - 580), controlPoint2: NSPoint(x: 1604, y: canvasHeight - 530))
    accent.curve(to: NSPoint(x: 2366, y: canvasHeight - 248), controlPoint1: NSPoint(x: 1860, y: canvasHeight - 280), controlPoint2: NSPoint(x: 2104, y: canvasHeight - 234))
    accent.line(to: NSPoint(x: 2366, y: canvasHeight - 3180))
    accent.curve(to: NSPoint(x: 1490, y: canvasHeight - 2920), controlPoint1: NSPoint(x: 2228, y: canvasHeight - 3268), controlPoint2: NSPoint(x: 1760, y: canvasHeight - 3200))
    accent.close()
    guard let accentGradient = NSGradient(colors: [hex(0xF04A58), hex(0xC82838)]) else { return }
    accentGradient.draw(in: accent, angle: 270)

    fillRoundedRect(x: 190, y: 186, width: 234, height: 46, radius: 23, color: hex(0xF7F8FA, alpha: 0.12))
    drawText("PASS AI PARTNER", x: 236, y: 186, font: englishFont(34, .bold), color: hex(0xFF4E58), kern: 3)

    drawText("MATHEMATICS", x: 190, y: 512, font: englishFont(90, .bold), color: hex(0xF7F8FA), kern: 8)
    drawText("봉투모의고사", x: 190, y: 620, font: koreanFont(248, .heavy), color: .white, kern: -8)
    drawText("단원·난이도 맞춤 실전 테스트", x: 198, y: 834, font: koreanFont(62, .semibold), color: hex(0xB9C7DA), kern: -2)
    strokeLine(x1: 194, y1: 930, x2: 1226, y2: 930, color: hex(0xE63946), width: 10)
    drawText("학원별 진도에 맞춘 구성으로 바로 배포할 수 있는 봉투형 모의고사 커버", x: 194, y: 984, width: 1180, font: koreanFont(48, .medium), color: hex(0xD7E0EC), lineHeight: 66)
    drawText("정기 테스트, 특강 패키지, 월간 실전 훈련물에 모두 어울리는 프리미엄 인상", x: 194, y: 1112, width: 1180, font: koreanFont(48, .medium), color: hex(0xD7E0EC), lineHeight: 66)

    fillRoundedRect(x: 190, y: 1358, width: 1048, height: 1160, radius: 54, color: hex(0xF7F8FA))
    fillRoundedRect(x: 190, y: 1358, width: 1048, height: 176, radius: 54, color: hex(0xE63946))
    drawText("응시 정보", x: 274, y: 1408, font: koreanFont(78, .bold), color: .white, kern: -2)
    drawFieldBlock(title: "ACADEMY", value: "학원명", x: 278, y: 1710, width: 870, accent: hex(0x6B7280))
    drawFieldBlock(title: "TARGET", value: "학년 / 반", x: 278, y: 2072, width: 870, accent: hex(0x6B7280))
    drawFieldBlock(title: "DATE", value: "시행일", x: 278, y: 2434, width: 870, accent: hex(0x6B7280))

    fillRoundedRect(x: 1494, y: 1960, width: 778, height: 558, radius: 44, color: hex(0xFFFFFF, alpha: 0.08))
    strokeRoundedRect(x: 1494, y: 1960, width: 778, height: 558, radius: 44, color: hex(0x355176), lineWidth: 4)
    drawText("SERIES", x: 1576, y: 2110, font: englishFont(54, .bold), color: .white, kern: 2.5)
    drawText("MOCK EXAM", x: 1576, y: 2208, width: 620, font: englishFont(152, .black, condensed: true), color: .white, kern: -6, lineHeight: 156)

    strokeCircle(cx: 1768, cy: 2972, radius: 322, color: hex(0x334D70), width: 4)
    strokeCircle(cx: 1768, cy: 2972, radius: 222, color: hex(0x334D70), width: 4, dash: [24, 18])
    fillCircle(cx: 1768, cy: 2972, radius: 4, color: hex(0xA6B6CB))
    strokeLine(x1: 1554, y1: 3058, x2: 1608, y2: 2990, color: hex(0xE63946), width: 12)
    strokeLine(x1: 1608, y1: 2990, x2: 1704, y2: 2930, color: hex(0xE63946), width: 12)
    strokeLine(x1: 1704, y1: 2930, x2: 1828, y2: 2920, color: hex(0xE63946), width: 12)
    strokeLine(x1: 1828, y1: 2920, x2: 1936, y2: 2944, color: hex(0xE63946), width: 12)
    strokeLine(x1: 1936, y1: 2944, x2: 2068, y2: 2882, color: hex(0xE63946), width: 12)

    drawText("CUSTOM TEST COVER / 2026 EDITION", x: 190, y: 3228, font: englishFont(42, .bold), color: hex(0xB9C7DA), kern: 6)
    let noSize = measureText("No. 01", font: englishFont(60, .black), kern: 2)
    drawText("No. 01", x: canvasWidth - 190 - noSize.width, y: 3220, font: englishFont(60, .black), color: .white, kern: 2)
}

func drawWeeklyCover() {
    drawGradientRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight, colors: [hex(0xFBFCFD), hex(0xEEF2F7)], angle: 270)
    drawGrid(step: 120, line: hex(0xD6DCE5, alpha: 0.95), dots: hex(0xD5DDE7, alpha: 0.45), dotStep: 24)

    fillRoundedRect(x: 152, y: 138, width: 2176, height: 88, radius: 28, color: hex(0x0F1B2D))
    fillCircle(cx: 2264, cy: 182, radius: 20, color: hex(0xE63946))
    drawText("PASS AI PARTNER / WEEKLY STUDY PROGRAM", x: 212, y: 154, font: englishFont(44, .bold), color: .white, kern: 4)

    drawGradientRect(x: 152, y: 326, width: 1288, height: 1624, radius: 62, colors: [hex(0x14233A), hex(0x0F1B2D)], angle: 270)
    fillCircle(cx: 1180, cy: 548, radius: 242, color: hex(0xFFFFFF, alpha: 0.05))
    strokeCircle(cx: 1180, cy: 548, radius: 166, color: hex(0x506784), width: 4)
    strokeCircle(cx: 1180, cy: 548, radius: 100, color: hex(0x506784), width: 4, dash: [18, 16])
    strokeLine(x1: 1036, y1: 584, x2: 1104, y2: 504, color: hex(0xE63946), width: 12)
    strokeLine(x1: 1104, y1: 504, x2: 1184, y2: 456, color: hex(0xE63946), width: 12)
    strokeLine(x1: 1184, y1: 456, x2: 1272, y2: 448, color: hex(0xE63946), width: 12)
    strokeLine(x1: 1272, y1: 448, x2: 1352, y2: 464, color: hex(0xE63946), width: 12)

    fillRoundedRect(x: 240, y: 430, width: 292, height: 58, radius: 29, color: hex(0xE63946))
    drawText("WEEKLY STUDY", x: 288, y: 443, font: englishFont(34, .bold), color: .white, kern: 3)
    drawText("주간학습지", x: 240, y: 616, font: koreanFont(236, .heavy), color: .white, kern: -9)
    drawText("이번 주 학습 목표와 단원 점검을 한 장에 정리하는 표지", x: 246, y: 902, width: 1050, font: koreanFont(62, .semibold), color: hex(0xC7D3E4), lineHeight: 78)
    strokeLine(x1: 244, y1: 1118, x2: 1188, y2: 1118, color: hex(0xE63946), width: 10)

    fillRoundedRect(x: 240, y: 1138, width: 1112, height: 620, radius: 42, color: hex(0xFFFFFF, alpha: 0.07))
    strokeRoundedRect(x: 240, y: 1138, width: 1112, height: 620, radius: 42, color: hex(0x2C4567), lineWidth: 4)
    drawText("THIS WEEK", x: 320, y: 1216, font: englishFont(38, .bold), color: hex(0xE63946), kern: 4)
    drawText("학습 목표", x: 320, y: 1316, font: koreanFont(86, .bold), color: .white, kern: -2)
    strokeLine(x1: 320, y1: 1470, x2: 1272, y2: 1470, color: hex(0x456384), width: 5)
    drawText("핵심 개념 복습 / 주간 오답 점검 / 숙제 수행 관리", x: 320, y: 1538, width: 910, font: koreanFont(52, .medium), color: hex(0xD9E2EE), lineHeight: 72)
    drawText("학원명, 범위, 목표, 체크포인트를 빠르게 적어 배포하기 좋은 구성", x: 320, y: 1652, width: 910, font: koreanFont(52, .medium), color: hex(0xD9E2EE), lineHeight: 72)

    drawGradientRect(x: 1522, y: 326, width: 806, height: 874, radius: 62, colors: [hex(0xF15B68), hex(0xD53646)], angle: 270)
    drawText("TRACKER", x: 1608, y: 452, font: englishFont(40, .bold), color: hex(0xFFE7EA), kern: 5)
    drawText("WEEK\n01", x: 1608, y: 564, width: 640, font: englishFont(174, .black, condensed: true), color: .white, kern: -6, lineHeight: 164)
    drawText("주간 리듬을 만드는 수학\n학습 커버", x: 1608, y: 872, width: 620, font: koreanFont(48, .semibold), color: hex(0xFFF4F5), lineHeight: 62)
    fillRoundedRect(x: 1608, y: 1018, width: 632, height: 146, radius: 30, color: hex(0xFFFFFF, alpha: 0.14))
    drawText("RANGE", x: 1664, y: 1054, font: englishFont(32, .bold), color: hex(0xFFE7EA), kern: 3)
    drawText("이번 주 범위", x: 1664, y: 1094, font: koreanFont(60, .bold), color: .white, kern: -2)

    fillRoundedRect(x: 1522, y: 1280, width: 806, height: 1672, radius: 62, color: .white)
    strokeRoundedRect(x: 1522, y: 1280, width: 806, height: 1672, radius: 62, color: hex(0xD8DEE8), lineWidth: 4)
    drawText("배포 정보", x: 1608, y: 1388, font: koreanFont(78, .bold), color: hex(0x0F1B2D), kern: -2)

    fillRoundedRect(x: 1608, y: 1536, width: 632, height: 184, radius: 28, color: hex(0xF7F8FA))
    drawText("ACADEMY", x: 1660, y: 1596, font: englishFont(34, .bold), color: hex(0x6B7280), kern: 3)
    drawText("학원명", x: 1660, y: 1654, font: koreanFont(72, .bold), color: hex(0x0F1B2D), kern: -2)

    fillRoundedRect(x: 1608, y: 1760, width: 302, height: 184, radius: 28, color: hex(0xF7F8FA))
    drawText("GRADE", x: 1658, y: 1820, font: englishFont(34, .bold), color: hex(0x6B7280), kern: 3)
    drawText("학년", x: 1658, y: 1878, font: koreanFont(72, .bold), color: hex(0x0F1B2D), kern: -2)

    fillRoundedRect(x: 1938, y: 1760, width: 302, height: 184, radius: 28, color: hex(0xF7F8FA))
    drawText("WEEK", x: 1990, y: 1820, font: englishFont(34, .bold), color: hex(0x6B7280), kern: 3)
    drawText("차수", x: 1990, y: 1878, font: koreanFont(72, .bold), color: hex(0x0F1B2D), kern: -2)

    drawText("점검 포인트", x: 1608, y: 2052, font: koreanFont(60, .bold), color: hex(0x0F1B2D), kern: -1.5)

    let items: [(CGFloat, Int, String, Int)] = [
        (2200, 0xFFF0F2, "핵심 개념 확인", 0xE63946),
        (2346, 0xF7F8FA, "오답 유형 정리", 0x0F1B2D),
        (2492, 0xFFF0F2, "과제 수행 체크", 0xE63946),
        (2638, 0xF7F8FA, "다음 주 예고", 0x0F1B2D)
    ]
    for (y, bg, title, bullet) in items {
        fillRoundedRect(x: 1608, y: y, width: 632, height: 118, radius: 24, color: hex(bg))
        fillCircle(cx: 1670, cy: y + 59, radius: 16, color: hex(bullet))
        drawText(title, x: 1712, y: y + 28, font: koreanFont(46, .bold), color: hex(0x0F1B2D), kern: -1)
    }

    fillRoundedRect(x: 152, y: 2094, width: 1288, height: 858, radius: 62, color: .white)
    strokeRoundedRect(x: 152, y: 2094, width: 1288, height: 858, radius: 62, color: hex(0xD8DEE8), lineWidth: 4)
    drawText("커버 메모", x: 244, y: 2192, font: koreanFont(84, .bold), color: hex(0x0F1B2D), kern: -2)
    strokeLine(x1: 244, y1: 2334, x2: 1316, y2: 2334, color: hex(0xE1E5EC), width: 5)
    drawText("학생 이름 / 학습 범위 / 지도 포인트를 적고 바로 배포할 수 있는 주간 표지", x: 244, y: 2392, width: 1040, font: koreanFont(52, .semibold), color: hex(0x6B7280), lineHeight: 72)

    fillRoundedRect(x: 244, y: 2546, width: 1098, height: 120, radius: 28, color: hex(0xF7F8FA))
    drawText("학생명", x: 300, y: 2574, font: koreanFont(48, .bold), color: hex(0x0F1B2D), kern: -1)
    strokeLine(x1: 500, y1: 2610, x2: 1274, y2: 2610, color: hex(0xD4DAE3), width: 5)

    fillRoundedRect(x: 244, y: 2696, width: 1098, height: 120, radius: 28, color: hex(0xFFF0F2))
    drawText("이번 주 범위", x: 300, y: 2724, font: koreanFont(48, .bold), color: hex(0x0F1B2D), kern: -1)
    strokeLine(x1: 612, y1: 2760, x2: 1274, y2: 2760, color: hex(0xE8BFC6), width: 5)

    fillRoundedRect(x: 244, y: 2846, width: 1098, height: 120, radius: 28, color: hex(0xF7F8FA))
    drawText("지도 메모", x: 300, y: 2874, font: koreanFont(48, .bold), color: hex(0x0F1B2D), kern: -1)
    strokeLine(x1: 560, y1: 2910, x2: 1274, y2: 2910, color: hex(0xD4DAE3), width: 5)

    drawText("WEEKLY COVER / CLEAN ACADEMY EDITION", x: 152, y: 3248, font: englishFont(40, .bold), color: hex(0x6B7280), kern: 5)
    let noSize = measureText("No. 02", font: englishFont(58, .black), kern: 2)
    drawText("No. 02", x: canvasWidth - 152 - noSize.width, y: 3238, font: englishFont(58, .black), color: hex(0x0F1B2D), kern: 2)
}

func renderJPEG(fileName: String, draw: () -> Void) throws {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasWidth),
        pixelsHigh: Int(canvasHeight),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "render", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to allocate bitmap"])
    }

    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw NSError(domain: "render", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create graphics context"])
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    hex(0xFFFFFF).setFill()
    NSRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight).fill()
    draw()
    NSGraphicsContext.restoreGraphicsState()

    guard let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.95]) else {
        throw NSError(domain: "render", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JPEG"])
    }

    let outputDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("assets/covers/rendered", isDirectory: true)
    try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
    let url = outputDir.appendingPathComponent(fileName)
    try data.write(to: url)
    print("Rendered \(url.path)")
}

do {
    try renderJPEG(fileName: "bongtu-mock-cover.jpg", draw: drawMockExamCover)
    try renderJPEG(fileName: "weekly-study-cover.jpg", draw: drawWeeklyCover)
} catch {
    fputs("Render failed: \(error)\n", stderr)
    exit(1)
}
