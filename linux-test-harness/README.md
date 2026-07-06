# Linux test harness

Runs the `ssc2Tests` unit suite (the calculator tests) outside Xcode — on Linux
or macOS — via SwiftPM. The `Sources/` and `Tests/` entries are **symlinks**
into the real app tree, so this harness never drifts from the app code.

```sh
cd linux-test-harness
swift test
```

Requirements: a Swift 6.1+ toolchain (swift-cidr's manifest requires it).
In Claude Code on the web, `.claude/hooks/session-start.sh` installs the
toolchain automatically at session start.

Only the calculator logic is covered here; SwiftUI views and `ssc2UITests`
still require Xcode.
