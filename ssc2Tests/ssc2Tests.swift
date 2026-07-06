//
//  ssc2Tests.swift
//  ssc2Tests
//
//  Created by Diogo Assumpcao on 4/8/25.
//

import Testing
@testable import Simple_Subnet_Calc

// MARK: - IPv4Calculator

@Suite("IPv4Calculator")
struct IPv4CalculatorTests {

    // MARK: Standard subnets

    @Test("/24 classful-style subnet")
    func slash24() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.10", maskBits: 24)
        #expect(info.networkAddress == "192.168.1.0")
        #expect(info.broadcastAddress == "192.168.1.255")
        #expect(info.subnetMask == "255.255.255.0")
        #expect(info.numberOfHosts == 254)
    }

    @Test("/16 subnet")
    func slash16() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "172.16.5.3", maskBits: 16)
        #expect(info.networkAddress == "172.16.0.0")
        #expect(info.broadcastAddress == "172.16.255.255")
        #expect(info.subnetMask == "255.255.0.0")
        #expect(info.numberOfHosts == 65534)
    }

    @Test("/8 subnet")
    func slash8() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "10.20.30.40", maskBits: 8)
        #expect(info.networkAddress == "10.0.0.0")
        #expect(info.broadcastAddress == "10.255.255.255")
        #expect(info.subnetMask == "255.0.0.0")
        #expect(info.numberOfHosts == 16_777_214)
    }

    // MARK: Non-octet-boundary masks

    @Test("/25 splits the last octet in half")
    func slash25() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.100", maskBits: 25)
        #expect(info.networkAddress == "192.168.1.0")
        #expect(info.broadcastAddress == "192.168.1.127")
        #expect(info.subnetMask == "255.255.255.128")
        #expect(info.numberOfHosts == 126)
    }

    @Test("/26 places a host in the second subnet")
    func slash26() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.130", maskBits: 26)
        #expect(info.networkAddress == "192.168.1.128")
        #expect(info.broadcastAddress == "192.168.1.191")
        #expect(info.subnetMask == "255.255.255.192")
        #expect(info.numberOfHosts == 62)
    }

    @Test("/30 four-address subnet")
    func slash30() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.10", maskBits: 30)
        #expect(info.networkAddress == "192.168.1.8")
        #expect(info.broadcastAddress == "192.168.1.11")
        #expect(info.subnetMask == "255.255.255.252")
        #expect(info.numberOfHosts == 2)
    }

    @Test("/2 quarter of the address space (general host-count formula)")
    func slash2() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "130.5.6.7", maskBits: 2)
        #expect(info.networkAddress == "128.0.0.0")
        #expect(info.broadcastAddress == "191.255.255.255")
        #expect(info.subnetMask == "192.0.0.0")
        #expect(info.numberOfHosts == 1_073_741_822)
    }

    @Test("/3 eighth of the address space (general host-count formula)")
    func slash3() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "130.5.6.7", maskBits: 3)
        #expect(info.networkAddress == "128.0.0.0")
        #expect(info.broadcastAddress == "159.255.255.255")
        #expect(info.subnetMask == "224.0.0.0")
        #expect(info.numberOfHosts == 536_870_910)
    }

    // MARK: Special-case masks

    @Test("/31 point-to-point link (RFC 3021) has 2 usable addresses")
    func slash31() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.10", maskBits: 31)
        #expect(info.networkAddress == "192.168.1.10")
        #expect(info.broadcastAddress == "192.168.1.11")
        #expect(info.subnetMask == "255.255.255.254")
        #expect(info.numberOfHosts == 2)
    }

    @Test("/32 single-host route")
    func slash32() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.10", maskBits: 32)
        #expect(info.networkAddress == "192.168.1.10")
        #expect(info.broadcastAddress == "192.168.1.10")
        #expect(info.subnetMask == "255.255.255.255")
        #expect(info.numberOfHosts == 1)
    }

    @Test("/1 very large subnet")
    func slash1() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "10.0.0.1", maskBits: 1)
        #expect(info.networkAddress == "0.0.0.0")
        #expect(info.broadcastAddress == "127.255.255.255")
        #expect(info.subnetMask == "128.0.0.0")
        #expect(info.numberOfHosts == 2_147_483_646)
    }

    @Test("/0 default route reports 2^32 - 2 hosts")
    func slash0() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "10.0.0.1", maskBits: 0)
        #expect(info.networkAddress == "0.0.0.0")
        #expect(info.broadcastAddress == "255.255.255.255")
        #expect(info.subnetMask == "0.0.0.0")
        #expect(info.numberOfHosts == 4_294_967_294)
    }

    // MARK: Invalid mask bits

    @Test("mask bits above 32 are rejected")
    func maskBitsTooHigh() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidMaskBits) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.1", maskBits: 33)
        }
    }

    @Test("negative mask bits are rejected")
    func maskBitsNegative() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidMaskBits) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.1", maskBits: -1)
        }
    }

    // MARK: Invalid addresses

    @Test("too few octets are rejected")
    func tooFewOctets() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidIPFormat) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1", maskBits: 24)
        }
    }

    @Test("too many octets are rejected")
    func tooManyOctets() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidIPFormat) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.1.1", maskBits: 24)
        }
    }

    @Test("an octet above 255 is rejected")
    func octetOutOfRange() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.256", maskBits: 24)
        }
    }

    @Test("a non-numeric octet is rejected")
    func octetNotNumeric() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.abc", maskBits: 24)
        }
    }

    @Test("an octet with four digits is rejected")
    func octetTooManyDigits() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "1000.1.1.1", maskBits: 24)
        }
    }

    @Test("a four-digit octet with a leading zero is rejected")
    func octetFourDigitsLeadingZero() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "0100.1.1.1", maskBits: 24)
        }
    }

    @Test("a leading zero on an octet is rejected")
    func octetLeadingZero() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.010.1", maskBits: 24)
        }
    }

    @Test("a zero octet written as \"00\" is rejected")
    func octetDoubleZero() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.00.1", maskBits: 24)
        }
    }

    @Test("a plus-signed octet is rejected")
    func octetPlusSign() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.+1.1", maskBits: 24)
        }
    }

    @Test("a minus-signed octet is rejected")
    func octetMinusSign() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.-0.1", maskBits: 24)
        }
    }

    @Test("an empty octet is rejected")
    func octetEmpty() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192..168.1", maskBits: 24)
        }
    }

    @Test("leading whitespace is rejected")
    func leadingWhitespaceRejected() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: " 192.168.1.1", maskBits: 24)
        }
    }

    @Test("trailing whitespace is rejected")
    func trailingWhitespaceRejected() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.1 ", maskBits: 24)
        }
    }

    @Test("a CIDR suffix in the address field is rejected")
    func cidrSuffixRejected() {
        #expect(throws: IPv4Calculator.IPv4Error.invalidOctet) {
            try IPv4Calculator.calculateSubnet(ipAddress: "192.168.1.1/24", maskBits: 24)
        }
    }

    // MARK: Canonical zero octets

    @Test("a bare zero octet still parses")
    func octetBareZero() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "10.0.0.0", maskBits: 24)
        #expect(info.networkAddress == "10.0.0.0")
        #expect(info.broadcastAddress == "10.0.0.255")
        #expect(info.subnetMask == "255.255.255.0")
        #expect(info.numberOfHosts == 254)
    }

    @Test("the maximum octet value still parses")
    func octetMaxValue() throws {
        let info = try IPv4Calculator.calculateSubnet(ipAddress: "255.255.255.255", maskBits: 32)
        #expect(info.networkAddress == "255.255.255.255")
        #expect(info.broadcastAddress == "255.255.255.255")
        #expect(info.subnetMask == "255.255.255.255")
        #expect(info.numberOfHosts == 1)
    }
}

// MARK: - IPv6SubnetCalculator

@Suite("IPv6SubnetCalculator")
struct IPv6SubnetCalculatorTests {

    let calc = IPv6SubnetCalculator()

    // MARK: Expansion

    @Test("expands a :: address to eight zero-padded groups")
    func expandsCompressedAddress() throws {
        let info = try calc.calculateSubnet(address: "2001:db8::", prefixLength: 64)
        #expect(info.expandedAddress == "2001:0db8:0000:0000:0000:0000:0000:0000")
    }

    @Test("expands a fully written address, padding leading zeros")
    func expandsFullAddress() throws {
        let info = try calc.calculateSubnet(address: "2001:db8:85a3:0:0:8a2e:370:7334", prefixLength: 128)
        #expect(info.expandedAddress == "2001:0db8:85a3:0000:0000:8a2e:0370:7334")
    }

    @Test("uppercase input is lowercased per RFC 5952")
    func lowercasesUppercaseInput() throws {
        let info = try calc.calculateSubnet(address: "2001:DB8::1", prefixLength: 128)
        #expect(info.compressedAddress == "2001:db8::1")
        #expect(info.expandedAddress == "2001:0db8:0000:0000:0000:0000:0000:0001")
    }

    @Test("groups with leading zeros in the input parse fine")
    func leadingZeroGroupsParse() throws {
        let info = try calc.calculateSubnet(address: "2001:0db8::1", prefixLength: 128)
        #expect(info.compressedAddress == "2001:db8::1")
        #expect(info.expandedAddress == "2001:0db8:0000:0000:0000:0000:0000:0001")
    }

    // MARK: Zone indices

    @Test("a zone index is stripped before parsing")
    func zoneIndexStripped() throws {
        let info = try calc.calculateSubnet(address: "fe80::1%en0", prefixLength: 64)
        #expect(info.compressedAddress == "fe80::1")
        #expect(info.expandedAddress == "fe80:0000:0000:0000:0000:0000:0000:0001")
        #expect(info.subnetPrefix == "fe80::/64")
        #expect(info.firstAddress == "fe80::")
        #expect(info.lastAddress == "fe80::ffff:ffff:ffff:ffff")
    }

    @Test("a bare percent sign with an empty zone is stripped too")
    func emptyZoneIndexStripped() throws {
        let info = try calc.calculateSubnet(address: "fe80::1%", prefixLength: 64)
        #expect(info.compressedAddress == "fe80::1")
        #expect(info.subnetPrefix == "fe80::/64")
    }

    // MARK: Compression (RFC 5952)

    @Test("compresses a middle run of zeros")
    func compressesMiddleZeroRun() throws {
        let info = try calc.calculateSubnet(address: "2001:db8:85a3:0:0:8a2e:370:7334", prefixLength: 128)
        #expect(info.compressedAddress == "2001:db8:85a3::8a2e:370:7334")
    }

    @Test("compresses a leading run of zeros")
    func compressesLeadingZeroRun() throws {
        let info = try calc.calculateSubnet(address: "::1", prefixLength: 128)
        #expect(info.compressedAddress == "::1")
    }

    @Test("compresses a trailing run of zeros")
    func compressesTrailingZeroRun() throws {
        let info = try calc.calculateSubnet(address: "2001:db8::", prefixLength: 64)
        #expect(info.compressedAddress == "2001:db8::")
    }

    @Test("the all-zeros unspecified address compresses to ::")
    func compressesUnspecifiedAddress() throws {
        let info = try calc.calculateSubnet(address: "::", prefixLength: 0)
        #expect(info.compressedAddress == "::")
        #expect(info.expandedAddress == "0000:0000:0000:0000:0000:0000:0000:0000")
        #expect(info.subnetPrefix == "::/0")
        #expect(info.firstAddress == "::")
        #expect(info.lastAddress == "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")
    }

    @Test("a single zero group is not compressed (RFC 5952 §4.2.2)")
    func singleZeroGroupNotCompressed() throws {
        let info = try calc.calculateSubnet(address: "2001:db8:0:1:1:1:1:1", prefixLength: 128)
        #expect(info.compressedAddress == "2001:db8:0:1:1:1:1:1")
    }

    @Test("when two zero runs tie in length, the first is compressed (RFC 5952 §4.2.3)")
    func tiedZeroRunsCompressFirst() throws {
        let info = try calc.calculateSubnet(address: "1:0:0:2:0:0:3:4", prefixLength: 128)
        #expect(info.compressedAddress == "1::2:0:0:3:4")
    }

    @Test("the longest zero run wins regardless of position")
    func longestZeroRunWins() throws {
        let info = try calc.calculateSubnet(address: "2001:0:0:1:0:0:0:1", prefixLength: 128)
        #expect(info.compressedAddress == "2001:0:0:1::1")
    }

    // MARK: Network / first / last addresses

    @Test("last address fills the host bits with ones")
    func lastAddressOfSlash64() throws {
        let info = try calc.calculateSubnet(address: "2001:db8::", prefixLength: 64)
        #expect(info.lastAddress == "2001:db8::ffff:ffff:ffff:ffff")
    }

    @Test("first address of a /64 is the network address")
    func firstAddressOfSlash64() throws {
        let info = try calc.calculateSubnet(address: "2001:db8::", prefixLength: 64)
        #expect(info.firstAddress == "2001:db8::")
    }

    @Test("first address of a /128 is the address itself")
    func firstAddressOfSlash128() throws {
        let info = try calc.calculateSubnet(address: "2001:db8:85a3:0:0:8a2e:370:7334", prefixLength: 128)
        #expect(info.firstAddress == "2001:db8:85a3::8a2e:370:7334")
    }

    @Test("a /127 covers exactly two addresses")
    func slash127Edges() throws {
        let info = try calc.calculateSubnet(address: "2001:db8::1", prefixLength: 127)
        #expect(info.subnetPrefix == "2001:db8::/127")
        #expect(info.firstAddress == "2001:db8::")
        #expect(info.lastAddress == "2001:db8::1")
        #expect(info.totalHosts == "2.00000e+00")
    }

    @Test("a /1 splits the address space on the top bit")
    func slash1Edges() throws {
        let lower = try calc.calculateSubnet(address: "2001:db8::", prefixLength: 1)
        #expect(lower.subnetPrefix == "::/1")
        #expect(lower.firstAddress == "::")
        #expect(lower.lastAddress == "7fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")

        let upper = try calc.calculateSubnet(address: "a000::", prefixLength: 1)
        #expect(upper.subnetPrefix == "8000::/1")
        #expect(upper.firstAddress == "8000::")
        #expect(upper.lastAddress == "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")
    }

    @Test("subnet prefix of a /128 keeps the full address")
    func subnetPrefixOfSlash128() throws {
        let info = try calc.calculateSubnet(address: "2001:db8:85a3:0:0:8a2e:370:7334", prefixLength: 128)
        #expect(info.subnetPrefix == "2001:db8:85a3::8a2e:370:7334/128")
    }

    @Test("subnet prefix of a /48 compresses correctly")
    func subnetPrefixOfSlash48() throws {
        let info = try calc.calculateSubnet(address: "2001:db8:85a3::8a2e:370:7334", prefixLength: 48)
        #expect(info.subnetPrefix == "2001:db8:85a3::/48")
    }

    @Test("a /61 truncates the network mid-group")
    func subnetPrefixOfSlash61() throws {
        let info = try calc.calculateSubnet(address: "2001:db8:0:f::", prefixLength: 61)
        #expect(info.subnetPrefix == "2001:db8:0:8::/61")
        #expect(info.firstAddress == "2001:db8:0:8::")
        #expect(info.lastAddress == "2001:db8:0:f:ffff:ffff:ffff:ffff")
        #expect(info.numberOfSlash64Networks == "8")
    }

    // MARK: /64-network counts

    @Test("a /64 or smaller contains exactly one /64")
    func slash64NetworkCountAtBoundary() throws {
        #expect(try calc.calculateSubnet(address: "2001:db8::", prefixLength: 64).numberOfSlash64Networks == "1")
        #expect(try calc.calculateSubnet(address: "2001:db8::", prefixLength: 96).numberOfSlash64Networks == "1")
        #expect(try calc.calculateSubnet(address: "2001:db8::", prefixLength: 128).numberOfSlash64Networks == "1")
    }

    @Test("a /48 contains 65536 /64 networks (plain integer formatting)")
    func slash64NetworkCountSmall() throws {
        let info = try calc.calculateSubnet(address: "2001:db8::", prefixLength: 48)
        #expect(info.numberOfSlash64Networks == "65536")
    }

    // NOTE: The scientific-notation expectations below come from
    // `String(format:)` with power-of-two inputs, so they are deterministic;
    // the exact strings are pinned by these tests on both Darwin and Linux.

    @Test("a /32 reports its /64 count in scientific notation")
    func slash64NetworkCountLarge() throws {
        let info = try calc.calculateSubnet(address: "2001:db8::", prefixLength: 32)
        #expect(info.numberOfSlash64Networks == "4.29497e+09")
    }

    @Test("a /0 reports its /64 count in scientific notation")
    func slash64NetworkCountSlash0() throws {
        let info = try calc.calculateSubnet(address: "::", prefixLength: 0)
        #expect(info.numberOfSlash64Networks == "1.84467e+19")
    }

    // MARK: Total host counts (always scientific notation)

    @Test("total hosts for a /64")
    func totalHostsSlash64() throws {
        let info = try calc.calculateSubnet(address: "2001:db8::", prefixLength: 64)
        #expect(info.totalHosts == "1.84467e+19")
    }

    @Test("total hosts for a /128 is one address")
    func totalHostsSlash128() throws {
        let info = try calc.calculateSubnet(address: "2001:db8::", prefixLength: 128)
        #expect(info.totalHosts == "1.00000e+00")
    }

    @Test("total hosts for a /0 is the whole address space")
    func totalHostsSlash0() throws {
        let info = try calc.calculateSubnet(address: "2001:db8::", prefixLength: 0)
        #expect(info.totalHosts == "3.40282e+38")
    }

    // MARK: Invalid input

    @Test("prefix length above 128 is rejected")
    func prefixTooHigh() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidPrefixLength) {
            try calc.calculateSubnet(address: "2001:db8::", prefixLength: 129)
        }
    }

    @Test("negative prefix length is rejected")
    func prefixNegative() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidPrefixLength) {
            try calc.calculateSubnet(address: "2001:db8::", prefixLength: -1)
        }
    }

    @Test("IPv4-mapped addresses are explicitly unsupported")
    func ipv4MappedRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.ipv4MappedAddressesNotSupported) {
            try calc.calculateSubnet(address: "2001:db8::1.2.3.4", prefixLength: 64)
        }
    }

    @Test("more than one :: is rejected")
    func doubleColonTwiceRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "2001::db8::1", prefixLength: 64)
        }
    }

    @Test("too few groups without :: is rejected")
    func tooFewGroupsRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "2001:db8:1:2:3", prefixLength: 64)
        }
    }

    @Test("a non-hexadecimal group is rejected")
    func nonHexGroupRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "2001:db8:zzzz::", prefixLength: 64)
        }
    }

    @Test("a group wider than 16 bits is rejected")
    func oversizedGroupRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "12345::", prefixLength: 64)
        }
    }
}

// MARK: - IPv6SubnetCalculator parser strictness

@Suite("IPv6SubnetCalculator (parser strictness)")
struct IPv6ParserStrictnessTests {

    let calc = IPv6SubnetCalculator()

    @Test("three consecutive colons before a group is rejected")
    func tripleColonLeadingRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: ":::1", prefixLength: 64)
        }
    }

    @Test("three consecutive colons after a group is rejected")
    func tripleColonTrailingRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "1:::", prefixLength: 64)
        }
    }

    @Test("three consecutive colons between groups is rejected")
    func tripleColonMiddleRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "1:::2", prefixLength: 64)
        }
    }

    @Test("a trailing single colon without :: is rejected")
    func trailingSingleColonRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "1:2:3:4:5:6:7:", prefixLength: 64)
        }
    }

    @Test("a leading single colon without :: is rejected")
    func leadingSingleColonRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: ":1:2:3:4:5:6:7", prefixLength: 64)
        }
    }

    @Test("a dangling single colon after a :: form is rejected")
    func danglingColonAfterDoubleColonRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "1::2:", prefixLength: 64)
        }
    }

    @Test(":: replacing zero groups after eight groups is rejected")
    func noOpDoubleColonTrailingRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "1:2:3:4:5:6:7:8::", prefixLength: 64)
        }
    }

    @Test(":: replacing zero groups before eight groups is rejected")
    func noOpDoubleColonLeadingRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "::1:2:3:4:5:6:7:8", prefixLength: 64)
        }
    }

    @Test(":: replacing zero groups between eight groups is rejected")
    func noOpDoubleColonMiddleRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "1:2:3:4:5:6:7::8", prefixLength: 64)
        }
    }

    @Test("a group wider than 16 bits inside a :: address is rejected")
    func oversizedGroupInDoubleColonRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "1:2:3:00000::", prefixLength: 64)
        }
    }

    @Test("a CIDR suffix in the address field is rejected")
    func cidrSuffixRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "2001:db8::/64", prefixLength: 64)
        }
    }

    @Test("whitespace around the address is rejected")
    func whitespaceRejected() {
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: " 2001:db8::", prefixLength: 64)
        }
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "2001:db8:: ", prefixLength: 64)
        }
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: "2001:db8::1 ", prefixLength: 64)
        }
        #expect(throws: IPv6SubnetCalculator.SubnetError.invalidAddress) {
            try calc.calculateSubnet(address: " ::1", prefixLength: 64)
        }
    }
}
