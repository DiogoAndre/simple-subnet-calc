//
//  ContentView.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/8/25.
//

import SwiftUI

struct ContentView: View {
    enum CalculatorMode: String, CaseIterable {
        case ipv4 = "IPv4"
        case ipv6 = "IPv6"
    }
    
    @State private var selectedMode: CalculatorMode = .ipv4
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected mode
            Group {
                if selectedMode == .ipv4 {
                    SubnetV4CalculatorView()
                        .transition(.opacity)
                } else {
                    SubnetV6CalculatorView()
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            
            // Floating Tab Bar
            FloatingTabBar(selectedMode: $selectedMode)
                .padding(.horizontal, 35)
                .padding(.bottom, 20)
        }
        .edgesIgnoringSafeArea(.bottom)
        .animation(.easeInOut(duration: 0.3), value: selectedMode)
    }
}

struct FloatingTabBar: View {
    @Binding var selectedMode: ContentView.CalculatorMode
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ContentView.CalculatorMode.allCases, id: \.self) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    VStack(spacing: 4) {
                        Text(mode.rawValue)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedMode == mode ? .accentColor : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 25)
                    .contentShape(Rectangle())
                }
            }
        }
        .background(
            Capsule(style: .continuous)
                .fill(Color(.cardBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
        )
    }

}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
