import UserNotifications
import WebKit

enum HostDataCleaner {
    @MainActor
    static func clearData(for host: ConnectedHost) async {
        let dataStore = WKWebsiteDataStore.default()
        let records = await dataStore.dataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())
        let hostName = host.origin.host()?.lowercased()
        let matchingRecords = records.filter { record in
            let name = record.displayName.lowercased()
            return name == hostName || (hostName.map { name.hasSuffix(".\($0)") } ?? false)
        }
        if !matchingRecords.isEmpty {
            await dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: matchingRecords)
        }

        let center = UNUserNotificationCenter.current()
        let delivered = await center.deliveredNotifications()
        let pending = await center.pendingNotificationRequests()
        let prefix = "host:\(host.id.uuidString):"
        center.removeDeliveredNotifications(withIdentifiers: delivered.map(\.request.identifier).filter { $0.hasPrefix(prefix) })
        center.removePendingNotificationRequests(withIdentifiers: pending.map(\.identifier).filter { $0.hasPrefix(prefix) })
    }
}
