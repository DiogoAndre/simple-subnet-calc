# Simple Subnet Calc

Fast, Clean, and Built for Pros — A lightweight subnet calculator for IPv4 and IPv6 networks.

[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/pe/app/simple-subnet-calc/id665684290)

## Overview

Simple Subnet Calc is a clean and intuitive subnet calculator designed for network engineers, sysadmins, IT professionals, and students. With support for both IPv4 and IPv6 subnetting, it provides essential networking calculations without ads or clutter.

## Features

- **IPv4 Subnet Calculator**
  - CIDR notation support
  - Network address calculation
  - Broadcast address identification
  - Available host range
  - Binary representation
  - Custom numeric keypad for easy input

- **IPv6 Subnet Calculator**
  - Full IPv6 address support
  - Prefix length calculations
  - Compressed notation
  - Custom hexadecimal keypad

- **User Experience**
  - Pull down to quickly reset IP address input
  - Smart delete behavior for seamless editing
  - Clean, distraction-free interface
  - No ads or unnecessary features
  - Optimized for one-handed use

## Platform Support

- **iPhone** (iOS 18.0+) - Fully tested
- **iPad** (iOS 18.0+) - Should work but not extensively tested
- **Mac** (Apple Silicon) - Should work but not extensively tested
- **Apple Vision Pro** - Should work but not extensively tested

## Building the Project

This project is built using Xcode and SwiftUI.

### Requirements
- Xcode 16.3 or later (the swift-cidr dependency requires a Swift 6.1 toolchain)
- iOS 18.0+ deployment target
- macOS 15.2+ (for Mac development)

### Dependencies
- [swift-cidr](https://github.com/RouteObjects/swift-cidr) 0.2.0 (`CIDR` module) — resolved automatically by Xcode via Swift Package Manager.

### Build Instructions
1. Clone the repository
2. Open `Simple Subnet Calc.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (⌘R)

## Privacy

Simple Subnet Calc respects your privacy — no data is collected, stored, or transmitted by the app.

## App Store

Download the latest version from the App Store:
https://apps.apple.com/pe/app/simple-subnet-calc/id665684290

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

CIDR math (address parsing, network/broadcast calculation, and RFC 5952 compression) is powered by [swift-cidr](https://github.com/RouteObjects/swift-cidr), licensed under Apache-2.0.

## Author

Developed by Diogo Andre Assumpcao