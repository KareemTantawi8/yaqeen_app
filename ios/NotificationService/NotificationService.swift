import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard
            let content = bestAttemptContent,
            let imageURLString = request.content.userInfo["fcm_options"] as? [String: Any],
            let urlString = imageURLString["image"] as? String,
            let imageURL = URL(string: urlString)
        else {
            contentHandler(bestAttemptContent ?? request.content)
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
            handler(content)
        }
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
            let tmpFile = tmpDir.appendingPathComponent(url.lastPathComponent)
            try? FileManager.default.moveItem(at: location, to: tmpFile)
            let attachment = try? UNNotificationAttachment(
                identifier: url.lastPathComponent,
                url: tmpFile,
                options: nil
            )
            completion(attachment)
        }
        task.resume()
    }
}
