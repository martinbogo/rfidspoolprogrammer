//
//  NFCManager.swift
//  ACE RFID iOS
//
//  NFC Tag Reading and Writing Manager
//

import Foundation
@preconcurrency import CoreNFC
import Combine
import UIKit

// MARK: - Debug Helper
private func debugLog(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}

class NFCManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var tagUID: String = ""
    @Published var tagType: String = ""
    @Published var statusMessage: String = ""
    @Published var lastReadData: RFIDTagData?
    @Published var lastReadBytes: [UInt8]?
    @Published var tagLockStatus: String = ""
    
    // Store data for verification after write
    private var dataToVerify: [UInt8]?
    
    private var nfcSession: NFCTagReaderSession?
    private var currentOperation: NFCOperation = .none
    private var writeData: RFIDTagData?
    
    // Haptic feedback generators
    private let successFeedback = UINotificationFeedbackGenerator()
    private let errorFeedback = UINotificationFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    enum NFCOperation {
        case none
        case read
        case write(RFIDTagData)
        case format
        case checkLock
        case verifyWrite
    }
    
    // MARK: - Haptic Feedback
    
    private func playSuccessHaptic() {
        DispatchQueue.main.async {
            self.successFeedback.notificationOccurred(.success)
        }
    }
    
    private func playErrorHaptic() {
        DispatchQueue.main.async {
            self.errorFeedback.notificationOccurred(.error)
        }
    }
    
    private func playDetectionHaptic() {
        DispatchQueue.main.async {
            self.impactFeedback.impactOccurred()
        }
    }
    
    // MARK: - Public Methods
    
    func startReadSession() {
        guard NFCTagReaderSession.readingAvailable else {
            statusMessage = "NFC is not available on this device"
            return
        }
        
        currentOperation = .read
        startSession(with: "Hold your iPhone near the RFID tag to read")
    }
    
    func startWriteSession(data: RFIDTagData) {
        guard NFCTagReaderSession.readingAvailable else {
            statusMessage = "NFC is not available on this device"
            return
        }
        
        currentOperation = .write(data)
        writeData = data
        
        // Important: Set polling option and alert message
        nfcSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: nil)
        nfcSession?.alertMessage = "Hold iPhone near RFID tag to write.\n⚠️ Keep steady - do not move!"
        nfcSession?.begin()
        isScanning = true
    }
    
    func startFormatSession() {
        guard NFCTagReaderSession.readingAvailable else {
            statusMessage = "NFC is not available on this device"
            return
        }
        
        currentOperation = .format
        startSession(with: "Hold your iPhone near the RFID tag to format")
    }
    
    func checkTagLockStatus() {
        guard NFCTagReaderSession.readingAvailable else {
            statusMessage = "NFC is not available on this device"
            return
        }
        
        currentOperation = .checkLock
        startSession(with: "Hold your iPhone near the RFID tag to check lock status and configuration")
    }
    
    private func startSession(with message: String) {
        nfcSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        nfcSession?.alertMessage = message
        nfcSession?.begin()
        isScanning = true
    }
    
    func stopSession() {
        nfcSession?.invalidate()
        isScanning = false
    }
    
    // MARK: - Helper Methods
    
    private func readPassword(tag: NFCMiFareTag, completion: @escaping (String) -> Void) {
        // Try to read configuration pages (43-44) to get password and PACK
        debugLog("🔍 Attempting to read password from tag...")
        
        // Read page 43 (contains PWD - password)
        let readCmd43 = Data([0x30, 43]) // READ command for page 43
        tag.sendMiFareCommand(commandPacket: readCmd43) { response43, error43 in
            if let error43 = error43 {
                completion("❌ Cannot read password page: \(error43.localizedDescription)")
                return
            }
            guard response43.count >= 4 else {
                completion("❌ Invalid response from password page")
                return
            }
            
            // Page 43 contains PWD (password) - 4 bytes
            let pwd = Array(response43.prefix(4))
            let pwdString = pwd.map { String(format: "%02X", $0) }.joined(separator: " ")
            
            // Read page 44 (contains PACK - password acknowledge)
            let readCmd44 = Data([0x30, 44])
            tag.sendMiFareCommand(commandPacket: readCmd44) { response44, error44 in
                if let error44 = error44 {
                    completion("🔐 Password: \(pwdString)\n❌ Cannot read PACK: \(error44.localizedDescription)")
                    return
                }
                guard response44.count >= 2 else {
                    completion("🔐 Password: \(pwdString)\n❌ Invalid PACK response")
                    return
                }
                
                // Page 44 byte 0-1 contain PACK (password acknowledge)
                let pack = Array(response44.prefix(2))
                let packString = pack.map { String(format: "%02X", $0) }.joined(separator: " ")
                
                let result = "🔐 Password Configuration:\n" +
                            "   PWD (Password): \(pwdString)\n" +
                            "   PACK (Acknowledge): \(packString)\n" +
                            "\n   💡 Use this password in the write function!\n"
                
                debugLog(result)
                completion(result)
            }
        }
    }
    
    private func checkLockBytes(tag: NFCMiFareTag, completion: @escaping (String) -> Void) {
        // Read page 2 for static lock bytes
        let readCmd2 = Data([0x30, 0x02]) // READ command for page 2
        tag.sendMiFareCommand(commandPacket: readCmd2) { response2, error2 in
            if let error2 = error2 {
                completion("❌ Failed to read lock bytes: \(error2.localizedDescription)")
                return
            }
            guard response2.count >= 16 else {
                completion("❌ Invalid lock bytes response")
                return
            }
            
            let lockByte2 = response2[2]
            let lockByte3 = response2[3]
            
            debugLog("🔒 Lock bytes - Byte 2: \(String(format: "%02X", lockByte2)), Byte 3: \(String(format: "%02X", lockByte3))")
            
            var lockInfo = "Lock Status:\n"            // Check if pages 3-15 are locked (bit 3 of byte 2)
            if lockByte2 & 0x08 != 0 {
                lockInfo += "⚠️ Pages 3-15: LOCKED\n"
            } else {
                lockInfo += "✅ Pages 3-15: Unlocked\n"
            }
            
            // Check if lock bits themselves are locked
            if lockByte2 & 0x01 != 0 {
                lockInfo += "🔒 Lock bits: PERMANENTLY LOCKED (cannot be changed!)\n"
            } else {
                lockInfo += "✅ Lock bits: Can be modified\n"
            }
            
            // Check OTP (One Time Programmable) area lock
            if lockByte2 & 0x02 != 0 {
                lockInfo += "⚠️ OTP area: LOCKED\n"
            } else {
                lockInfo += "✅ OTP area: Unlocked\n"
            }
            
            // Now check dynamic lock bytes (page 40) for NTAG215/216
            let readDynamicLock = Data([0x30, 0x28]) // Read page 40
            tag.sendMiFareCommand(commandPacket: readDynamicLock) { response2, error2 in
                if let error2 = error2 {
                    lockInfo += "\n⚠️ Could not read dynamic lock bytes: \(error2.localizedDescription)\n"
                    lockInfo += "(Tag might be NTAG213 without dynamic locks)"
                    completion(lockInfo)
                    return
                }
                
                guard response2.count >= 3 else {
                    completion(lockInfo + "\n(No dynamic lock bytes detected)")
                    return
                }
                
                let dynLock0 = response2[0]
                let dynLock1 = response2[1]
                let dynLock2 = response2[2]
                
                debugLog("🔒 Dynamic lock bytes: \(String(format: "%02X %02X %02X", dynLock0, dynLock1, dynLock2))")
                
                lockInfo += "\nDynamic Lock Bytes (NTAG215/216):\n"
                
                // Check if any dynamic lock bits are set
                if dynLock0 != 0 || dynLock1 != 0 || dynLock2 != 0 {
                    lockInfo += "⚠️ DYNAMIC LOCKS DETECTED!\n"
                    lockInfo += String(format: "   Bytes: %02X %02X %02X\n", dynLock0, dynLock1, dynLock2)
                    lockInfo += "   This may block pages 16+\n"
                    
                    // Check if pages around 4-31 are affected
                    if dynLock0 & 0x01 != 0 {
                        lockInfo += "   ⚠️ Pages 16-19 LOCKED\n"
                    }
                } else {
                    lockInfo += "✅ No dynamic locks set\n"
                }
                
                // Now check configuration pages (41-43) for password protection
                let readConfig = Data([0x30, 0x29]) // Read page 41 (AUTH0, ACCESS)
                tag.sendMiFareCommand(commandPacket: readConfig) { response3, error3 in
                    if let error3 = error3 {
                        lockInfo += "\n⚠️ Could not read config: \(error3.localizedDescription)"
                        completion(lockInfo)
                        return
                    }
                    
                    if response3.count >= 8 {
                        // Page 41: byte 3 = AUTH0 (password protection start page)
                        // Page 42: byte 0 = ACCESS (access bits)
                        let auth0 = response3[3]
                        let access = response3[4]
                        
                        lockInfo += "\nPassword Protection:\n"
                        lockInfo += String(format: "   AUTH0: 0x%02X", auth0)
                        
                        if auth0 < 0xFF {
                            lockInfo += " ⚠️ PASSWORD REQUIRED from page \(auth0)!\n"
                            lockInfo += "   ACCESS: \(String(format: "0x%02X", access))\n"
                            lockInfo += "\n   🔐 TAG IS PASSWORD PROTECTED!\n"
                            lockInfo += "   Writes require authentication.\n"
                            lockInfo += "   Use blank NTAG215 tags for custom programming.\n"
                            completion(lockInfo)
                        } else {
                            lockInfo += " (No password protection)\n"
                            lockInfo += "\n   ✅ Tag is writable!\n"
                            completion(lockInfo)
                        }
                    } else {
                        completion(lockInfo)
                    }
                }
            }
        }
    }
    
    private func detectTagType(_ tag: NFCMiFareTag) -> String {
        // Detect NTAG type based on available memory
        // NTAG213: 180 bytes (45 pages)
        // NTAG215: 540 bytes (135 pages)
        // NTAG216: 924 bytes (231 pages)
        
        // We'll try to read a high page number to determine type
        return "NTAG215" // Default assumption
    }
    
    private func formatTag(_ tag: NFCMiFareTag, completion: @escaping (Bool) -> Void) {
        debugLog("🔧 Starting tag format...")
        debugLog("   Step 1: Writing Capability Container to page 3: E1 10 3E 00")
        
        // Write capability container FIRST (before exhausting the session)
        let ccBytes: [UInt8] = [0xE1, 0x10, 0x3E, 0x00]
        writePage(tag: tag, page: 3, data: Data(ccBytes)) { success in
            if !success {
                debugLog("❌ Failed to write capability container to page 3")
                completion(false)
                return
            }
            
            debugLog("   ✓ Page 3 (CC) written")
            debugLog("   Step 2: Clearing page 2 (lock bytes): 00 00 00 00")
            
            // Clear page 2
            self.writePage(tag: tag, page: 2, data: Data([0x00, 0x00, 0x00, 0x00])) { success2 in
                if !success2 {
                    debugLog("❌ Failed to clear page 2")
                    completion(false)
                    return
                }
                
                debugLog("   ✓ Page 2 (lock) cleared")
                debugLog("   Step 3: Clearing all user data (pages 4-31)...")
                
                // Now clear all data pages using the working write function
                let blankData = [UInt8](repeating: 0x00, count: 144)
                self.writeAllPages(tag: tag, data: blankData) { success3 in
                    if success3 {
                        debugLog("   ✓ All user data cleared")
                        debugLog("✅ Format complete!")
                        debugLog("   📖 Do a 'Read Tag' to verify the format")
                    } else {
                        debugLog("❌ Failed to clear user data")
                    }
                    completion(success3)
                }
            }
        }
    }
    
    private func readPages(tag: NFCMiFareTag, startPage: UInt8, count: Int, completion: @escaping ([UInt8]?) -> Void) {
        var allData = [UInt8]()
        var currentPage = startPage
        let pagesPerRead = 4
        
        debugLog("📖 Starting read from page \(startPage), count: \(count)")
        
        func readNextBatch() {
            guard currentPage < startPage + UInt8(count) else {
                debugLog("✅ Read complete: \(allData.count) bytes")
                debugLog("   Raw data (first 32 bytes): \(allData.prefix(32).map { String(format: "%02X", $0) }.joined(separator: " "))")
                completion(allData)
                return
            }
            
            let command = Data([0x30, currentPage]) // READ command
            debugLog("   Reading page \(currentPage)...")
            
            tag.sendMiFareCommand(commandPacket: command) { response, error in
                if let error = error {
                    debugLog("❌ Read error at page \(currentPage): \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                debugLog("   ✓ Page \(currentPage): \(response.prefix(16).map { String(format: "%02X", $0) }.joined(separator: " "))")
                allData.append(contentsOf: response)
                currentPage += UInt8(pagesPerRead)
                readNextBatch()
            }
        }
        
        readNextBatch()
    }
    
    private func writePage(tag: NFCMiFareTag, page: UInt8, data: Data, completion: @escaping (Bool) -> Void) {
        guard data.count == 4 else {
            debugLog("❌ Invalid data length: \(data.count) bytes")
            completion(false)
            return
        }
        
        var command = Data([0xA2, page]) // WRITE command
        command.append(data)
        
        tag.sendMiFareCommand(commandPacket: command) { response, error in
            if let error = error {
                debugLog("❌ Write error at page \(page): \(error.localizedDescription)")
                completion(false)
            } else {
                debugLog("✓ Page \(page) written successfully")
                completion(true)
            }
        }
    }
    
    private func writeAllPages(tag: NFCMiFareTag, data: [UInt8], completion: @escaping (Bool) -> Void) {
        let startPage: UInt8 = 4
        let endPage: UInt8 = 31 // Pages 4 through 31 (28 pages total, 112 bytes)
        
        debugLog("📝 Starting write: \(data.count) bytes to \(endPage - startPage + 1) pages")
        debugLog("   Strategy: Direct writes (password auth not needed for this tag)")
        
        // Based on testing: PWD_AUTH causes connection loss on this tag
        // But direct writes actually DO work! Just write directly.
        self.performDirectWrites(tag: tag, data: data, startPage: startPage, endPage: endPage, completion: completion)
    }
    
    private func tryPasswordsAndWrite(tag: NFCMiFareTag, passwords: [[UInt8]], passwordIndex: Int, data: [UInt8], startPage: UInt8, endPage: UInt8, completion: @escaping (Bool) -> Void) {
        
        guard passwordIndex < passwords.count else {
            debugLog("❌ All \(passwords.count) passwords failed!")
            debugLog("   This tag requires a custom password that we don't know.")
            completion(false)
            return
        }
        
        let password = passwords[passwordIndex]
        debugLog("🔐 Trying password \(passwordIndex + 1)/\(passwords.count): \(password.map { String(format: "%02X", $0) }.joined(separator: " "))")
        
        var authCommand = Data([0x1B]) // PWD_AUTH
        authCommand.append(contentsOf: password)
        
        tag.sendMiFareCommand(commandPacket: authCommand) { response, error in
            if let error = error {
                debugLog("   ❌ Password \(passwordIndex + 1) failed: \(error.localizedDescription)")
                // Try next password
                self.tryPasswordsAndWrite(tag: tag, passwords: passwords, passwordIndex: passwordIndex + 1, data: data, startPage: startPage, endPage: endPage, completion: completion)
                return
            }
            
            // Check response
            if response.count >= 2 {
                let pack = response.prefix(2).map { String(format: "%02X", $0) }.joined(separator: " ")
                debugLog("   ✅ SUCCESS! Password \(passwordIndex + 1) worked! PACK: \(pack)")
                
                // Now write with this authenticated session
                self.performDirectWrites(tag: tag, data: data, startPage: startPage, endPage: endPage, completion: completion)
            } else if response.count == 1 && response[0] == 0x00 {
                debugLog("   ❌ Password \(passwordIndex + 1) rejected (NAK)")
                // Try next password
                self.tryPasswordsAndWrite(tag: tag, passwords: passwords, passwordIndex: passwordIndex + 1, data: data, startPage: startPage, endPage: endPage, completion: completion)
            } else {
                debugLog("   ⚠️ Unexpected response: \(response.map { String(format: "%02X", $0) }.joined(separator: " "))")
                // Try next password
                self.tryPasswordsAndWrite(tag: tag, passwords: passwords, passwordIndex: passwordIndex + 1, data: data, startPage: startPage, endPage: endPage, completion: completion)
            }
        }
    }
    
    private func performDirectWrites(tag: NFCMiFareTag, data: [UInt8], startPage: UInt8, endPage: UInt8, completion: @escaping (Bool) -> Void) {
        debugLog("📝 Starting authenticated writes...")
        
        // Create array of all write operations
        var writeOperations: [(page: UInt8, data: Data)] = []
        
        for page in startPage...endPage {
            let offset = Int(page - startPage) * 4
            guard offset < data.count else { break }
            
            var pageBytes = [UInt8](repeating: 0, count: 4)
            for i in 0..<4 {
                if offset + i < data.count {
                    pageBytes[i] = data[offset + i]
                }
            }
            writeOperations.append((page: page, data: Data(pageBytes)))
        }
        
        var currentIndex = 0
        
        func writeNext() {
            guard currentIndex < writeOperations.count else {
                debugLog("✅ Write complete: \(currentIndex) pages written")
                completion(true)
                return
            }
            
            let operation = writeOperations[currentIndex]
            
            debugLog("Writing page \(operation.page): \(operation.data.map { String(format: "%02X", $0) }.joined(separator: " "))")
            
            var writeCommand = Data([0xA2, operation.page])
            writeCommand.append(operation.data)
            
            tag.sendMiFareCommand(commandPacket: writeCommand) { writeResponse, writeError in
                if let writeError = writeError {
                    debugLog("❌ Write failed at page \(operation.page): \(writeError.localizedDescription)")
                    completion(false)
                    return
                }
                
                // Check response
                if writeResponse.count > 0 && writeResponse[0] == 0x0A {
                    debugLog("✓ Page \(operation.page) ACK")
                } else if writeResponse.count > 0 {
                    let code = writeResponse[0]
                    if code == 0x00 {
                        debugLog("⚠️ Page \(operation.page) NAK - auth may have expired")
                    } else {
                        debugLog("✓ Page \(operation.page) response: \(String(format: "0x%02X", code))")
                    }
                }
                
                currentIndex += 1
                
                // Tiny delay to avoid overwhelming tag
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.005) {
                    writeNext()
                }
            }
        }
        
        writeNext()
    }
}

// MARK: - NFCTagReaderSessionDelegate

extension NFCManager: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        debugLog("NFC session became active")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        debugLog("NFC session invalidated: \(error.localizedDescription)")
        
        DispatchQueue.main.async {
            self.isScanning = false
            if let nfcError = error as? NFCReaderError {
                if nfcError.code != .readerSessionInvalidationErrorUserCanceled {
                    self.statusMessage = "Session error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first else {
            session.invalidate(errorMessage: "No tags found")
            return
        }
        
        session.connect(to: firstTag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
                return
            }
            
            // Handle MiFare tags (NTAG213/215/216)
            guard case let .miFare(tag) = firstTag else {
                session.invalidate(errorMessage: "Unsupported tag type")
                return
            }
            
            // Get UID
            let uid = tag.identifier
            let uidString = uid.map { String(format: "%02X", $0) }.joined(separator: ":")
            
            DispatchQueue.main.async {
                self.tagUID = uidString
                self.tagType = self.detectTagType(tag)
                // Play detection haptic when tag is detected
                self.playDetectionHaptic()
            }
            
            // Perform operation based on current mode
            switch self.currentOperation {
            case .read:
                self.performRead(tag: tag, session: session)
                
            case .write(let data):
                self.performWrite(tag: tag, data: data, session: session)
                
            case .format:
                self.performFormat(tag: tag, session: session)
                
            case .checkLock:
                self.performLockCheck(tag: tag, session: session)
                
            case .verifyWrite:
                self.performVerifyWrite(tag: tag, session: session)
                
            case .none:
                session.invalidate()
            }
        }
    }
    
    private func performRead(tag: NFCMiFareTag, session: NFCTagReaderSession) {
        readPages(tag: tag, startPage: 4, count: 33) { readBytes in
            guard let readBytes = readBytes else {
                session.invalidate(errorMessage: "Failed to read tag")
                return
            }
            
            DispatchQueue.main.async {
                // Store the read bytes for parsing in ContentView
                self.lastReadBytes = readBytes
                self.statusMessage = "Tag read successfully - \(readBytes.count) bytes read"
                self.playSuccessHaptic()
                session.alertMessage = "Read successful!"
                session.invalidate()
            }
        }
    }
    
    private func performWrite(tag: NFCMiFareTag, data: RFIDTagData, session: NFCTagReaderSession) {
        let bytes = data.toBytes()
        debugLog("📋 Preparing to write \(bytes.count) bytes")
        debugLog("   Profile: \(data.profile.displayName)")
        debugLog("   Color: \(data.color)")
        debugLog("   Spool: \(data.spoolSize.rawValue)")
        
        // Store data for verification
        self.dataToVerify = bytes
        
        // Keep the session alive with informative message
        session.alertMessage = "Keep iPhone near tag - Writing data..."
        
        // Try writing directly without format first
        writeAllPages(tag: tag, data: bytes) { success in
            if success {
                DispatchQueue.main.async {
                    self.statusMessage = "✅ Write complete - Starting verification..."
                    self.playSuccessHaptic()
                }
                session.alertMessage = "✅ Write done! Keep near tag for verify..."
                
                // Wait a moment then start verification in new session
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    session.invalidate()
                    
                    // Auto-start verify session after brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.currentOperation = .verifyWrite
                        self.startSession(with: "Hold near tag to verify write...")
                    }
                }
            } else {
                debugLog("⚠️ Write failed. Checking if tag is password-protected...")
                
                // Automatically check lock status to help diagnose the issue
                self.checkLockBytes(tag: tag) { lockStatus in
                    DispatchQueue.main.async {
                        // Parse the lock status to see if it's password protected
                        if lockStatus.contains("PASSWORD PROTECTED") || lockStatus.contains("PASSWORD REQUIRED") {
                            self.statusMessage = "❌ Write failed: Tag is PASSWORD PROTECTED\n\n" +
                                               "This tag requires a password for writing.\n" +
                                               "Use the 'Status' button to see full lock details.\n\n" +
                                               "💡 Solution: Use blank NTAG215 tags instead."
                            self.playErrorHaptic()
                            session.invalidate(errorMessage: "❌ Tag is password protected")
                        } else if lockStatus.contains("LOCKED") && !lockStatus.contains("Unlocked") {
                            self.statusMessage = "❌ Write failed: Tag has write-protection\n\n" +
                                               "Some pages are locked.\n" +
                                               "Use 'Status' button for details.\n\n" +
                                               "Try: Format Tag first, or use different tag."
                            self.playErrorHaptic()
                            session.invalidate(errorMessage: "❌ Tag is write-protected")
                        } else {
                            // Unknown reason - provide general guidance
                            self.statusMessage = "❌ Write failed\n\n" +
                                               "Possible causes:\n" +
                                               "• Tag connection lost\n" +
                                               "• Tag incompatibility\n" +
                                               "• Unknown write protection\n\n" +
                                               "Try:\n" +
                                               "1. Check tag with 'Status' button\n" +
                                               "2. Try 'Format Tag' first\n" +
                                               "3. Use blank NTAG215 tag"
                            self.playErrorHaptic()
                            session.invalidate(errorMessage: "❌ Write failed - Check Status")
                        }
                        
                        // Store lock status for Status view
                        self.tagLockStatus = lockStatus
                    }
                }
            }
        }
    }
    
    private func performFormat(tag: NFCMiFareTag, session: NFCTagReaderSession) {
        formatTag(tag) { success in
            if success {
                DispatchQueue.main.async {
                    self.statusMessage = "✅ Tag formatted successfully"
                    self.playSuccessHaptic()
                }
                session.alertMessage = "Format successful!"
                session.invalidate()
            } else {
                debugLog("⚠️ Format failed. Checking if tag is password-protected...")
                
                // Automatically check lock status to help diagnose the issue
                self.checkLockBytes(tag: tag) { lockStatus in
                    DispatchQueue.main.async {
                        // Parse the lock status to see if it's password protected
                        if lockStatus.contains("PASSWORD PROTECTED") || lockStatus.contains("PASSWORD REQUIRED") {
                            self.statusMessage = "❌ Format failed: Tag is PASSWORD PROTECTED\n\n" +
                                               "This tag requires a password and cannot be formatted.\n" +
                                               "Use the 'Status' button to see full lock details.\n\n" +
                                               "💡 Solution: Use blank NTAG215 tags instead."
                            self.playErrorHaptic()
                            session.invalidate(errorMessage: "❌ Tag is password protected")
                        } else if lockStatus.contains("PERMANENTLY LOCKED") {
                            self.statusMessage = "❌ Format failed: Tag is PERMANENTLY LOCKED\n\n" +
                                               "Lock bits cannot be changed.\n" +
                                               "This tag cannot be reformatted.\n\n" +
                                               "💡 Use a different blank tag."
                            self.playErrorHaptic()
                            session.invalidate(errorMessage: "❌ Tag permanently locked")
                        } else if lockStatus.contains("LOCKED") && !lockStatus.contains("Unlocked") {
                            self.statusMessage = "❌ Format failed: Tag has write-protection\n\n" +
                                               "Some pages are locked and cannot be cleared.\n" +
                                               "Use 'Status' button for details.\n\n" +
                                               "💡 Use a different blank tag."
                            self.playErrorHaptic()
                            session.invalidate(errorMessage: "❌ Tag is write-protected")
                        } else {
                            // Unknown reason - provide general guidance
                            self.statusMessage = "❌ Format failed\n\n" +
                                               "Possible causes:\n" +
                                               "• Tag connection lost\n" +
                                               "• Tag incompatibility\n" +
                                               "• Unknown write protection\n\n" +
                                               "Try:\n" +
                                               "1. Check tag with 'Status' button\n" +
                                               "2. Use blank NTAG215 tag"
                            self.playErrorHaptic()
                            session.invalidate(errorMessage: "❌ Format failed - Check Status")
                        }
                        
                        // Store lock status for Status view
                        self.tagLockStatus = lockStatus
                    }
                }
            }
        }
    }
    
    private func performLockCheck(tag: NFCMiFareTag, session: NFCTagReaderSession) {
        checkLockBytes(tag: tag) { lockStatus in
            DispatchQueue.main.async {
                self.tagLockStatus = lockStatus
                self.statusMessage = "Lock status checked"
            }
            debugLog(lockStatus)
            session.alertMessage = "Lock status retrieved"
            session.invalidate()
        }
    }
    
    private func performVerifyWrite(tag: NFCMiFareTag, session: NFCTagReaderSession) {
        guard let expectedData = dataToVerify else {
            session.invalidate(errorMessage: "No data to verify")
            return
        }
        
        debugLog("🔍 Starting verification read...")
        
        readPages(tag: tag, startPage: 4, count: 33) { readBytes in
            guard let readBytes = readBytes else {
                DispatchQueue.main.async {
                    self.statusMessage = "❌ Verification failed - could not read tag"
                    self.playErrorHaptic()
                }
                session.invalidate(errorMessage: "Verification read failed")
                return
            }
            
            // Compare first 112 bytes (28 pages * 4 bytes)
            let bytesToCompare = min(expectedData.count, readBytes.count, 112)
            let readData = Array(readBytes.prefix(bytesToCompare))
            let expectedSubset = Array(expectedData.prefix(bytesToCompare))
            
            var mismatchCount = 0
            var firstMismatch: (index: Int, expected: UInt8, actual: UInt8)?
            
            for i in 0..<bytesToCompare {
                if readData[i] != expectedSubset[i] {
                    mismatchCount += 1
                    if firstMismatch == nil {
                        firstMismatch = (i, expectedSubset[i], readData[i])
                    }
                }
            }
            
            if mismatchCount == 0 {
                debugLog("✅ VERIFICATION SUCCESS: All \(bytesToCompare) bytes match!")
                DispatchQueue.main.async {
                    self.statusMessage = "✅ Write verified successfully - Data is correct!"
                    self.playSuccessHaptic()
                }
                session.alertMessage = "✅ Verified! Data written correctly."
            } else {
                debugLog("❌ VERIFICATION FAILED: \(mismatchCount) byte mismatches")
                if let first = firstMismatch {
                    debugLog("   First mismatch at byte \(first.index): Expected \(String(format: "%02X", first.expected)), Got \(String(format: "%02X", first.actual))")
                }
                DispatchQueue.main.async {
                    self.statusMessage = "❌ Verification failed - \(mismatchCount) bytes don't match"
                    self.playErrorHaptic()
                }
                session.alertMessage = "❌ Verify failed - Data mismatch"
            }
            
            session.invalidate()
            self.dataToVerify = nil
        }
    }
}
