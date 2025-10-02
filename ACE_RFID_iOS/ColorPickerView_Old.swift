//
//  ColorPickerView.swift
//  ACE RFID iOS
//
//  Enhanced color picker with gradient and presets
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) var dismiss
    
    @State private var hue: Double = 0.0
    @State private var saturation: Double = 1.0
    @State private var brightness: Double = 1.0
    @State private var alpha: Double = 1.0
    @State private var showingRGBSliders = false
    @State private var showingPresets = true
    @State private var showHexInputDialog = false
    @State private var hexInput = ""
    
    let presetColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        .white, .gray, .black,
        Color(red: 1.0, green: 0.0, blue: 1.0),  // Magenta
        Color(red: 0.0, green: 1.0, blue: 1.0),  // Cyan
        Color(red: 0.5, green: 0.0, blue: 0.5),  // Dark purple
        Color(red: 1.0, green: 0.5, blue: 0.0),  // Light orange
        Color(red: 0.5, green: 1.0, blue: 0.0),  // Lime
        Color(red: 0.0, green: 0.5, blue: 1.0),  // Sky blue
        Color(red: 1.0, green: 0.75, blue: 0.8), // Light pink
        Color(red: 0.6, green: 0.4, blue: 0.2),  // Brown
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Color Preview") {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedColor)
                            .frame(width: 100, height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Button(action: {
                            showHexInputDialog = true
                        }) {
                            HStack {
                                Text("Hex: \(hexString)")
                                    .font(.system(.body, design: .monospaced))
                                Spacer()
                                Image(systemName: "pencil")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.primary)
                        
                        Text("RGB: \(rgbString)")
                            .font(.system(.caption, design: .monospaced))
                    }
                }
                
                Section {
                    DisclosureGroup("Gradient Picker", isExpanded: .constant(true)) {
                        VStack(spacing: 15) {
                            // Hue gradient picker
                            ZStack(alignment: .leading) {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .red, .yellow, .green, .cyan, .blue, .purple, .red
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(height: 30)
                                .cornerRadius(15)
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 25, height: 25)
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                    .offset(x: CGFloat(hue) * (UIScreen.main.bounds.width - 80) - 12.5)
                            }
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let width = UIScreen.main.bounds.width - 80
                                        hue = min(max(0, Double(value.location.x) / width), 1.0)
                                        updateColor()
                                    }
                            )
                            
                            // Saturation/Brightness picker
                            GeometryReader { geometry in
                                ZStack {
                                    // Background gradient
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white,
                                                    Color(hue: hue, saturation: 1.0, brightness: 1.0)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .overlay(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .clear,
                                                    .black
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .cornerRadius(10)
                                    
                                    // Selection indicator
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 20, height: 20)
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                        .position(
                                            x: CGFloat(saturation) * geometry.size.width,
                                            y: (1 - CGFloat(brightness)) * geometry.size.height
                                        )
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            saturation = min(max(0, Double(value.location.x / geometry.size.width)), 1.0)
                                            brightness = 1 - min(max(0, Double(value.location.y / geometry.size.height)), 1.0)
                                            updateColor()
                                        }
                                )
                            }
                            .frame(height: 200)
                            
                            // Alpha slider
                            VStack(alignment: .leading) {
                                Text("Opacity: \(Int(alpha * 100))%")
                                    .font(.caption)
                                Slider(value: $alpha, in: 0...1, step: 0.01)
                                    .onChange(of: alpha) { _ in
                                        updateColor()
                                    }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    DisclosureGroup("RGB Sliders", isExpanded: $showingRGBSliders) {
                        let components = colorComponents
                        
                        VStack(spacing: 15) {
                            ColorSliderRow(title: "Red", value: .constant(components.red), color: .red) { newValue in
                                updateFromRGB(red: newValue, green: components.green, blue: components.blue)
                            }
                            ColorSliderRow(title: "Green", value: .constant(components.green), color: .green) { newValue in
                                updateFromRGB(red: components.red, green: newValue, blue: components.blue)
                            }
                            ColorSliderRow(title: "Blue", value: .constant(components.blue), color: .blue) { newValue in
                                updateFromRGB(red: components.red, green: components.green, blue: newValue)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    DisclosureGroup("Preset Colors", isExpanded: $showingPresets) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                            ForEach(0..<presetColors.count, id: \.self) { index in
                                Circle()
                                    .fill(presetColors[index])
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == presetColors[index] ? Color.blue : Color.gray.opacity(0.3), lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedColor = presetColors[index]
                                        updateFromColor()
                                    }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Pick Color")
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
        }
        .onAppear {
            updateFromColor()
        }
        .alert("Enter Hex Color (AARRGGBB)", isPresented: $showHexInputDialog) {
            TextField("AARRGGBB", text: $hexInput)
                .textInputAutocapitalization(.characters)
            Button("Cancel", role: .cancel) {
                hexInput = ""
            }
            Button("OK") {
                if isValidHexCode(hexInput) {
                    applyHexColor(hexInput)
                }
                hexInput = ""
            }
        } message: {
            Text("Enter an 8-character hex code (alpha, red, green, blue)")
        }
    }
    
    private var colorComponents: (red: Double, green: Double, blue: Double) {
        let uiColor = UIColor(selectedColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue))
    }
    
    private var hexString: String {
        let components = colorComponents
        return String(format: "%02X%02X%02X%02X",
                     Int(alpha * 255),
                     Int(components.red * 255),
                     Int(components.green * 255),
                     Int(components.blue * 255))
    }
    
    private var rgbString: String {
        let components = colorComponents
        return String(format: "R:%d G:%d B:%d A:%.0f%%",
                     Int(components.red * 255),
                     Int(components.green * 255),
                     Int(components.blue * 255),
                     alpha * 100)
    }
    
    private func updateColor() {
        selectedColor = Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
    }
    
    private func updateFromColor() {
        let uiColor = UIColor(selectedColor)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        hue = Double(h)
        saturation = Double(s)
        brightness = Double(b)
        alpha = Double(a)
    }
    
    private func updateFromRGB(red: Double, green: Double, blue: Double) {
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: nil)
        hue = Double(h)
        saturation = Double(s)
        brightness = Double(b)
        selectedColor = Color(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    private func isValidHexCode(_ hex: String) -> Bool {
        let pattern = "^[0-9A-Fa-f]{8}$"
        return hex.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func applyHexColor(_ hex: String) {
        guard hex.count == 8 else { return }
        
        let alphaHex = String(hex.prefix(2))
        let redHex = String(hex.dropFirst(2).prefix(2))
        let greenHex = String(hex.dropFirst(4).prefix(2))
        let blueHex = String(hex.dropFirst(6).prefix(2))
        
        guard let a = Int(alphaHex, radix: 16),
              let r = Int(redHex, radix: 16),
              let g = Int(greenHex, radix: 16),
              let b = Int(blueHex, radix: 16) else { return }
        
        alpha = Double(a) / 255.0
        updateFromRGB(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0)
    }
}

struct ColorSliderRow: View {
    let title: String
    @Binding var value: Double
    let color: Color
    let onChange: (Double) -> Void
    
    @State private var localValue: Double
    
    init(title: String, value: Binding<Double>, color: Color, onChange: @escaping (Double) -> Void) {
        self.title = title
        self._value = value
        self.color = color
        self.onChange = onChange
        self._localValue = State(initialValue: value.wrappedValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(title): \(Int(localValue * 255))")
                .font(.caption)
            Slider(value: $localValue, in: 0...1, step: 0.01)
                .accentColor(color)
                .onChange(of: localValue) { newValue in
                    onChange(newValue)
                }
        }
    }
}

#Preview {
    ColorPickerView(selectedColor: .constant(.red))
}
