import AppKit
import SwiftUI

func announce(_ text: String) {
    var message = AttributedString(text)
    message.accessibilitySpeechAnnouncementPriority = .low
    AccessibilityNotification.Announcement(message).post()
}
