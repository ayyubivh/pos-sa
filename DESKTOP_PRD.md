# EazyERP POS — Desktop Version
## Product Requirements Document & Strategic Planning Guide

**Version:** 1.0  
**Date:** April 18, 2026  
**Author:** Engineering Team  
**Status:** Draft — Pending Stakeholder Review

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Goals & Success Metrics](#2-goals--success-metrics)
3. [Target Platforms](#3-target-platforms)
4. [Stakeholders & Users](#4-stakeholders--users)
5. [Feature Parity Analysis](#5-feature-parity-analysis)
6. [UX & Design Requirements](#6-ux--design-requirements)
7. [Tech Stack & Architecture](#7-tech-stack--architecture)
8. [Desktop-Specific Features](#8-desktop-specific-features)
9. [Non-Functional Requirements](#9-non-functional-requirements)
10. [Milestones & Timeline](#10-milestones--timeline)
11. [Risk Assessment](#11-risk-assessment)
12. [Open Questions](#12-open-questions)

---

## 1. Executive Summary

EazyERP POS is a production-grade point-of-sale and field operations management system built in Flutter. The current app targets Android and iOS (mobile-first, portrait-locked) and is actively used by field sales representatives managing B2B sales workflows including invoicing, inventory, expense tracking, customer relationship management, attendance, and reporting.

This document defines requirements, strategy, and a delivery plan for a **first-class desktop version** of the same application targeting **Windows, macOS, and Linux**. The desktop version must serve counter-sales environments (cashier stations, back-office management, warehouse), where large screens, keyboard/mouse input, and continuous-power operation offer fundamentally different — and higher-throughput — usage patterns than mobile.

The Flutter codebase already scaffolds Windows, macOS, and Linux targets and includes `sqflite_common_ffi` for desktop database support, reducing the bootstrapping effort. The primary work is **UX re-architecture for large screens**, hardware integration (receipt printers, barcode scanners, cash drawers), and adaptation of mobile-specific affordances.

---

## 2. Goals & Success Metrics

### 2.1 Business Goals

| # | Goal |
|---|------|
| G1 | Extend EazyERP POS to counter-sales and back-office environments without maintaining a separate codebase |
| G2 | Improve checkout throughput for high-volume retailers using keyboard shortcuts and scanner hardware |
| G3 | Enable back-office users (managers, accountants) to process reports, manage inventory, and approve expenses from a workstation |
| G4 | Provide an offline-capable desktop install that syncs with the EazyERP cloud when connectivity is available |
| G5 | Support multi-terminal deployments (multiple desktops per location, shared back-end) |

### 2.2 Success Metrics

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| Checkout transaction time | ≤ 30s per sale on desktop vs. ~60s on mobile | In-app timing log |
| Feature parity score | ≥ 95% of mobile features available on desktop | Feature checklist audit |
| Crash-free sessions | ≥ 99.5% on each desktop platform | Crash reporting tool |
| Offline resilience | App fully functional with 0 connectivity for ≥ 8 hours | Manual & automated QA |
| Receipt print success rate | ≥ 99% via USB/network thermal printers | Hardware integration test |
| Time-to-ship v1.0 desktop | ≤ 20 weeks from kickoff | Project tracking |

---

## 3. Target Platforms

### 3.1 Priority Order

| Priority | Platform | Rationale |
|----------|----------|-----------|
| P0 | **Windows 10/11 (x64)** | Dominant OS in retail/SMB environments in target markets |
| P1 | **macOS 12+ (Apple Silicon + Intel)** | Premium retail, Apple-ecosystem customers |
| P2 | **Linux (Ubuntu 22.04 LTS, x64)** | Budget-conscious deployments, kiosk use |

### 3.2 Minimum System Requirements

| Component | Windows | macOS | Linux |
|-----------|---------|-------|-------|
| OS Version | Windows 10 1903+ | macOS 12 Monterey+ | Ubuntu 22.04 / Debian 11+ |
| CPU | x64, 2GHz+ | Apple M1 or Intel x64 | x64, 2GHz+ |
| RAM | 4 GB | 4 GB | 4 GB |
| Disk | 500 MB free | 500 MB free | 500 MB free |
| Display | 1280×720 min | 1280×800 min | 1280×720 min |
| Network | Optional (offline mode) | Optional (offline mode) | Optional (offline mode) |

### 3.3 Recommended Hardware for POS Station

- 15–24" touch or non-touch monitor
- USB or Bluetooth barcode scanner (HID keyboard-emulation mode)
- USB/Ethernet thermal receipt printer (ESC/POS protocol, 80mm)
- Cash drawer (triggered via printer RJ11/USB)
- Customer-facing display (second monitor or tablet) — Phase 2

---

## 4. Stakeholders & Users

### 4.1 User Personas

#### Persona A — Cashier (Primary Desktop User)
- Processes 50–200 transactions/day
- Needs: fast product lookup, barcode scan-to-cart, quick payment capture, receipt print
- Proficiency: Basic computer literacy
- Key pain point on mobile: Small screen makes high-volume scanning tedious

#### Persona B — Store Manager
- Reviews daily sales reports, manages inventory, approves expenses
- Needs: rich reporting dashboards, export to PDF/CSV, multi-terminal visibility
- Proficiency: Intermediate
- Key pain point: Cannot see full reports on a phone screen efficiently

#### Persona C — Back-Office Accountant
- Manages expenses, reconciles payments, exports data
- Needs: Keyboard-driven data entry, bulk operations, profit/loss reports
- Proficiency: High (comfortable with spreadsheets)

#### Persona D — Field Force Supervisor
- Tracks field reps, views visit logs, reviews attendance
- Could use either mobile or desktop

### 4.2 Stakeholders

| Stakeholder | Interest |
|-------------|---------|
| Product Owner | Feature parity, on-time delivery |
| Engineering Lead | Architecture, code quality, maintainability |
| QA Team | Cross-platform test coverage |
| Sales/BD | Winning retail & SMB accounts |
| End Customers | Reliability, ease of use |

---

## 5. Feature Parity Analysis

### 5.1 Feature Matrix

| Feature Module | Mobile Status | Desktop Target | Notes |
|----------------|--------------|----------------|-------|
| **Authentication** | ✓ OAuth2 login | ✓ Full parity | Desktop can cache tokens more aggressively |
| **Dashboard / Home** | ✓ Statistics widget | ✓ Enhanced — multi-panel layout | Sidebar + content area on desktop |
| **Product Catalog** | ✓ Browse, filter | ✓ Full parity + keyboard search | Larger grid view |
| **Cart** | ✓ Flip-card UI | ✓ Redesign — table/list UI | Flip-card is touch idiom; replace with table |
| **Barcode Scan** | ✓ Camera scan | ✓ USB HID scanner support | Camera scan demoted to secondary |
| **Checkout / Payment** | ✓ Payment types | ✓ Full parity + cash-drawer trigger | Add keyboard shortcut flow |
| **Receipt Printing** | ✓ Bluetooth thermal | ✓ USB/network thermal + PDF | Upgrade print stack |
| **Sales History** | ✓ List view | ✓ Table view + filter/sort | |
| **Invoice PDF** | ✓ HTML→PDF | ✓ Full parity | |
| **Customer / Contacts** | ✓ CRM lite | ✓ Full parity | |
| **Contact Payments** | ✓ | ✓ Full parity | |
| **Expenses** | ✓ | ✓ Full parity | |
| **Shipment** | ✓ | ✓ Full parity | |
| **Field Force** | ✓ | ✓ Read-only on desktop (Phase 1) | GPS tracking stays on mobile |
| **Follow-Up Scheduling** | ✓ | ✓ Full parity | |
| **Brands / Units** | ✓ Admin screens | ✓ Full parity | |
| **Reports** | ✓ Sales, P&L, Stock | ✓ Enhanced — charts, export | Add export to CSV/Excel |
| **Notifications** | ✓ Push | ✓ System tray notifications | Platform notification API |
| **Attendance / Clock-In** | ✓ GPS-based | ✗ Excluded Phase 1 | Desktop lacks GPS; Phase 2 with IP-based |
| **Maps / Visit Tracking** | ✓ Google Maps | ✗ Excluded Phase 1 | Field-only feature |
| **Theme / Locale** | ✓ AR/EN, dark/light | ✓ Full parity | |
| **Offline Sync** | ✓ SQLite + cron | ✓ Full parity | sqflite_ffi already in pubspec |
| **QR Generation** | ✓ | ✓ Full parity | |
| **Image Upload** | ✓ Camera/gallery | ✓ File picker instead | Replace image_picker with file_selector |
| **Multi-location** | ✓ | ✓ Full parity | |
| **Cash Drawer** | ✗ Not on mobile | ✓ Phase 1 desktop-only | ESC/POS trigger |
| **Customer Display** | ✗ | ✓ Phase 2 | Second-screen support |
| **Keyboard Shortcuts** | ✗ | ✓ Phase 1 desktop-only | Full shortcut map |
| **CSV/Excel Export** | ✗ | ✓ Phase 1 desktop-only | Report export |
| **Window Management** | ✗ | ✓ Phase 1 desktop-only | Resizable, multi-window (Phase 2) |

### 5.2 Features Requiring Redesign (Not Simple Port)

1. **Navigation shell** — Bottom tab bar → Left sidebar (NavigationRail/Drawer)
2. **Cart UI** — Flip-card animation → Inline editable table
3. **Barcode input** — Camera preview → HID keyboard stream
4. **Printer integration** — Bluetooth → USB/Network ESC/POS stack
5. **Image input** — `image_picker` → `file_selector` package
6. **Layout** — Portrait-locked → Adaptive responsive layout

---

## 6. UX & Design Requirements

### 6.1 Layout System

The app must implement an **adaptive layout** that responds to window width:

| Breakpoint | Width | Layout |
|------------|-------|---------|
| Compact | < 600px | Single pane (mobile-like, for small windows) |
| Medium | 600–1024px | Two-pane (sidebar + content) |
| Expanded | > 1024px | Three-pane (sidebar + main + detail/panel) |

### 6.2 Navigation

- **Primary:** Left `NavigationRail` (collapsed icons) expanding to full `NavigationDrawer` (icons + labels) at ≥ 720px width
- **Secondary:** Breadcrumb trail for deep navigation
- **No bottom navigation bar** on desktop
- Keyboard navigation: `Tab` traversal, `Escape` to close dialogs, `Enter` to confirm

### 6.3 Interaction Model

| Interaction | Mobile | Desktop |
|-------------|--------|---------|
| Select product | Tap card | Click card OR type barcode OR keyboard search |
| Add to cart | Tap button | `Enter` or `+` key |
| Adjust quantity | Tap spinner | Direct keyboard input in table cell |
| Delete line | Swipe | `Delete` key or button |
| Complete sale | Tap checkout | `F5` shortcut |
| Print receipt | Tap print | `Ctrl+P` or auto-print on completion |
| Open cash drawer | N/A | `F8` shortcut |
| New sale | Tap | `F1` shortcut |

### 6.4 Typography & Density

- Use a **compact density** preset (Material 3 `VisualDensity.compact`) for data-heavy screens (sales history, reports, contacts)
- Font size floors: body 13sp, label 12sp (slightly smaller than mobile's 14sp minimums)
- Tables must support column sorting and horizontal scrolling for narrow windows

### 6.5 Receipt Printer UI

- Printer selection persists in `SharedPreferences` (USB port name or IP)
- Status indicator (connected/disconnected) always visible in status bar
- Print preview before committing (optional setting)

### 6.6 Accessibility

- Full keyboard navigability for all primary flows
- Screen reader support (Semantics widgets on all interactive elements)
- High-contrast mode via existing theme system

---

## 7. Tech Stack & Architecture

### 7.1 Existing Stack (Retained)

| Layer | Technology | Notes |
|-------|-----------|-------|
| Framework | Flutter 3.22+ / Dart 3.4+ | Upgrade from 3.10 for desktop stability fixes |
| State Management | flutter_bloc (Cubit) | Retained, platform-agnostic |
| HTTP | Dio 5.x | Retained |
| Local DB | sqflite + sqflite_common_ffi | Already in pubspec — activate FFI path for desktop |
| PDF | printing + htmltopdfwidgets | Retained; add desktop PDF-viewer widget |
| i18n | flutter_localizations | Retained |
| Theme | Material 3 + custom AppTheme | Retained; add desktop density tokens |

### 7.2 Packages to Add (Desktop)

| Package | Purpose | Priority |
|---------|---------|---------|
| `window_manager` | Window title, size constraints, minimize/restore | P0 |
| `file_selector` | File open/save dialogs (replace `image_picker`) | P0 |
| `local_notifier` | System tray / native desktop notifications | P0 |
| `screen_retriever` | Multi-monitor detection for customer display | P1 |
| `pos_printer` or `esc_pos_utils` + `dart_periphery` | ESC/POS thermal printer over USB/network | P0 |
| `win32` (Windows only) | Cash drawer GPIO via COM port (Windows only) | P1 |
| `flutter_acrylic` | Windows 11 Mica/Acrylic titlebar | P2 cosmetic |
| `bitsdojo_window` | Frameless window chrome (optional) | P2 cosmetic |

### 7.3 Packages to Replace

| Remove | Replace With | Reason |
|--------|-------------|--------|
| `barcode_scan2` (camera) | HID keyboard stream + `barcode_scan2` as fallback | No camera on most desktops |
| `image_picker` | `file_selector` | image_picker has no desktop support |
| `permission_handler` | Platform guards (no-op on desktop) | Desktop has different permission model |
| `geolocator` | Stub/no-op on desktop | No GPS on desktop |
| `google_maps_flutter` | Exclude on desktop builds | No field maps on desktop |
| `flashy_tab_bar2` | `NavigationRail` / `NavigationDrawer` | Bottom tab bar not suitable for desktop |

### 7.4 Adaptive Platform Code Pattern

Use compile-time platform detection via `dart:io` and Flutter's `kIsWeb`:

```dart
// In widget trees
if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  return DesktopLayout(child: content);
} else {
  return MobileLayout(child: content);
}
```

Keep business logic in Cubits and Services unchanged. Only the **presentation layer** diverges.

### 7.5 Architecture Changes

```
lib/
├── core/                    # No change
├── data/services/           # No change — platform-agnostic
├── domain/models/           # No change
├── models/                  # No change
├── apis/                    # No change
├── viewmodel/               # No change (Cubits)
├── locale/                  # No change
│
├── presentation/
│   ├── screens/             # Existing mobile screens (no change)
│   ├── desktop/             # NEW — desktop-specific screens
│   │   ├── layout/          # DesktopShell, NavigationRail, StatusBar
│   │   ├── cart/            # Desktop cart table UI
│   │   ├── checkout/        # Desktop checkout (keyboard flow)
│   │   ├── reports/         # Enhanced report views with charts
│   │   └── settings/        # Printer config, shortcut config
│   └── adaptive/            # NEW — adaptive wrapper widgets
│       ├── adaptive_layout.dart
│       ├── adaptive_nav.dart
│       └── adaptive_scaffold.dart
│
├── helpers/
│   ├── desktop/             # NEW
│   │   ├── keyboard_shortcuts.dart
│   │   ├── printer_service.dart    # ESC/POS abstraction
│   │   └── cash_drawer_service.dart
│   └── ...existing...
│
└── main.dart                # Platform-aware initialization
```

### 7.6 Desktop Initialization

`main.dart` gains a desktop bootstrap block:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(900, 600),
      center: true,
      title: 'EazyERP POS',
    );
    await windowManager.waitUntilReadyToShow(windowOptions);
    await windowManager.show();
  }

  runApp(MyApp());
}
```

---

## 8. Desktop-Specific Features

### 8.1 Keyboard Shortcut System

A global `CallbackShortcuts` / `Shortcuts` widget wraps the desktop shell.

| Shortcut | Action |
|----------|--------|
| `F1` | New Sale |
| `F2` | Customer Search |
| `F3` | Product Search |
| `F4` | Hold Sale / Recall |
| `F5` | Proceed to Checkout |
| `F6` | Apply Discount |
| `F7` | Print Last Receipt |
| `F8` | Open Cash Drawer |
| `F9` | Clock In / Clock Out |
| `F10` | Daily Summary Report |
| `F12` | Toggle Fullscreen |
| `Ctrl+Z` | Remove Last Cart Item |
| `Ctrl+P` | Print (any context) |
| `Ctrl+S` | Save / Complete current action |
| `Escape` | Cancel / Close dialog |
| `Ctrl+,` | Open Settings |
| `Ctrl+Q` | Quit |

### 8.2 Receipt Printer Service

Abstraction supporting multiple transport layers:

```
PrinterService
├── UsbPrinter (dart_periphery / platform channel)
├── NetworkPrinter (TCP socket to ESC/POS printer IP:9100)
├── BluetoothPrinter (mobile only — excluded on desktop)
└── PdfPrinter (virtual — save/open PDF via printing package)
```

Configuration stored in `SharedPreferences`:
- `printer_type`: usb | network | pdf
- `printer_port`: COM3 / /dev/usb/lp0 / 192.168.1.100:9100
- `auto_print_on_sale`: true/false
- `paper_width`: 80mm | 56mm

### 8.3 Cash Drawer Integration

Triggered via `DK` ESC/POS command sent through the printer connection (most cash drawers connect via RJ11 to the printer). No separate driver needed.

```dart
Future<void> openCashDrawer() async {
  // ESC/POS: ESC p 0 25 250
  await printerService.sendRaw([0x1B, 0x70, 0x00, 0x19, 0xFA]);
}
```

### 8.4 Window Management

- Minimum window size: 900×600
- Default launch size: 1280×800, centered
- Remember last window position/size across sessions
- Support fullscreen mode (`F12`)
- Prevent accidental close if sale is in progress (unsaved cart warning dialog)

### 8.5 System Tray

- App minimizes to system tray instead of closing (configurable)
- Tray icon shows connection status (green = synced, yellow = pending sync, red = offline)
- Tray menu: Open, New Sale, Sync Now, Quit

### 8.6 Report Enhancements (Desktop-Only)

- Add a charting library (`fl_chart`) for visual sales dashboards
- Export buttons: **Download PDF**, **Download CSV**, **Print**
- Date range picker with keyboard input support
- Side-by-side comparison: current period vs. previous period

### 8.7 Multi-Terminal Sync

When multiple desktops share one EazyERP backend:
- Each terminal registers itself with a `terminal_id` (UUID stored in SharedPreferences)
- Sales uploaded to API are tagged with `terminal_id`
- Reports can filter by terminal or show aggregate
- Local SQLite is per-terminal; cloud is the source of truth

---

## 9. Non-Functional Requirements

### 9.1 Performance

| Metric | Target |
|--------|--------|
| App cold start | < 3 seconds |
| Product search response | < 300ms (local SQLite) |
| Cart render (50 items) | < 100ms |
| Report generation (1000 records) | < 2 seconds |
| Receipt print trigger to paper | < 4 seconds |

### 9.2 Offline Capability

- All POS operations (browse, cart, checkout, receipt) must work with zero connectivity
- Sync queue persists across restarts
- Conflict resolution: last-write-wins for most entities; manual resolution UI for payment conflicts
- Connectivity status always visible in status bar

### 9.3 Security

- OAuth2 tokens stored in platform keychain (Windows Credential Manager, macOS Keychain, Linux Secret Service via `flutter_secure_storage`)
- Auto-lock after configurable idle timeout (default 10 minutes) — requires PIN/password to re-enter
- All API traffic over HTTPS
- No plaintext credentials in logs or SharedPreferences

### 9.4 Installer & Distribution

| Platform | Format | Signing |
|----------|--------|---------|
| Windows | MSIX or NSIS installer | Code-signed (EV cert recommended) |
| macOS | `.dmg` with `.app` | Notarized + Developer ID signed |
| Linux | `.deb` (Ubuntu/Debian), AppImage (universal) | GPG signed |

Auto-update via `upgrader` package or custom update channel (compare `app_version` from API endpoint).

### 9.5 Accessibility

- WCAG 2.1 AA compliance for all primary flows
- Full keyboard-only operation for checkout flow
- Screen reader support (Windows Narrator, macOS VoiceOver)

### 9.6 Logging & Crash Reporting

- Structured local log file (rolling, 7-day retention) in platform app-data directory
- Crash reports sent to Sentry or Firebase Crashlytics (with user consent)
- `dart:developer` service extension for debug builds

---

## 10. Milestones & Timeline

**Total estimated duration: 20 weeks (5 months)**  
Team assumption: 2 Flutter developers, 1 QA engineer, 1 UI/UX designer (part-time)

---

### Phase 0 — Foundation (Weeks 1–2)

**Goal:** Dev environment, platform scaffolding, and baseline running on all 3 desktop OSes.

| Task | Owner | Duration |
|------|-------|----------|
| Audit all packages for desktop compatibility; document replacements | Dev 1 | 2 days |
| Upgrade Flutter to 3.22+, resolve any breaking changes | Dev 1 | 1 day |
| Confirm Windows/macOS/Linux build succeeds (even if UI is broken) | Dev 1+2 | 2 days |
| Activate `sqflite_ffi` path in `main.dart` for desktop | Dev 2 | 1 day |
| Implement `window_manager` — size, title, close guard | Dev 2 | 2 days |
| Set up CI pipeline (GitHub Actions) for all 3 desktop targets | Dev 1 | 2 days |
| Design review: wireframes for desktop shell, cart table, checkout | Designer | 5 days |

**Exit Criteria:** App builds and launches on Windows, macOS, Linux. SQLite works on desktop. CI green.

---

### Phase 1 — Desktop Shell & Navigation (Weeks 3–5)

**Goal:** Adaptive navigation shell that replaces bottom tab bar with sidebar.

| Task | Owner | Duration |
|------|-------|----------|
| Build `AdaptiveLayout` widget (compact / medium / expanded breakpoints) | Dev 1 | 3 days |
| Build `DesktopShell` with `NavigationRail` → `NavigationDrawer` | Dev 1 | 3 days |
| Implement `StatusBar` widget (sync status, printer status, time, user) | Dev 2 | 2 days |
| Port splash and login screens to desktop layout | Dev 2 | 2 days |
| Port home/dashboard to 2-column desktop layout | Dev 1 | 3 days |
| Implement global keyboard shortcut scaffold | Dev 2 | 2 days |
| Replace `flashy_tab_bar2` with adaptive nav on desktop path | Dev 1 | 1 day |
| QA: navigation flow on all 3 platforms | QA | 3 days |

**Exit Criteria:** Desktop app navigates between all sections via sidebar. Login→Home works. Shortcuts skeleton registered.

---

### Phase 2 — Core POS Flow (Weeks 6–10)

**Goal:** Full cashier workflow — product → cart → checkout → receipt → cash drawer.

| Task | Owner | Duration |
|------|-------|----------|
| Desktop product list: table/grid with search input (keyboard-first) | Dev 1 | 3 days |
| Barcode HID input handler (global key listener → cart add) | Dev 2 | 3 days |
| Desktop cart: editable table with inline qty input, Delete key support | Dev 1 | 4 days |
| Wire F1–F8 shortcuts to POS actions | Dev 2 | 2 days |
| Desktop checkout screen: keyboard tab-through payment fields | Dev 1 | 3 days |
| Implement `PrinterService` abstraction (USB + Network + PDF) | Dev 2 | 5 days |
| Printer settings UI (port config, paper size, auto-print toggle) | Dev 2 | 2 days |
| Cash drawer trigger via ESC/POS command | Dev 2 | 1 day |
| Replace `image_picker` with `file_selector` on desktop | Dev 1 | 1 day |
| QA: end-to-end sale on all 3 platforms with USB printer | QA | 5 days |

**Exit Criteria:** Cashier can complete a full sale with barcode scanner and print receipt, triggered entirely by keyboard.

---

### Phase 3 — Management Screens (Weeks 11–14)

**Goal:** Port all non-POS screens with desktop-appropriate layouts.

| Task | Owner | Duration |
|------|-------|----------|
| Sales history: sortable/filterable table, date range picker | Dev 1 | 3 days |
| Customer/Contacts: two-pane (list + detail) desktop layout | Dev 1 | 3 days |
| Contact payments: desktop table with inline editing | Dev 2 | 2 days |
| Expenses: desktop form + filterable list | Dev 2 | 2 days |
| Shipment: desktop list + detail view | Dev 1 | 2 days |
| Brands/Units: admin table with inline edit/delete | Dev 2 | 2 days |
| Follow-up scheduling: calendar + list dual view | Dev 1 | 3 days |
| Field force (read-only supervisor view) | Dev 2 | 2 days |
| Notifications: desktop notification + system tray | Dev 2 | 2 days |
| QA: all management screens on all 3 platforms | QA | 4 days |

**Exit Criteria:** All management screens are usable on desktop with appropriate layout. No mobile-only widgets remain in the desktop path.

---

### Phase 4 — Reports & Export (Weeks 15–16)

**Goal:** Enhanced reporting with charts and data export.

| Task | Owner | Duration |
|------|-------|----------|
| Integrate `fl_chart` for sales line chart and category bar chart | Dev 1 | 3 days |
| Sales report: chart + table + period comparison | Dev 1 | 2 days |
| Profit/loss report: enhanced layout with chart | Dev 1 | 2 days |
| Product stock report: sortable table, low-stock highlight | Dev 2 | 2 days |
| Export to PDF (existing stack) and CSV (`csv` package) | Dev 2 | 2 days |
| QA: reports on all 3 platforms, CSV/PDF export validation | QA | 3 days |

**Exit Criteria:** Reports render charts on desktop. PDF and CSV export work and produce correct data.

---

### Phase 5 — Security, Polish & Packaging (Weeks 17–19)

**Goal:** Production-ready security, auto-lock, installers, and auto-update.

| Task | Owner | Duration |
|------|-------|----------|
| `flutter_secure_storage` for token storage on all desktop platforms | Dev 2 | 2 days |
| Auto-lock timer with PIN unlock screen | Dev 2 | 3 days |
| Window position/size persistence | Dev 1 | 1 day |
| System tray (minimize, tray menu) | Dev 1 | 2 days |
| Windows MSIX / NSIS installer setup | Dev 1 | 2 days |
| macOS DMG + notarization script | Dev 1 | 2 days |
| Linux .deb + AppImage build | Dev 2 | 2 days |
| Auto-update check via API version endpoint | Dev 2 | 2 days |
| Accessibility audit (keyboard nav, screen reader) | QA | 2 days |
| Performance profiling & optimization | Dev 1+2 | 2 days |

**Exit Criteria:** Signed installers produced for all 3 platforms. Auto-lock works. App passes accessibility audit.

---

### Phase 6 — Beta & Launch (Week 20)

| Task | Owner | Duration |
|------|-------|----------|
| Internal beta deploy to 3+ test POS stations | All | 3 days |
| Bug fixes from beta feedback | Dev 1+2 | 2 days |
| Final QA sign-off | QA | 2 days |
| v1.0 release — installers published to distribution channel | Dev 1 | 1 day |

**Exit Criteria:** v1.0 shipped with all P0 features. Known issues documented in backlog.

---

### Summary Timeline

```
Week:  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
       ├──────┤ ├─────────────┤ ├──────────────────┤ ├────┤ ├──────────────┤ ├──┤
Phase:    0         1                  2               3       4          5    6
```

---

## 11. Risk Assessment

### 11.1 Risk Register

| ID | Risk | Probability | Impact | Severity | Mitigation |
|----|------|-------------|--------|----------|-----------|
| R1 | **USB printer driver compatibility** varies by Windows version and printer model | High | High | Critical | Build abstraction layer early (Phase 2); test with 3+ physical printers; keep PDF fallback always available |
| R2 | **sqflite_ffi performance** on Windows with large datasets | Medium | Medium | Medium | Profile in Phase 0; consider drift + sqlite3_flutter_libs as fallback ORM |
| R3 | **Package compatibility** — some packages lack desktop support (`barcode_scan2`, `geolocator`) | High | Medium | High | Document replacements in Phase 0; platform guards prevent runtime crashes |
| R4 | **macOS code signing and notarization** complexity and Apple review delays | Medium | Medium | Medium | Start Apple Developer account setup in Week 1; build signing pipeline in Phase 5 |
| R5 | **Codebase divergence** — desktop and mobile paths drifting over time | Medium | High | High | Enforce shared business logic; only presentation layer forks; CI tests both paths |
| R6 | **UI complexity of adaptive layout** — three breakpoints × many screens | High | Medium | High | Designer delivers wireframes before Phase 1 coding; use `AdaptiveScaffold` from flutter_adaptive_scaffold package |
| R7 | **Cash drawer integration** — hardware variance (RJ11, USB, Bluetooth) | Medium | Medium | Medium | Default to printer-pass-through (most common); document hardware compatibility list |
| R8 | **Windows Defender / antivirus** false-positive on MSIX/NSIS installer | Low | High | Medium | Code-sign with EV certificate from Week 1; submit for AV whitelisting |
| R9 | **Timeline slippage** from printer and hardware integration unknowns | Medium | High | High | Hardware integration is on critical path — start Phase 2 PrinterService in parallel with Phase 1 |
| R10 | **API rate limits or auth token expiry** during long desktop sessions | Low | Medium | Low | Implement token refresh in Dio interceptor (may already exist — verify) |

### 11.2 Dependencies & Blockers

| Dependency | Owner | Risk if Delayed |
|-----------|-------|----------------|
| Physical test hardware (printer, scanner, cash drawer) | Ops/Procurement | Blocks Phase 2 hardware testing |
| Apple Developer account + EV cert | Finance/Legal | Blocks macOS distribution |
| Windows EV code-signing cert | Finance/Legal | Blocks Windows distribution |
| UI/UX wireframes for desktop shell | Designer | Blocks Phase 1 start |
| Access to staging EazyERP backend | Backend team | Blocks API integration testing |

### 11.3 Go/No-Go Criteria for v1.0 Launch

**Must-have (blocking):**
- [ ] All P0 features functional on Windows and macOS
- [ ] End-to-end sale + receipt print working on physical hardware
- [ ] No P0 (critical) bugs open
- [ ] Signed installers pass OS security checks without warnings
- [ ] Offline mode validated for 8-hour session

**Should-have (non-blocking for launch):**
- [ ] Linux .deb packaged (can ship as separate release)
- [ ] System tray (can be post-launch patch)
- [ ] CSV export (can be post-launch patch)

---

## 12. Open Questions

| # | Question | Owner | Deadline |
|---|----------|-------|---------|
| OQ1 | Will the desktop app be distributed as an in-house enterprise install or via Microsoft Store / Mac App Store? (Affects signing approach significantly) | Product Owner | Week 1 |
| OQ2 | Should multi-window support (e.g., reports in a separate window while the cashier screen stays open) be in Phase 1 or Phase 2? | Engineering Lead | Week 2 |
| OQ3 | Is there a customer-facing display requirement (second monitor showing cart items and total to the buyer)? If yes, what is the timeline? | Product Owner | Week 2 |
| OQ4 | What is the approved list of thermal printer models to certify? | Ops | Week 2 |
| OQ5 | Should the desktop app support multi-user sessions per machine (fast user switching) or is it always single-user-per-machine? | Product Owner | Week 1 |
| OQ6 | Will the auto-lock PIN be the same as the EazyERP login password, or a separate short PIN? | Product + Security | Week 3 |
| OQ7 | Does the desktop version need Arabic RTL layout support? (Flutter desktop RTL has some known rendering issues as of 2026) | Product Owner | Week 1 |
| OQ8 | Is the `eazyerp.co` API capable of handling concurrent requests from multiple terminals at the same location? What are the rate limits? | Backend Team | Week 2 |

---

## Appendix A — Shortcut Reference Card

*(To be printed and placed at each POS station)*

| Key | Action |
|-----|--------|
| F1 | New Sale |
| F2 | Customer Search |
| F3 | Product / Barcode Search |
| F4 | Hold Sale |
| F5 | Checkout |
| F6 | Discount |
| F7 | Reprint Last Receipt |
| F8 | Cash Drawer |
| F10 | Today's Report |
| F12 | Fullscreen |
| Ctrl+P | Print |
| Ctrl+Z | Remove Last Item |
| Escape | Cancel |

---

## Appendix B — Package Compatibility Matrix

| Package | Android | iOS | Windows | macOS | Linux | Action |
|---------|---------|-----|---------|-------|-------|--------|
| sqflite | ✓ | ✓ | ✗ | ✗ | ✗ | Use sqflite_ffi on desktop |
| sqflite_common_ffi | — | — | ✓ | ✓ | ✓ | Already in pubspec |
| image_picker | ✓ | ✓ | Partial | Partial | ✗ | Replace with file_selector |
| barcode_scan2 | ✓ | ✓ | ✗ | ✗ | ✗ | HID listener on desktop |
| geolocator | ✓ | ✓ | ✗ | ✗ | ✗ | Stub/exclude on desktop |
| google_maps_flutter | ✓ | ✓ | ✗ | ✗ | ✗ | Exclude on desktop (Phase 1) |
| permission_handler | ✓ | ✓ | Partial | Partial | ✗ | Platform guard |
| flashy_tab_bar2 | ✓ | ✓ | ✓ | ✓ | ✓ | Replace with NavigationRail |
| flutter_secure_storage | ✓ | ✓ | ✓ | ✓ | ✓ (libsecret) | Add for token storage |
| printing | ✓ | ✓ | ✓ | ✓ | ✓ | Retained |
| shared_preferences | ✓ | ✓ | ✓ | ✓ | ✓ | Retained |
| connectivity_plus | ✓ | ✓ | ✓ | ✓ | ✓ | Retained |
| url_launcher | ✓ | ✓ | ✓ | ✓ | ✓ | Retained |
| path_provider | ✓ | ✓ | ✓ | ✓ | ✓ | Retained |
| dio | ✓ | ✓ | ✓ | ✓ | ✓ | Retained |
| flutter_bloc | ✓ | ✓ | ✓ | ✓ | ✓ | Retained |
| lottie | ✓ | ✓ | ✓ | ✓ | ✓ | Retained |

---

*Document ends. Next step: stakeholder review and sign-off on OQ1, OQ5, OQ7 before Phase 0 kickoff.*
