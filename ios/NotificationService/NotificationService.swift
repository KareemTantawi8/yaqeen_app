import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    private let notificationSoundName = UNNotificationSoundName("yaqeen_notification.caf")

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let content = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // Force the bundled Yaqeen chime for every FCM push (background/killed).
        content.sound = UNNotificationSound(named: notificationSoundName)

        guard let imageURL = extractImageURL(from: request.content.userInfo) else {
            contentHandler(content)
            return
        }

        downloadImage(from: imageURL) { attachment in
            if let attachment = attachment {
                content.attachments = [attachment]
            }
            contentHandler(content)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let handler = contentHandler, let content = bestAttemptContent {
            content.sound = UNNotificationSound(named: notificationSoundName)
            handler(content)
        }
    }

    // FCM puts the image URL at fcm_options.image (standard) or at the top-level
    // "image" key depending on the sender SDK version.
    private func extractImageURL(from userInfo: [AnyHashable: Any]) -> URL? {
        if let fcmOptions = userInfo["fcm_options"] as? [String: Any],
           let urlString = fcmOptions["image"] as? String,
           let url = URL(string: urlString) {
            return url
        }
        if let urlString = userInfo["image"] as? String,
           let url = URL(string: urlString) {
            return url
        }
        return nil
    }

    private func downloadImage(
        from url: URL,
        completion: @escaping (UNNotificationAttachment?) -> Void
    ) {
        let task = URLSession.shared.downloadTask(with: url) { location, _, _ in
            guard let location = location else {
                completion(nil)
                return
            }
            let tmpDir = FileManager.default.temporaryDirectory
            // Use a unique name to avoid collisions from rapid back-to-back pushes.
            let filename = "\(UUID().uuidString)-\(url.lastPathComponent)"
            let tmpFile = tmpDir.appendingPathComponent(filename)
            try? FileManager.default.moveItem(at: location, to: tmpFile)
            let attachment = try? UNNotificationAttachment(
                identifier: filename,
                url: tmpFile,
                options: nil
            )
            completion(attachment)
        }
        task.resume()
    }
}
