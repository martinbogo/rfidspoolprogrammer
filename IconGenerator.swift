//
//  IconGenerator.swift
//  Temporary icon generator using SwiftUI
//
//  Use this to generate a placeholder icon until you get a professional design
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.8),
                    Color(red: 0.1, green: 0.2, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Spool shape
            ZStack {
                // Outer rim
                Circle()
                    .stroke(Color.white.opacity(0.9), lineWidth: 15)
                    .frame(width: 160, height: 160)
                
                // Inner rim
                Circle()
                    .stroke(Color.white.opacity(0.7), lineWidth: 10)
                    .frame(width: 100, height: 100)
                
                // Center hub
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 50, height: 50)
                
                // Filament lines
                ForEach(0..<8) { i in
                    Rectangle()
                        .fill(Color.orange.opacity(0.8))
                        .frame(width: 3, height: 55)
                        .offset(y: -52.5)
                        .rotationEffect(.degrees(Double(i) * 45))
                }
            }
            .offset(y: 20)
            
            // NFC symbol (waves)
            VStack(spacing: 3) {
                ForEach(0..<3) { i in
                    Capsule()
                        .fill(
                            Color.orange
                                .opacity(1.0 - Double(i) * 0.25)
                        )
                        .frame(
                            width: 80 + CGFloat(i) * 30,
                            height: 6 - CGFloat(i) * 1
                        )
                }
            }
            .offset(y: -70)
            .rotationEffect(.degrees(-15))
        }
        .frame(width: 1024, height: 1024)
    }
}

// MARK: - Usage Instructions
/*
 To generate the icon:
 
 1. Add this file to your Xcode project (temporarily)
 2. Create a new SwiftUI Preview in Xcode
 3. Add this code:
 
 struct IconGenerator_Previews: PreviewProvider {
     static var previews: some View {
         AppIconView()
             .previewLayout(.fixed(width: 1024, height: 1024))
     }
 }
 
 4. Run preview and take a screenshot
 5. Or use the export function below
 6. Use online tool to generate all icon sizes:
    - https://www.appicon.co/
    - https://makeappicon.com/
 
 This generates a 1024x1024 base icon.
 */

// MARK: - Better Option: Use AI Generation
/*
 Recommended prompt for DALL-E/Midjourney:
 
 "iOS app icon, minimalist flat design, 3D printer filament spool in blue 
  gradient with NFC wireless waves in orange, modern tech aesthetic, 
  1024x1024px, professional, clean"
 
 Try these free AI tools:
 - Bing Image Creator (DALL-E 3): https://www.bing.com/create
 - Leonardo.ai: https://leonardo.ai
 - Ideogram.ai: https://ideogram.ai
 */
