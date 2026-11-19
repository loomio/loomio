import UserNotifications
import WebKit

enum HostDataCleaner {
    @MainActor
    static func websiteDataStore(for host: ConnectedHost) -> WKWebsiteDataStore {
        host.usesLegacyDataStore ? .default() : WKWebsiteDataStore(forIdentifier: host.id)
    }

    @MainActor
    static func clearData(for host: ConnectedHost, registrationID: UUID?) async {
        let dataStore = websiteDataStore(for: host)
        if host.usesLegacyDataStore {
            let records = await dataStore.dataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())
            let hostName = host.origin.host()?.lowercased()
            let matching = records.filter { record in
                let name = record.displayName.lowercased()
                return name == hostName || (hostName.map { name.hasSuffix(".\($0)") } ?? false)
            }
            await dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: matching)
        } else {
            await dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)
        }

        let center = UNUserNotificationCenter.current()
        let delivered = await center.deliveredNotifications()
        let pending = await center.pendingNotificationRequests()
        let belongsToHost: (UNNotificationRequest) -> Bool = { request in
            if request.identifier.hasPrefix("host:\(host.id.uuidString):") { return true }
            guard let registrationID,
                  let value = request.content.userInfo["registration_id"] as? String else { return false }
            return UUID(uuidString: value) == registrationID
        }
        center.removeDeliveredNotifications(withIdentifiers: delivered.map(\.request).filter(belongsToHost).map(\.identifier))
        center.removePendingNotificationRequests(withIdentifiers: pending.filter(belongsToHost).map(\.identifier))
    }
}
