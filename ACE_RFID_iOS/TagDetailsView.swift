//
//  TagDetailsView.swift
//  Spool Programmer
//
//  Detailed tag information display
//

import SwiftUI

struct TagDetailsView: View {
    let details: TagDetails
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Tag Icon
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 20)
                    
                    // Tag Type
                    Text(details.tagType)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // UID
                    VStack(spacing: 8) {
                        Text("Tag UID")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(details.uid)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Memory Usage Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Memory Usage", systemImage: "internaldrive")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.0f%%", details.memoryUsagePercent))
                                .font(.headline)
                                .foregroundColor(memoryUsageColor)
                        }
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(.tertiarySystemBackground))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(LinearGradient(
                                        colors: [.blue, memoryUsageColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(width: geometry.size.width * CGFloat(details.memoryUsagePercent / 100.0), height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                        
                        Text(details.memoryUsageText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Data Info Card
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Tag Contents", systemImage: "doc.text")
                            .font(.headline)
                        
                        if details.hasData, let dataType = details.dataType {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Contains \(dataType) data")
                                    .font(.subheadline)
                            }
                        } else {
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                Text("No filament data detected")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("Read \(details.formattedReadDate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tag Details")
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
    
    private var memoryUsageColor: Color {
        let percent = details.memoryUsagePercent
        if percent > 90 {
            return .red
        } else if percent > 70 {
            return .orange
        } else {
            return .green
        }
    }
}

#Preview {
    TagDetailsView(details: TagDetails(
        uid: "04:A1:B2:C3:D4:E5:F6",
        tagType: "NTAG215",
        memoryUsed: 144,
        memoryTotal: 504,
        readDate: Date(),
        hasData: true,
        dataType: "PLA Filament"
    ))
}
