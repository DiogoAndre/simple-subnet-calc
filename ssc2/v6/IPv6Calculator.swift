//
//  IPv6Calculator.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/16/25.
//

import Foundation

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
        // Validate inputs
        guard prefixLength >= 0 && prefixLength <= 128 else {
            throw SubnetError.invalidPrefixLength
        }
        
        // Expand and normalize the address
        let expandedAddress = try expandIPv6Address(address)
        
        // Calculate subnet prefix
        let subnetPrefix = try calculateSubnetPrefix(expandedAddress, prefixLength: prefixLength)
        
        // Calculate number of /64 networks
        let numberOfSlash64Networks = calculateNumberOfSlash64Networks(prefixLength: prefixLength)
        
        // Calculate total hosts
        let totalHosts = calculateTotalHosts(prefixLength: prefixLength)
        
        // Compress the address
        let compressedAddress = try compressIPv6Address(expandedAddress)
        
        // Calculate first and last addresses
        let firstAddress = try calculateFirstAddress(expandedAddress, prefixLength: prefixLength)
        let lastAddress = try calculateLastAddress(expandedAddress, prefixLength: prefixLength)
        
        return SubnetInfo(
            compressedAddress: compressedAddress,
            expandedAddress: expandedAddress,
            subnetPrefix: subnetPrefix,
            numberOfSlash64Networks: numberOfSlash64Networks,
            totalHosts: totalHosts,
            firstAddress: firstAddress,
            lastAddress: lastAddress
        )
    }
    
    // MARK: - Private Methods
    
    /// Expands an IPv6 address to its full form
    /// - Parameter address: The IPv6 address to expand
    /// - Returns: The fully expanded IPv6 address
    /// - Throws: InvalidAddressError if the address cannot be expanded
    private func expandIPv6Address(_ address: String) throws -> String {
        // Remove any IPv6 zone index if present
        var ipAddress = address
        if let percentIndex = ipAddress.firstIndex(of: "%") {
            ipAddress = String(ipAddress[..<percentIndex])
        }
        
        // Handle IPv4-mapped addresses
        if ipAddress.contains(".") {
            throw SubnetError.ipv4MappedAddressesNotSupported
        }
        
        // Split the address by the "::" delimiter
        let parts = ipAddress.components(separatedBy: "::")
        
        // Validate that we have at most one "::" in the address
        guard parts.count <= 2 else {
            throw SubnetError.invalidAddress
        }
        
        if parts.count == 2 {
            // Handle the case with "::"
            let leftParts = parts[0].isEmpty ? [] : parts[0].components(separatedBy: ":")
            let rightParts = parts[1].isEmpty ? [] : parts[1].components(separatedBy: ":")

            guard !leftParts.contains("") && !rightParts.contains("") else {
                throw SubnetError.invalidAddress
            }

            guard leftParts.allSatisfy({ $0.count <= 4 }) && rightParts.allSatisfy({ $0.count <= 4 }) else {
                throw SubnetError.invalidAddress
            }

            // Calculate how many groups we need to add
            let totalGroups = 8
            let missingGroups = totalGroups - leftParts.count - rightParts.count

            guard missingGroups > 0 else {
                throw SubnetError.invalidAddress
            }

            // Build full parts array with zeroes for the compressed section
            var fullParts = leftParts
            fullParts.append(contentsOf: Array(repeating: "0000", count: missingGroups))
            fullParts.append(contentsOf: rightParts)

            // Ensure each part is 4 characters by padding with leading zeroes
            let expandedParts = fullParts.map { part in
                let paddedPart = String(repeating: "0", count: max(0, 4 - part.count)) + part
                return paddedPart
            }

            guard expandedParts.count == 8 else {
                throw SubnetError.invalidAddress
            }

            return expandedParts.joined(separator: ":")
        } else {
            // Handle the case without "::"
            let segments = ipAddress.components(separatedBy: ":")

            guard segments.count == 8 else {
                throw SubnetError.invalidAddress
            }

            guard segments.allSatisfy({ !$0.isEmpty && $0.count <= 4 }) else {
                throw SubnetError.invalidAddress
            }

            // Ensure each part is 4 characters
            let expandedParts = segments.map { part in
                let paddedPart = String(repeating: "0", count: max(0, 4 - part.count)) + part
                return paddedPart
            }

            return expandedParts.joined(separator: ":")
        }
    }
    
    /// Compresses an IPv6 address according to RFC 5952
    /// - Parameter expandedAddress: The fully expanded IPv6 address
    /// - Returns: The compressed IPv6 address
    /// - Throws: InvalidAddressError if the address cannot be compressed
    private func compressIPv6Address(_ expandedAddress: String) throws -> String {
        let segments = expandedAddress.components(separatedBy: ":")
        
        guard segments.count == 8 else {
            throw SubnetError.invalidAddress
        }
        
        // Remove leading zeros from each segment
        let compressedSegments = segments.map { segment in
            let trimmed = segment.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
            return trimmed.isEmpty ? "0" : trimmed
        }
        
        // Find the longest run of zeros to compress
        var longestZeroRunStart = -1
        var longestZeroRunLength = 0
        var currentZeroRunStart = -1
        var currentZeroRunLength = 0
        
        for (index, segment) in compressedSegments.enumerated() {
            if segment == "0" {
                if currentZeroRunStart == -1 {
                    currentZeroRunStart = index
                    currentZeroRunLength = 1
                } else {
                    currentZeroRunLength += 1
                }
            } else {
                if currentZeroRunLength > longestZeroRunLength {
                    longestZeroRunStart = currentZeroRunStart
                    longestZeroRunLength = currentZeroRunLength
                }
                currentZeroRunStart = -1
                currentZeroRunLength = 0
            }
        }
        
        // Check if we ended with a run of zeros
        if currentZeroRunLength > longestZeroRunLength {
            longestZeroRunStart = currentZeroRunStart
            longestZeroRunLength = currentZeroRunLength
        }
        
        // Compress the longest run of zeros if it's at least 2 segments
        if longestZeroRunLength >= 2 {
            var result = ""
            
            for i in 0..<longestZeroRunStart {
                result += compressedSegments[i] + ":"
            }
            
            result += ":"
            
            for i in (longestZeroRunStart + longestZeroRunLength)..<8 {
                result += compressedSegments[i]
                if i < 7 {
                    result += ":"
                }
            }

            // Leading zero-run produces a single leading ':'; pad to '::'.
            // Trailing zero-run already ends in '::' from the explicit `result += ":"`
            // above, so no symmetric fixup is needed (the previous one over-appended).
            if result.hasPrefix(":") && !result.hasPrefix("::") {
                result = ":" + result
            }

            return result
        } else {
            // No compression, just join the segments
            return compressedSegments.joined(separator: ":")
        }
    }
    
    /// Calculates the subnet prefix for the given address and prefix length
    /// - Parameters:
    ///   - expandedAddress: The fully expanded IPv6 address
    ///   - prefixLength: The number of mask bits
    /// - Returns: The subnet prefix in CIDR notation
    /// - Throws: InvalidAddressError, InvalidPrefixLengthError
    private func calculateSubnetPrefix(_ expandedAddress: String, prefixLength: Int) throws -> String {
        guard prefixLength >= 0 && prefixLength <= 128 else {
            throw SubnetError.invalidPrefixLength
        }
        
        let segments = expandedAddress.components(separatedBy: ":")
        guard segments.count == 8 else {
            throw SubnetError.invalidAddress
        }
        
        var binaryAddress = ""
        for segment in segments {
            guard let value = UInt16(segment, radix: 16) else {
                throw SubnetError.invalidAddress
            }
            
            let binarySegment = String(value, radix: 2)
            let paddedBinarySegment = String(repeating: "0", count: 16 - binarySegment.count) + binarySegment
            binaryAddress += paddedBinarySegment
        }
        
        // Apply the prefix length
        let prefixBinary = String(binaryAddress.prefix(prefixLength))
        let zerosToPad = 128 - prefixBinary.count
        let fullBinary = prefixBinary + String(repeating: "0", count: zerosToPad)
        
        // Convert binary back to hexadecimal
        var result = ""
        var index = fullBinary.startIndex
        
        for _ in 0..<8 {
            var segmentBinary = ""
            for _ in 0..<16 {
                segmentBinary += String(fullBinary[index])
                index = fullBinary.index(after: index)
            }
            
            if let value = UInt16(segmentBinary, radix: 2) {
                let hexString = String(format: "%x", value)
                let paddedHex = String(repeating: "0", count: 4 - hexString.count) + hexString
                result += paddedHex + ":"
            } else {
                throw SubnetError.invalidAddress
            }
        }
        
        result.removeLast() // Remove the trailing ":"
        
        // Compress the result
        let compressedPrefix = try compressIPv6Address(result)
        return "\(compressedPrefix)/\(prefixLength)"
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
    
    /// Calculates the first address in the subnet
    /// - Parameters:
    ///   - expandedAddress: The fully expanded IPv6 address
    ///   - prefixLength: The subnet prefix length
    /// - Returns: The first IP address in the subnet (network address)
    /// - Throws: InvalidAddressError, InvalidPrefixLengthError
    private func calculateFirstAddress(_ expandedAddress: String, prefixLength: Int) throws -> String {
        guard prefixLength >= 0 && prefixLength <= 128 else {
            throw SubnetError.invalidPrefixLength
        }
        
        // First address is simply the network address (prefix) with all zeros after the prefix
        let segments = expandedAddress.components(separatedBy: ":")
        guard segments.count == 8 else {
            throw SubnetError.invalidAddress
        }
        
        var binaryAddress = ""
        for segment in segments {
            guard let value = UInt16(segment, radix: 16) else {
                throw SubnetError.invalidAddress
            }
            
            let binarySegment = String(value, radix: 2)
            let paddedBinarySegment = String(repeating: "0", count: 16 - binarySegment.count) + binarySegment
            binaryAddress += paddedBinarySegment
        }
        
        // Get the network portion
        let networkBinary = prefixLength > 0 ? String(binaryAddress.prefix(prefixLength)) : ""
        
        // Add zeros for the host portion
        let fullBinary = networkBinary + String(repeating: "0", count: 128 - networkBinary.count)
        
        // Convert binary back to hexadecimal segments
        var addressSegments = [String]()
        
        for i in 0..<8 {
            let startIndex = fullBinary.index(fullBinary.startIndex, offsetBy: i * 16)
            let endIndex = fullBinary.index(startIndex, offsetBy: 16)
            let segmentBinary = String(fullBinary[startIndex..<endIndex])
            
            guard let value = UInt16(segmentBinary, radix: 2) else {
                throw SubnetError.invalidAddress
            }
            
            let hexString = String(format: "%04x", value)
            addressSegments.append(hexString)
        }
        
        // Join segments and compress
        let expandedFirstAddress = addressSegments.joined(separator: ":")
        return try compressIPv6Address(expandedFirstAddress)
    }
    
    /// Calculates the last address in the subnet
    /// - Parameters:
    ///   - expandedAddress: The fully expanded IPv6 address
    ///   - prefixLength: The subnet prefix length
    /// - Returns: The last IP address in the subnet
    /// - Throws: InvalidAddressError, InvalidPrefixLengthError
    private func calculateLastAddress(_ expandedAddress: String, prefixLength: Int) throws -> String {
        guard prefixLength >= 0 && prefixLength <= 128 else {
            throw SubnetError.invalidPrefixLength
        }
        
        // Last address is the network address with all bits after prefix set to 1
        let segments = expandedAddress.components(separatedBy: ":")
        guard segments.count == 8 else {
            throw SubnetError.invalidAddress
        }
        
        var binaryAddress = ""
        for segment in segments {
            guard let value = UInt16(segment, radix: 16) else {
                throw SubnetError.invalidAddress
            }
            
            let binarySegment = String(value, radix: 2)
            let paddedBinarySegment = String(repeating: "0", count: 16 - binarySegment.count) + binarySegment
            binaryAddress += paddedBinarySegment
        }
        
        // Get the network portion
        let networkBinary = prefixLength > 0 ? String(binaryAddress.prefix(prefixLength)) : ""
        
        // Add ones for the host portion
        let fullBinary = networkBinary + String(repeating: "1", count: 128 - networkBinary.count)
        
        // Convert binary back to hexadecimal segments
        var addressSegments = [String]()
        
        for i in 0..<8 {
            let startIndex = fullBinary.index(fullBinary.startIndex, offsetBy: i * 16)
            let endIndex = fullBinary.index(startIndex, offsetBy: 16)
            let segmentBinary = String(fullBinary[startIndex..<endIndex])
            
            guard let value = UInt16(segmentBinary, radix: 2) else {
                throw SubnetError.invalidAddress
            }
            
            let hexString = String(format: "%04x", value)
            addressSegments.append(hexString)
        }
        
        // Join segments and compress
        let expandedLastAddress = addressSegments.joined(separator: ":")
        return try compressIPv6Address(expandedLastAddress)
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
