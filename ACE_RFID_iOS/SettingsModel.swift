//
//  SettingsModel.swift
//  Spool Programmer
//
//  User preferences and app settings
//

import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    // Settings keys
    private enum Keys {
        static let defaultSpoolSize = "defaultSpoolSize"
        static let autoVerify = "autoVerify"
        static let hapticFeedback = "hapticFeedback"
        static let temperatureUnit = "temperatureUnit"
        static let showDebugInfo = "showDebugInfo"
    }
    
    @Published var defaultSpoolSize: SpoolSize {
        didSet {
            UserDefaults.standard.set(defaultSpoolSize.rawValue, forKey: Keys.defaultSpoolSize)
        }
    }
    
    @Published var autoVerifyEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoVerifyEnabled, forKey: Keys.autoVerify)
        }
    }
    
    @Published var hapticFeedbackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedbackEnabled, forKey: Keys.hapticFeedback)
        }
    }
    
    @Published var temperatureUnit: TemperatureUnit {
        didSet {
            UserDefaults.standard.set(temperatureUnit.rawValue, forKey: Keys.temperatureUnit)
        }
    }
    
    @Published var showDebugInfo: Bool {
        didSet {
            UserDefaults.standard.set(showDebugInfo, forKey: Keys.showDebugInfo)
        }
    }
    
    init() {
        // Load saved settings or use defaults
        if let savedSize = UserDefaults.standard.string(forKey: Keys.defaultSpoolSize),
           let size = SpoolSize(rawValue: savedSize) {
            self.defaultSpoolSize = size
        } else {
            self.defaultSpoolSize = .kg1
        }
        
        self.autoVerifyEnabled = UserDefaults.standard.object(forKey: Keys.autoVerify) as? Bool ?? true
        self.hapticFeedbackEnabled = UserDefaults.standard.object(forKey: Keys.hapticFeedback) as? Bool ?? true
        
        if let savedUnit = UserDefaults.standard.string(forKey: Keys.temperatureUnit),
           let unit = TemperatureUnit(rawValue: savedUnit) {
            self.temperatureUnit = unit
        } else {
            self.temperatureUnit = .celsius
        }
        
        self.showDebugInfo = UserDefaults.standard.bool(forKey: Keys.showDebugInfo)
    }
    
    func resetToDefaults() {
        defaultSpoolSize = .kg1
        autoVerifyEnabled = true
        hapticFeedbackEnabled = true
        temperatureUnit = .celsius
        showDebugInfo = false
    }
}

enum TemperatureUnit: String, CaseIterable {
    case celsius = "Celsius"
    case fahrenheit = "Fahrenheit"
    
    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
    
    func convert(_ celsius: Int) -> Int {
        switch self {
        case .celsius:
            return celsius
        case .fahrenheit:
            return Int(Double(celsius) * 9.0 / 5.0 + 32.0)
        }
    }
    
    func formatTemp(_ celsius: Int) -> String {
        "\(convert(celsius))\(symbol)"
    }
}
