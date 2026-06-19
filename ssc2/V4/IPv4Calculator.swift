//
//  IPv4Calculator.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/8/25.
//

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
        
        // Convert IP address to UInt32
        let ipValue = try convertIPToUInt32(ipAddress)
        
        // Calculate subnet mask
        let mask: UInt32 = maskBits == 0 ? 0 : ~0 << (32 - maskBits)
        
        // Calculate network address
        let networkValue = ipValue & mask
        
        // Calculate broadcast address
        let broadcastValue = networkValue | ~mask
        
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
            networkAddress: convertUInt32ToIP(networkValue),
            broadcastAddress: convertUInt32ToIP(broadcastValue),
            subnetMask: convertUInt32ToIP(mask),
            numberOfHosts: numberOfHosts
        )
    }
    
    /// Converts a string IP address to a UInt32 representation
    /// - Parameter ipAddress: IPv4 address as a string (e.g., "192.168.1.1")
    /// - Returns: UInt32 representation of the IP address
    /// - Throws: An error if the IP address is invalid
    private static func convertIPToUInt32(_ ipAddress: String) throws -> UInt32 {
        let octets = ipAddress.split(separator: ".")
        
        guard octets.count == 4 else {
            throw IPv4Error.invalidIPFormat
        }
        
        var result: UInt32 = 0
        
        for (index, octetString) in octets.enumerated() {
            guard let octet = UInt8(octetString) else {
                throw IPv4Error.invalidOctet
            }
            
            result = result | (UInt32(octet) << (8 * (3 - index)))
        }
        
        return result
    }
    
    /// Converts a UInt32 representation of an IP address to a string
    /// - Parameter value: UInt32 representation of an IP address
    /// - Returns: String representation of the IP address (e.g., "192.168.1.1")
    private static func convertUInt32ToIP(_ value: UInt32) -> String {
        let octet1 = (value >> 24) & 0xFF
        let octet2 = (value >> 16) & 0xFF
        let octet3 = (value >> 8) & 0xFF
        let octet4 = value & 0xFF
        
        return "\(octet1).\(octet2).\(octet3).\(octet4)"
    }
    
    /// Errors that can occur during IPv4 calculations
    enum IPv4Error: Error {
        case invalidIPFormat
        case invalidOctet
        case invalidMaskBits
        case invalidIPAddress
    }
}
