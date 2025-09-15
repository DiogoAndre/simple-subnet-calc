//
//  CIDRBubbleShape.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/10/25.
//
import SwiftUI

// Custom shape for CIDR prefix bubble with downward pointing arrow
struct CIDRBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cornerRadius: CGFloat = 14
        let arrowWidth: CGFloat = 14
        let arrowHeight: CGFloat = 8
        
        var path = Path()
        
        // Start from the bottom left corner
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - arrowHeight))
        
        // Draw the left side up to the top rounded corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - arrowHeight - cornerRadius))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        // Draw the top left rounded corner
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        // Draw the top edge
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        // Draw the top right rounded corner
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        // Draw the right side down to the bottom rounded corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - arrowHeight - cornerRadius))
        
        // Draw the bottom right rounded corner
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - arrowHeight - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        
        // Draw the bottom edge to the start of the arrow
        path.addLine(to: CGPoint(x: rect.midX + arrowWidth/2, y: rect.maxY - arrowHeight))
        
        // Draw the arrow
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - arrowWidth/2, y: rect.maxY - arrowHeight))
        
        // Draw the bottom edge from the arrow to the left rounded corner
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - arrowHeight))
        
        // Draw the bottom left rounded corner
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - arrowHeight - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        
        path.closeSubpath()
        
        return path
    }
}
