//
//  SubnetV6CalculatorView.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/16/25.
//

import SwiftUI


enum IPv6Field: Hashable {
    case ip6String
}

struct SubnetV6CalculatorView: View {
    @EnvironmentObject private var appState: AppState
    
    // Subnet calculation results
    @State private var compressedAddress: String = ""
    @State private var expandedAddress: String = ""
    @State private var subnetPrefix: String = ""
    @State private var numberOfSlash64Networks: String = ""
    @State private var totalHosts: String = ""
    @State private var firstAddress: String = ""
    @State private var lastAddress: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
            // Title
            Text("Simple Subnet Calc")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top)

            // IP Address input card
            VStack(spacing: 12) {
                // IPv6 Address input field
                IPv6TextField(
                    text: $appState.ipv6Address,
                    field: .ip6String
                )
                .padding(.horizontal)
                .onChange(of: appState.ipv6Address) {
                    calculateSubnet()
                }

            }
            .cardStyle()
            .cornerRadius(10)

            // Results
            VStack(spacing: 0) {
                ResultRow(label: "Subnet Prefix", value: subnetPrefix)
                Divider()
                ResultRow(label: "First Address", value: firstAddress)
                Divider()
                ResultRow(label: "Last Address", value: lastAddress)
                Divider()
                DoubleResultRow(
                    leftLabel: "/64 Networks", 
                    leftValue: numberOfSlash64Networks, 
                    rightLabel: "Total Hosts", 
                    rightValue: totalHosts
                )
            }
            .cardStyle()
            
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    // Slider control with label that follows
                    VStack(spacing: 10) {
                        // This is a blank space to make room for the floating label
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 40)
                        
                        // Slider control
                        Slider(value: $appState.ipv6CidrPrefix, in: 1...128, step: 1)
                            .accentColor(.accentColor)
                            .onChange(of: appState.ipv6CidrPrefix) {
                                calculateSubnet()
                            }
                        
                        // Min/Max labels
                        HStack {
                            Text("1")
                            Spacer()
                            Text("128")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // CIDR prefix display that follows the slider
                    ZStack {
                        CIDRBubbleShape()
                            .fill(Color.blue)
                            .frame(width: 60, height: 45)  // Slightly taller to accommodate arrow
                        
                        Text("\(Int(appState.ipv6CidrPrefix))")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .offset(y: -4)  // Move text up slightly to account for arrow space
                    }
                    .offset(x: getCIDRLabelPosition(), y: 0)
                }
            }.cardStyle()
            
            Spacer()
            }
            .background(Color.appBackground)
        }
        .onAppear {
            calculateSubnet()
        }
        .refreshable {
            // Reset IPv6 fields when refreshed
            appState.resetIPv6Fields()
            
            // Reset calculation results
            compressedAddress = ""
            expandedAddress = ""
            subnetPrefix = ""
            numberOfSlash64Networks = ""
            totalHosts = ""
            firstAddress = ""
            lastAddress = ""
            
            calculateSubnet()
        }
    }
    
    // Calculate subnet when IP or prefix changes
    private func calculateSubnet() {
        let calculator = IPv6SubnetCalculator()
        
        do {
            let result = try calculator.calculateSubnet(
                address: appState.ipv6Address,
                prefixLength: Int(appState.ipv6CidrPrefix)
            )
            
            compressedAddress = result.compressedAddress
            expandedAddress = result.expandedAddress
            subnetPrefix = result.subnetPrefix
            numberOfSlash64Networks = result.numberOfSlash64Networks
            totalHosts = result.totalHosts
            firstAddress = result.firstAddress
            lastAddress = result.lastAddress
        } catch {
            // Handle errors - could show an alert or error message
            compressedAddress = ""
            expandedAddress = ""
            subnetPrefix = ""
            numberOfSlash64Networks = ""
            totalHosts = ""
            firstAddress = ""
            lastAddress = ""
        }
    }
    
    // Calculate position for the CIDR label based on slider value
    private func getCIDRLabelPosition() -> CGFloat {
        // Calculate position within available width (assuming a standard padding)
        // Maps the CIDR value (1...128) to a position across the width of the slider
        let totalRange: CGFloat = 127
        let normalizedValue = (appState.ipv6CidrPrefix - 1) / totalRange // 0.0 to 1.0
        
        // The available width minus the width of the label
        let availableWidth = UIScreen.main.bounds.width - 100 // Adjust for padding and margins
        
        // Calculate position from left edge
        var basePosition = (normalizedValue * availableWidth) - (availableWidth / 2)
        
        // Apply adjustments for extreme values
        if appState.ipv6CidrPrefix < 20 {
            basePosition += 20
        } else if appState.ipv6CidrPrefix > 100 {
            basePosition -= 20
        }
        
        return basePosition
    }
}

#Preview {
    SubnetV6CalculatorView()
        .environmentObject(AppState())
}
