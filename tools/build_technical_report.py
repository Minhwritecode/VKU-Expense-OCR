from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    PageTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
    PageBreak,
    KeepTogether,
    Image as ReportImage,
)


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output" / "pdf" / "ledgerly-technical-report-part2.pdf"
SCREENSHOT_DIR = ROOT / "docs" / "screenshots"
FONT_DIR = Path("/Users/macos/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/poppler/poppler/fonts")
pdfmetrics.registerFont(TTFont("DejaVuSans", str(FONT_DIR / "DejaVuSans.ttf")))
pdfmetrics.registerFont(TTFont("DejaVuSans-Bold", str(FONT_DIR / "Ubuntu-B.ttf")))

NAVY = colors.HexColor("#15345A")
COBALT = colors.HexColor("#2857A6")
INK = colors.HexColor("#18212F")
MUTED = colors.HexColor("#5E6A7A")
PAPER = colors.HexColor("#F8F5EE")
ORANGE = colors.HexColor("#E97845")
MINT = colors.HexColor("#CBEBDD")
LAVENDER = colors.HexColor("#E7E0FA")


styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="TitleVKU", parent=styles["Title"], fontName="DejaVuSans-Bold", fontSize=24, leading=29, textColor=NAVY, spaceAfter=7))
styles.add(ParagraphStyle(name="SubTitle", parent=styles["Normal"], fontName="DejaVuSans", fontSize=10, leading=14, textColor=MUTED, spaceAfter=15))
styles.add(ParagraphStyle(name="H1VKU", parent=styles["Heading1"], fontName="DejaVuSans-Bold", fontSize=15, leading=19, textColor=COBALT, spaceBefore=5, spaceAfter=7))
styles.add(ParagraphStyle(name="H2VKU", parent=styles["Heading2"], fontName="DejaVuSans-Bold", fontSize=10.5, leading=14, textColor=NAVY, spaceBefore=5, spaceAfter=4))
styles.add(ParagraphStyle(name="BodyVKU", parent=styles["BodyText"], fontName="DejaVuSans", fontSize=8.7, leading=13, textColor=INK, spaceAfter=5))
styles.add(ParagraphStyle(name="SmallVKU", parent=styles["BodyText"], fontName="DejaVuSans", fontSize=7.3, leading=10, textColor=MUTED, spaceAfter=3))
styles.add(ParagraphStyle(name="Cell", parent=styles["BodyText"], fontName="DejaVuSans", fontSize=7.2, leading=9.2, textColor=INK))
styles.add(ParagraphStyle(name="CellWhite", parent=styles["BodyText"], fontName="DejaVuSans", fontSize=7.2, leading=9.2, textColor=colors.white))
styles.add(ParagraphStyle(name="CenterCell", parent=styles["Cell"], alignment=TA_CENTER))


def P(text, style="BodyVKU"):
    return Paragraph(text, styles[style])


def table(data, widths, header=True, small=False):
    converted = []
    for r, row in enumerate(data):
        converted.append([P(str(value), "CellWhite" if header and r == 0 else ("Cell" if not small else "SmallVKU")) for value in row])
    t = Table(converted, colWidths=widths, repeatRows=1 if header else 0, hAlign="LEFT")
    commands = [
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#D4DCE7")),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]
    if header:
        commands += [("BACKGROUND", (0, 0), (-1, 0), NAVY), ("TEXTCOLOR", (0, 0), (-1, 0), colors.white)]
        for r in range(1, len(converted)):
            commands.append(("BACKGROUND", (0, r), (-1, r), colors.white if r % 2 else colors.HexColor("#F1F5F9")))
    t.setStyle(TableStyle(commands))
    return t


def architecture_flow():
    nodes = [
        [P("Camera / Gallery", "CellWhite"), P("ML Kit OCR<br/>offline", "CellWhite"), P("Regex parser<br/>total · date · merchant", "CellWhite"), P("Review form<br/>manual correction", "CellWhite"), P("SQLite<br/>history", "CellWhite")]
    ]
    t = Table(nodes, colWidths=[31*mm, 31*mm, 40*mm, 36*mm, 27*mm], rowHeights=[18*mm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (0, 0), ORANGE),
        ("BACKGROUND", (1, 0), (1, 0), COBALT),
        ("BACKGROUND", (2, 0), (2, 0), NAVY),
        ("BACKGROUND", (3, 0), (3, 0), colors.HexColor("#397A67")),
        ("BACKGROUND", (4, 0), (4, 0), colors.HexColor("#6E59A5")),
        ("BOX", (0, 0), (-1, -1), 0.7, colors.white),
        ("INNERGRID", (0, 0), (-1, -1), 1, colors.white),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
    ]))
    return t


def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(PAPER)
    canvas.rect(0, 0, A4[0], A4[1], fill=1, stroke=0)
    canvas.setFillColor(MUTED)
    canvas.setFont("Helvetica", 7)
    canvas.drawString(18*mm, 10*mm, "Ledgerly · VKU Expense OCR · Part 2")
    canvas.drawRightString(A4[0] - 18*mm, 10*mm, f"{doc.page}")
    canvas.restoreState()


class ReportDoc(BaseDocTemplate):
    def __init__(self, filename):
        super().__init__(filename, pagesize=A4, leftMargin=18*mm, rightMargin=18*mm, topMargin=15*mm, bottomMargin=17*mm)
        frame = Frame(self.leftMargin, self.bottomMargin, self.width, self.height, id="normal")
        self.addPageTemplates([PageTemplate(id="main", frames=frame, onPage=header_footer)])


def build():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    doc = ReportDoc(str(OUT))
    story = []
    story += [P("LEDGERLY", "TitleVKU"), P("Technical report · Mini-project 3 · Flutter Week 08 Part 2", "SubTitle")]
    story += [P("1. Product direction", "H1VKU"), P("Ledgerly is an offline-first expense tracker for VKU students and club managers. The product intentionally keeps a human, tactile feel: paper-like warm surfaces, cobalt navigation, compact cards, visible review steps and no generated content pretending to be a financial decision. OCR accelerates data entry; the user remains the final verifier.")]
    story += [P("2. Architecture and data flow", "H1VKU"), architecture_flow(), Spacer(1, 5*mm)]
    story += [P("Flutter presentation uses Material 3 with responsive NavigationBar / NavigationRail, a GoRouter ShellRoute for URL-addressable destinations, Riverpod for app state, SQLite for local persistence, and CustomPainter for the two charts. Native battery information is a small MethodChannel proof of Android Kotlin and iOS Swift interop.")]
    story += [P("Implemented layers", "H2VKU"), table([
        ["Layer", "Implementation", "Responsibility"],
        ["UI", "LedgerlyApp, AppShell, screens, widgets", "Responsive layout, theme, dark mode, dialogs and review sheet"],
        ["State", "ReceiptController + Riverpod", "Load, add, edit, delete, search and filter receipts"],
        ["Domain", "Receipt, ReceiptParser, parseVndInput", "Normalized data and deterministic OCR extraction"],
        ["Services", "OcrService, ReceiptRepository, DeviceInfoService", "ML Kit, SQLite/memory fallback, MethodChannel"],
        ["Navigation", "core/router.dart", "ShellRoute, guarded category query and receipt detail path"],
        ["Screens/widgets", "screens/ and widgets/", "Pages, review sheet, reusable cards and CustomPainter charts"],
    ], [28*mm, 55*mm, 69*mm])]
    story += [PageBreak(), P("3. OCR and parsing contract", "H1VKU"), P("Text recognition runs on-device through google_mlkit_text_recognition. The review form is deliberately mandatory: confidence is not silently treated as truth, and Vietnamese number grouping is normalized before persistence.")]
    story += [table([
        ["Field", "Pattern / strategy", "Fallback and review behavior"],
        ["Total", r"(?i)(total|amount|tổng|thành tiền)\s*[:：]?\s*([0-9][0-9., ]*)", "Normalize dots/commas/spaces; reject zero or invalid input"],
        ["Date", r"\b(20\d{2})[-/.](\d{1,2})[-/.](\d{1,2})\b", "Also accepts dd/mm/yyyy; future dates are blocked"],
        ["Merchant", "First non-empty OCR line not claimed as total/date", "User can edit merchant in the review sheet"],
        ["Category", "Keyword buckets: food, transport, shopping, bills, other", "Other is safe default; user can change category"],
    ], [25*mm, 75*mm, 52*mm])]
    story += [Spacer(1, 4*mm), P("4. Navigation, forms and native bridge", "H1VKU"), table([
        ["Sprint capability", "Delivered behavior"],
        ["GoRouter", "ShellRoute with /, /receipts, /insights, /settings; guarded category query and /receipts/:receiptId detail path. Fade/slide transitions preserve a calm deep-link flow."],
        ["Form safety", "Autovalidation after interaction, positive VND validation, focus traversal, date picker with future-date guard, save confirmation SnackBar."],
        ["MethodChannel", "vn.edu.vku/device_info returns battery percentage from Kotlin BatteryManager on Android and UIDevice on iOS; unsupported platforms fall back gracefully."],
        ["Adaptive UI", "Bottom navigation on compact widths; side rail and wider two-column content when space allows."],
    ], [35*mm, 117*mm])]
    story += [P("5. Visual language", "H1VKU"), table([
        ["Light mode", "Dark mode", "Interaction principles"],
        ["Warm paper #F8F5EE\nCobalt #2857A6\nOrange #E97845", "Ink surfaces with preserved cobalt/orange accents\nHigh-contrast text and chart colors", "Review before commit\nShort actions\nExplicit empty/error states\nTouch targets kept generous"],
    ], [48*mm, 48*mm, 56*mm])]
    light = ReportImage(str(SCREENSHOT_DIR / "dashboard-light.png"), width=47*mm, height=102*mm)
    dark = ReportImage(str(SCREENSHOT_DIR / "dashboard-dark.png"), width=47*mm, height=102*mm)
    screenshot_table = Table([[light, dark]], colWidths=[69*mm, 69*mm], hAlign="LEFT")
    screenshot_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.white),
        ("BOX", (0, 0), (-1, -1), 0.35, colors.HexColor("#D4DCE7")),
        ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#D4DCE7")),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]))
    story += [PageBreak(), P("6. Runtime screenshots", "H1VKU"), screenshot_table, Spacer(1, 3*mm), P("The screenshots were captured from the iPhone 15 Pro Max Simulator after a successful runtime launch. The light and dark surfaces keep the same information hierarchy, chart accent colors and navigation affordances while adapting contrast and elevation.", "SmallVKU")]
    story += [PageBreak(), P("7. Rubric and verification matrix", "H1VKU"), table([
        ["Rubric", "Evidence in project", "Status"],
        ["On-device OCR & heuristics · 3.5", "Camera/gallery, ML Kit, parser, review form", "Implemented"],
        ["Custom canvas visualization · 2.5", "Animated donut and weekly bar painters", "Implemented"],
        ["State management & DB · 2.0", "Riverpod StateNotifier, SQLite CRUD, memory fallback", "Implemented"],
        ["UI/UX polish · 1.0", "Material 3, dark mode, responsive shell, correction dialog", "Implemented"],
        ["Deliverables & report · 1.0", "This PDF, README, demo script, APK, simulator build, license and CI workflow", "Ready; student video/GitHub supplied"],
    ], [48*mm, 82*mm, 22*mm])]
    story += [P("Verification run", "H2VKU"), P("flutter analyze --no-fatal-infos: no issues found. flutter test: 4 tests passed, covering currency normalization, parser extraction, dashboard rendering and nested route registry. flutter build apk --release --no-pub: passed. flutter build appbundle --release --no-pub: passed. flutter build ios --simulator --no-codesign --no-pub: passed. iPhone Simulator smoke launch passed; physical-phone testing was confirmed by the student.")]
    story += [P("8. Known limitations and handoff", "H1VKU"), P("The current local APK uses the debug signing fallback because no private keystore was supplied. Before store submission, create the free private keystore described in docs/DEPLOYMENT.md, wire it through key.properties/Gradle, and rebuild. OCR quality depends on focus, lighting and the Latin model; receipts with unusual layouts still need manual correction. Video demo and GitHub handoff are supplied separately by the student.")]
    story += [P("Build artifacts", "H2VKU"), table([
        ["Artifact", "Path"],
        ["Android release-mode APK", "build/app/outputs/flutter-apk/app-release.apk"],
        ["Google Play AAB", "build/app/outputs/bundle/release/app-release.aab"],
        ["iOS Simulator app", "build/ios/iphonesimulator/Runner.app"],
        ["Demo script", "docs/DEMO_SCRIPT.md"],
    ], [53*mm, 99*mm])]
    doc.build(story)
    print(OUT)


if __name__ == "__main__":
    build()
