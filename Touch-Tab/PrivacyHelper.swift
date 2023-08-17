import Cocoa

class PrivacyHelper {
    static func isProcessTrustedWithPrompt() -> Bool {
        //TODO: Investigation required. Calling AXIsProcessTrustedWithOptions in sandboxed app doesn't prompt user (at least in Ventura 13.4.1) but creating CGEventTap does it.
        let isAccessibilityPermissionGranted = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true] as CFDictionary)
        if isAccessibilityPermissionGranted {
            return true
        } else {
            PrivacyHelper.promptForAccessibilityPermissionFromSandbox()
            return false
        }
    }

    private static func promptForAccessibilityPermissionFromSandbox() {
        _ = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: NSEvent.EventTypeMask.gesture.rawValue,
            callback: dummyEventHandler,
            userInfo: nil
        )
    }
}

fileprivate func dummyEventHandler(proxy: CGEventTapProxy, eventType: CGEventType, cgEvent: CGEvent, userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    debugPrint("Should never happen!")
    return Unmanaged.passUnretained(cgEvent)
}
