//
//  AboutView.swift
//  Spool Programmer
//
//  About/Help screen with app information and resources
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon and Name
                    VStack(spacing: 12) {
                        Image(systemName: "wave.3.right.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Spool Programmer")
                            .font(.title.bold())
                        
                        Text("Version \(appVersion)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Quick Start Guide
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Quick Start", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InstructionRow(
                                number: "1",
                                title: "Select Filament",
                                description: "Choose your filament profile from the list"
                            )
                            
                            InstructionRow(
                                number: "2",
                                title: "Choose Color & Size",
                                description: "Pick a color and select spool weight"
                            )
                            
                            InstructionRow(
                                number: "3",
                                title: "Write to Tag",
                                description: "Tap 'Write Tag' and hold your phone near the NTAG213/215/216 tag"
                            )
                            
                            InstructionRow(
                                number: "4",
                                title: "Verify",
                                description: "Automatic verification ensures data was written correctly"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Supported Tags
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Supported Tags", systemImage: "checkmark.seal.fill")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("• NTAG213 (144 bytes user memory)")
                        Text("• NTAG215 (504 bytes user memory)")
                        Text("• NTAG216 (888 bytes user memory)")
                        Text("• All types compatible - uses 144 bytes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("• Must be blank or unlocked")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Links Section
                    VStack(spacing: 12) {
                        LinkButton(
                            title: "GitHub Repository",
                            systemImage: "chevron.left.forwardslash.chevron.right",
                            url: "https://github.com/martinbogo/rfidspoolprogrammer"
                        )
                        
                        LinkButton(
                            title: "ACE-RFID Project",
                            systemImage: "antenna.radiowaves.left.and.right",
                            url: "https://github.com/AceCentre/ACE-RFID"
                        )
                        
                        LinkButton(
                            title: "Privacy Policy",
                            systemImage: "hand.raised.fill",
                            url: "https://github.com/martinbogo/rfidspoolprogrammer/blob/main/PRIVACY_POLICY.md"
                        )
                        
                        LinkButton(
                            title: "Report Issue",
                            systemImage: "exclamationmark.bubble.fill",
                            url: "https://github.com/martinbogo/rfidspoolprogrammer/issues"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Made with ❤️ for the 3D printing community")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("© 2024-2025 Martin Bogo")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct InstructionRow: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct LinkButton: View {
    let title: String
    let systemImage: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Label(title, systemImage: systemImage)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
