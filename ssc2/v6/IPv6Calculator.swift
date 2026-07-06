//
//  IPv6Calculator.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/16/25.
//

import CIDR
import Foundation

/// Thin adapter over the swift-cidr library.
///
/// Parsing, network math, and RFC 5952 compression are delegated to
/// `CIDR.IPv6Address` / `CIDR.IPNetwork`. A small structural pre-check stays
/// here because the library parser is more lenient than this app's historical
/// contract (see `validateStructure(_:)`), and the zero-padded expanded form
/// plus the host-count presentation strings are app-specific.
struct IPv6SubnetCalculator {
    // MARK: - Types

    struct SubnetInfo {
        let compressedAddress: String
        let expandedAddress: String
        let subnetPrefix: String
        let numberOfSlash64Networks: String
        let totalHosts: String
        let firstAddress: String
        let lastAddress: String
    }

    // MARK: - Public Methods

    /// Calculates subnet information for the given IPv6 address and prefix length
    /// - Parameters:
    ///   - address: The IPv6 address as a string
    ///   - prefixLength: The number of mask bits as an integer (0-128)
    /// - Returns: A SubnetInfo struct containing all calculated information
    /// - Throws: InvalidAddressError, InvalidPrefixLengthError
    func calculateSubnet(address: String, prefixLength: Int) throws -> SubnetInfo {
        // Validate inputs (prefix length first — its error takes precedence)
        guard prefixLength >= 0 && prefixLength <= 128 else {
            throw SubnetError.invalidPrefixLength
        }

        // Remove any IPv6 zone index if present
        var ipAddress = address
        if let percentIndex = ipAddress.firstIndex(of: "%") {
            ipAddress = String(ipAddress[..<percentIndex])
        }

        // Deliberately reject IPv4-mapped / mixed notation (the library would
        // happily parse it; this app never has)
        if ipAddress.contains(".") {
            throw SubnetError.ipv4MappedAddressesNotSupported
        }

        // Structural strictness the library parser does not enforce
        try Self.validateStructure(ipAddress)

        guard let parsed = IPv6Address(ipAddress),
              let network = IPNetwork(address: parsed, prefixLength: UInt8(prefixLength))
        else {
            throw SubnetError.invalidAddress
        }

        return SubnetInfo(
            compressedAddress: parsed.formatted(.compressed),
            expandedAddress: Self.zeroPaddedExpandedAddress(parsed.address),
            subnetPrefix: "\(network.formatted(.compressed))/\(prefixLength)",
            numberOfSlash64Networks: calculateNumberOfSlash64Networks(prefixLength: prefixLength),
            totalHosts: calculateTotalHosts(prefixLength: prefixLength),
            firstAddress: network.first.formatted(.compressed),
            lastAddress: network.last.formatted(.compressed)
        )
    }

    // MARK: - Private Methods

    /// Rejects malformed shapes that `CIDR.IPv6Address.init?` accepts but this
    /// app has always rejected:
    /// - a no-op "::" alongside eight explicit groups (e.g. "1:2:3:4:5:6:7:8::",
    ///   "::1:2:3:4:5:6:7:8", "1:2:3:4:5:6:7::8")
    /// - groups written with more than four hex digits (e.g. "1:2:3:00000::",
    ///   which the library accepts because its value still fits in 16 bits)
    /// - a dangling single colon next to a "::" (e.g. "1::2:")
    ///
    /// Everything else (non-hex characters, wrong group counts, multiple "::",
    /// leading/trailing single colons, triple colons) is rejected by the
    /// library parser itself.
    private static func validateStructure(_ ipAddress: String) throws {
        // The library's IPv6 initializer accepts a trailing "/n" CIDR suffix
        // (e.g. "2001:db8::/64"); this app has always rejected slashes here.
        guard !ipAddress.contains("/") else {
            throw SubnetError.invalidAddress
        }

        let parts = ipAddress.components(separatedBy: "::")

        // At most one "::"
        guard parts.count <= 2 else {
            throw SubnetError.invalidAddress
        }

        if parts.count == 2 {
            let leftParts = parts[0].isEmpty ? [] : parts[0].components(separatedBy: ":")
            let rightParts = parts[1].isEmpty ? [] : parts[1].components(separatedBy: ":")

            guard !leftParts.contains("") && !rightParts.contains("") else {
                throw SubnetError.invalidAddress
            }

            guard leftParts.allSatisfy({ $0.count <= 4 }) && rightParts.allSatisfy({ $0.count <= 4 }) else {
                throw SubnetError.invalidAddress
            }

            // The "::" must replace at least one group
            guard leftParts.count + rightParts.count < 8 else {
                throw SubnetError.invalidAddress
            }
        } else {
            let segments = ipAddress.components(separatedBy: ":")

            guard segments.count == 8 else {
                throw SubnetError.invalidAddress
            }

            guard segments.allSatisfy({ !$0.isEmpty && $0.count <= 4 }) else {
                throw SubnetError.invalidAddress
            }
        }
    }

    /// Formats raw address bits as the fully expanded form: eight lowercase,
    /// zero-padded four-digit hex groups (e.g. "2001:0db8:0000:...").
    /// The library has no zero-padded style, so this is derived here.
    private static func zeroPaddedExpandedAddress(_ value: UInt128) -> String {
        var groups = [String]()
        groups.reserveCapacity(8)

        for index in 0..<8 {
            let shift = (7 - index) * 16
            let group = UInt16(truncatingIfNeeded: value >> shift)
            groups.append(String(format: "%04x", UInt32(group)))
        }

        return groups.joined(separator: ":")
    }

    /// Calculates the number of /64 networks contained in this subnet
    /// - Parameter prefixLength: The subnet prefix length
    /// - Returns: The number of /64 networks as a formatted string
    private func calculateNumberOfSlash64Networks(prefixLength: Int) -> String {
        if prefixLength >= 64 {
            return "1" // A /64 or smaller subnet contains exactly one /64 network
        } else {
            // Calculate 2^(64-prefixLength)
            let exponent = 64 - prefixLength
            let numberOfNetworks = pow(2.0, Double(exponent))

            // Format using e notation if needed
            if numberOfNetworks >= 1_000_000 {
                return String(format: "%.5e", numberOfNetworks)
            } else {
                return String(format: "%.0f", numberOfNetworks)
            }
        }
    }

    /// Calculates the total number of IPv6 hosts in the subnet
    /// - Parameter prefixLength: The subnet prefix length
    /// - Returns: The total number of hosts as a formatted string
    private func calculateTotalHosts(prefixLength: Int) -> String {
        // Calculate 2^(128-prefixLength)
        let exponent = 128 - prefixLength

        // For such large numbers, we use scientific notation
        // IPv6 host counts are enormous, so we always use e notation
        let totalHosts = pow(2.0, Double(exponent))
        return String(format: "%.5e", totalHosts)
    }

    // MARK: - Error Types

    enum SubnetError: Error, LocalizedError {
        case invalidAddress
        case invalidPrefixLength
        case ipv4MappedAddressesNotSupported

        var errorDescription: String? {
            switch self {
            case .invalidAddress:
                return "Invalid IPv6 address format"
            case .invalidPrefixLength:
                return "Prefix length must be between 0 and 128"
            case .ipv4MappedAddressesNotSupported:
                return "IPv4-mapped IPv6 addresses are not supported"
            }
        }
    }
}

// MARK: - Example Usage

// Example usage:
// let calculator = IPv6SubnetCalculator()
// do {
//     let info = try calculator.calculateSubnet(address: "2001:db8::", prefixLength: 48)
//     print("Compressed: \(info.compressedAddress)")
//     print("Expanded: \(info.expandedAddress)")
//     print("Subnet Prefix: \(info.subnetPrefix)")
//     print("Number of /64 Networks: \(info.numberOfSlash64Networks)")
//     print("Total Hosts: \(info.totalHosts)")
// } catch {
//     print("Error: \(error.localizedDescription)")
// }
