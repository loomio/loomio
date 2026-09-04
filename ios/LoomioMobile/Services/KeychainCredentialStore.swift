import Foundation
import Security

struct StoredDeviceCredential: Codable, Equatable, Sendable {
    let deviceID: UUID
    let refreshToken: String
    let apnsToken: String?
    let apnsEnvironment: String?

    init(
        deviceID: UUID,
        refreshToken: String,
        apnsToken: String? = nil,
        apnsEnvironment: String? = nil
    ) {
        self.deviceID = deviceID
        self.refreshToken = refreshToken
        self.apnsToken = apnsToken
        self.apnsEnvironment = apnsEnvironment
    }
}

enum KeychainCredentialStore {
    private static let service = "org.loomio.mobile.device"

    static func save(_ credential: StoredDeviceCredential, for hostID: UUID) throws {
        let data = try JSONEncoder().encode(credential)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: hostID.uuidString
        ]
        let updates: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, updates as CFDictionary)
        if updateStatus == errSecSuccess { return }
        guard updateStatus == errSecItemNotFound else { throw KeychainError.unhandled(updateStatus) }

        var attributes = query
        updates.forEach { attributes[$0.key] = $0.value }
        let addStatus = SecItemAdd(attributes as CFDictionary, nil)
        guard addStatus == errSecSuccess else { throw KeychainError.unhandled(addStatus) }
    }

    static func load(for hostID: UUID) throws -> StoredDeviceCredential? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: hostID.uuidString,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.unhandled(status)
        }
        return try JSONDecoder().decode(StoredDeviceCredential.self, from: data)
    }

    static func delete(for hostID: UUID) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: hostID.uuidString
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum KeychainError: LocalizedError {
    case unhandled(OSStatus)

    var errorDescription: String? {
        switch self {
        case .unhandled(let status): "Keychain operation failed (\(status))."
        }
    }
}
