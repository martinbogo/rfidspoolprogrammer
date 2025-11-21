//
//  ColorPickerView.swift
//  Spool Programmer
//
//  Simplified color picker with presets and gradient
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) var dismiss
    
    @State private var red: Double = 0.0
    @State private var green: Double = 0.0
    @State private var blue: Double = 1.0
    @State private var hexInput = ""
    @State private var showHexAlert = false
    
    let presetColors: [(name: String, color: Color)] = [
        ("Clear", Color(red: 0.95, green: 0.95, blue: 0.98, opacity: 0.95)), // Translucent/Natural filament
        ("Black", .black),
        ("White", .white),
        ("Gray", .gray),
        ("Red", .red),
        ("Orange", .orange),
        ("Yellow", .yellow),
        ("Green", .green),
        ("Cyan", Color(red: 0.0, green: 1.0, blue: 1.0)),
        ("Blue", .blue),
        ("Purple", .purple),
        ("Magenta", Color(red: 1.0, green: 0.0, blue: 1.0)),
        ("Pink", .pink),
        ("Brown", Color(red: 0.6, green: 0.4, blue: 0.2)),
        ("Lime", Color(red: 0.5, green: 1.0, blue: 0.0)),
        ("Navy", Color(red: 0.0, green: 0.0, blue: 0.5)),
        ("Teal", Color(red: 0.0, green: 0.5, blue: 0.5)),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Color Preview & Hex Input
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(selectedColor)
                            .frame(height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(color: selectedColor.opacity(0.4), radius: 10, y: 5)
                        
                        // Hex Input
                        Button(action: {
                            hexInput = hexString
                            showHexAlert = true
                        }) {
                            HStack {
                                Image(systemName: "number")
                                    .foregroundColor(.secondary)
                                Text("Hex: \(hexString)")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                        }
                        
                        Text("RGB: \(rgbString)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Divider()
                    
                    // Preset Colors
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "square.grid.3x3.fill")
                                .foregroundColor(.secondary)
                            Text("Preset Colors")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(presetColors, id: \.name) { preset in
                                PresetColorButton(
                                    name: preset.name,
                                    color: preset.color,
                                    isSelected: colorsMatch(preset.color, selectedColor),
                                    action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedColor = preset.color
                                            updateFromColor()
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                    
                    // Gradient Picker
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "paintpalette.fill")
                                .foregroundColor(.secondary)
                            Text("Custom Color")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 20) {
                            // Red Slider
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Red")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(red * 100))%")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Pure black to pure red gradient
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0, green: 0, blue: 0),
                                                Color(red: 1, green: 0, blue: 0),
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .frame(height: 40)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        
                                        // Thumb
                                        Circle()
                                            .fill(Color(red: red, green: 0, blue: 0))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: 3)
                                                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                                            )
                                            .offset(x: CGFloat(red) * (geometry.size.width - 32))
                                    }
                                    .frame(height: 40)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let width = geometry.size.width - 32
                                                red = min(max(0, Double(value.location.x - 16) / width), 1.0)
                                                updateColor()
                                            }
                                    )
                                }
                                .frame(height: 40)
                            }
                            
                            // Green Slider
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Green")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(green * 100))%")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Pure black to pure green gradient
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0, green: 0, blue: 0),
                                                Color(red: 0, green: 1, blue: 0),
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .frame(height: 40)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        
                                        // Thumb
                                        Circle()
                                            .fill(Color(red: 0, green: green, blue: 0))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: 3)
                                                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                                            )
                                            .offset(x: CGFloat(green) * (geometry.size.width - 32))
                                    }
                                    .frame(height: 40)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let width = geometry.size.width - 32
                                                green = min(max(0, Double(value.location.x - 16) / width), 1.0)
                                                updateColor()
                                            }
                                    )
                                }
                                .frame(height: 40)
                            }
                            
                            // Blue Slider
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Blue")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(blue * 100))%")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Pure black to pure blue gradient
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0, green: 0, blue: 0),
                                                Color(red: 0, green: 0, blue: 1),
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .frame(height: 40)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        
                                        // Thumb
                                        Circle()
                                            .fill(Color(red: 0, green: 0, blue: blue))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: 3)
                                                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                                            )
                                            .offset(x: CGFloat(blue) * (geometry.size.width - 32))
                                    }
                                    .frame(height: 40)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let width = geometry.size.width - 32
                                                blue = min(max(0, Double(value.location.x - 16) / width), 1.0)
                                                updateColor()
                                            }
                                    )
                                }
                                .frame(height: 40)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
            .alert("Enter Hex Color", isPresented: $showHexAlert) {
                TextField("#RRGGBB", text: $hexInput)
                    .autocapitalization(.allCharacters)
                Button("Cancel", role: .cancel) { }
                Button("Apply") {
                    if let color = colorFromHex(hexInput) {
                        selectedColor = color
                        updateFromColor()
                    }
                }
            } message: {
                Text("Enter hex color (e.g., #FF5733)")
            }
            .onAppear {
                updateFromColor()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func updateColor() {
        selectedColor = Color(red: red, green: green, blue: blue)
    }
    
    private func updateFromColor() {
        let uiColor = UIColor(selectedColor)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        red = Double(r)
        green = Double(g)
        blue = Double(b)
    }
    
    private func colorsMatch(_ color1: Color, _ color2: Color) -> Bool {
        let ui1 = UIColor(color1)
        let ui2 = UIColor(color2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        ui1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        ui2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let tolerance: CGFloat = 0.01
        return abs(r1 - r2) < tolerance && abs(g1 - g2) < tolerance && abs(b1 - b2) < tolerance
    }
    
    private var hexString: String {
        let uiColor = UIColor(selectedColor)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "#%02X%02X%02X",
                     Int(r * 255),
                     Int(g * 255),
                     Int(b * 255))
    }
    
    private var rgbString: String {
        let uiColor = UIColor(selectedColor)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "R:%d G:%d B:%d",
                     Int(r * 255),
                     Int(g * 255),
                     Int(b * 255))
    }
    
    private func colorFromHex(_ hex: String) -> Color? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - Preset Color Button

struct PresetColorButton: View {
    let name: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(Color.blue, lineWidth: isSelected ? 3 : 0)
                    )
                    .shadow(color: color.opacity(0.3), radius: 4, y: 2)
                
                Text(name)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ColorPickerView(selectedColor: .constant(.blue))
}
