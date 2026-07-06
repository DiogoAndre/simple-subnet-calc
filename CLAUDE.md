# Simple Subnet Calc (ssc2)

Native SwiftUI subnet calculator for IPv4 and IPv6. Ships on the App Store; iOS 18+ (also runs on iPad, Apple Silicon Mac, Vision Pro). Single Xcode project with one SPM dependency: [swift-cidr](https://github.com/RouteObjects/swift-cidr) (pinned to 0.2.0, `CIDR` product only — SwiftNIO and friends appear in the resolved graph but are never built into the app).

## Build & run

- Open `Simple Subnet Calc.xcodeproj` in Xcode 16.3+ (swift-cidr's manifest requires a Swift 6.1 toolchain); build with ⌘R.
- Command line build (Simulator):
  ```
  xcodebuild -project "Simple Subnet Calc.xcodeproj" -scheme ssc2 \
    -destination 'platform=iOS Simulator,name=iPhone 15' build
  ```
- Tests (`ssc2Tests`, `ssc2UITests`) are scaffolding only — no real coverage yet.

## Layout

- `ssc2/ssc2App.swift` — `@main` entry. Holds the single `AppState: ObservableObject` shared via `.environmentObject` (IPv4 octets, CIDR prefix `/22` default; IPv6 address string, prefix `/64` default).
- `ssc2/ContentView.swift` — root view with custom floating capsule tab bar (`FloatingTabBar`) switching IPv4 ⇄ IPv6.
- `ssc2/V4/` — IPv4 stack: `SubnetV4CalculatorView`, `IPv4Calculator` (thin adapter over swift-cidr; keeps this app's strict input validation and the `/0`, `/31`, `/32` host-count special cases), `IPTextField`, `NumericKeypadView`, `OctetBinaryView`.
- `ssc2/v6/` — IPv6 stack: `SubnetV6CalculatorView`, `IPv6Calculator` (thin adapter over swift-cidr; keeps stricter-than-library parsing guards, the zero-padded expanded form, and the host-count formatting), `IPv6TextField`, `HexKeypadView`.
- Shared UI bits at `ssc2/` root: `CardStyle.swift`, `KeyButton.swift`, `ResultRow.swift`, `CIDRBubbleShape.swift`.
- Note the casing split: `V4/` is uppercase, `v6/` is lowercase. Keep it as-is unless renaming intentionally.

## Conventions

- Pure SwiftUI; no UIKit wrappers. The only third-party package is swift-cidr (`CIDR` module, pinned 0.2.0 via up-to-next-minor); don't add others without an explicit ask. There is no SPM manifest — the dependency is wired through the Xcode project.
- The calculators must keep their exact public API and error behavior (pinned by `ssc2Tests`); swift-cidr is an implementation detail behind them, and views never import `CIDR` directly.
- Calculation logic lives in plain `struct`s (`IPv4Calculator`, `IPv6Calculator`) with `static` methods that `throw` on bad input — views never compute inline.
- Octet input is clamped to 0–255 inside `AppState.didSet`, not in the view layer.
- Custom keypads replace the system keyboard for both calculators — when adding input affordances, extend `NumericKeypadView` / `HexKeypadView` rather than reaching for `.keyboardType(...)`.
- Colors come from the asset catalog (`Color.appBackground`, `Color(.cardBackground)`) — avoid hard-coding hex values.

## Privacy

App collects nothing. Don't add analytics, crash reporters, or network calls without an explicit ask.
