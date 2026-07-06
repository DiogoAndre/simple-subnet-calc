//
//  IPv4Calculator.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/8/25.
//

import CIDR

/// Thin adapter over the swift-cidr library.
///
/// Input validation (and its error classification) stays here because the
/// library's IPv4 parser is more lenient than this app's historical contract
/// (e.g. it accepts leading-zero octets such as "010"). The actual CIDR math
/// (network/broadcast/mask) is delegated to `CIDR.IPNetwork`.
struct IPv4Calculator {

    struct SubnetInfo {
        let networkAddress: String
        let broadcastAddress: String
        let subnetMask: String
        let numberOfHosts: UInt32
    }

    /// Calculates subnet information for a given IPv4 address and mask bits
    /// - Parameters:
    ///   - ipAddress: The IPv4 address as a string (e.g., "192.168.1.1")
    ///   - maskBits: The number of network mask bits (0-32)
    /// - Returns: A SubnetInfo object containing network address, broadcast address, subnet mask, and host count
    /// - Throws: An error if the IP address is invalid or mask bits are out of range
    static func calculateSubnet(ipAddress: String, maskBits: Int) throws -> SubnetInfo {
        // Validate inputs
        guard maskBits >= 0 && maskBits <= 32 else {
            throw IPv4Error.invalidMaskBits
        }

        // Enforce this app's canonical dotted-quad rules (exactly four octets,
        // 0-255, no leading zeros, no signs) before handing off to the library.
        try validateCanonicalDottedQuad(ipAddress)

        // The pre-validation above guarantees the library parser accepts the
        // address, so these failures are unreachable in practice.
        guard let address = IPv4Address(ipAddress),
              let network = IPNetwork(address: address, prefixLength: UInt8(maskBits))
        else {
            throw IPv4Error.invalidIPFormat
        }

        // Calculate number of hosts (2^(32-maskBits) - 2)
        // Subtract 2 for network and broadcast addresses, unless it's a /31 or /32.
        // /0 is special-cased because (1 << 32) overshifts UInt32 (Swift traps).
        let hostBits = 32 - maskBits
        let numberOfHosts: UInt32

        switch maskBits {
        case 32:
            numberOfHosts = 1
        case 31:
            numberOfHosts = 2
        case 0:
            numberOfHosts = UInt32.max - 1
        default:
            numberOfHosts = (1 << hostBits) - 2
        }

        return SubnetInfo(
            networkAddress: network.first.addressLiteral,
            broadcastAddress: network.last.addressLiteral,
            subnetMask: AF.V4.formatAddress(network.mask),
            numberOfHosts: numberOfHosts
        )
    }

    /// Validates that a string is a canonical dotted-quad IPv4 address.
    ///
    /// Kept adapter-side (instead of relying on `CIDR.IPv4Address.init?`) so
    /// error classification and strictness match the historical behavior:
    /// - wrong octet count -> `.invalidIPFormat`
    /// - empty, non-numeric, signed, leading-zero, or out-of-range octets -> `.invalidOctet`
    private static func validateCanonicalDottedQuad(_ ipAddress: String) throws {
        let octets = ipAddress.split(separator: ".", omittingEmptySubsequences: false)

        guard octets.count == 4 else {
            throw IPv4Error.invalidIPFormat
        }

        for octetString in octets {
            guard octetString.count >= 1 && octetString.count <= 3 else {
                throw IPv4Error.invalidOctet
            }

            guard octetString.allSatisfy({ $0.isASCII && $0.isNumber }) else {
                throw IPv4Error.invalidOctet
            }

            guard octetString == "0" || octetString.first != "0" else {
                throw IPv4Error.invalidOctet
            }

            guard UInt8(octetString) != nil else {
                throw IPv4Error.invalidOctet
            }
        }
    }

    /// Errors that can occur during IPv4 calculations
    enum IPv4Error: Error {
        case invalidIPFormat
        case invalidOctet
        case invalidMaskBits
        case invalidIPAddress
    }
}
