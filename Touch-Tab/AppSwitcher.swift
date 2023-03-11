import Cocoa

class AppSwitcher {
    private static let tabKey = CGKeyCode(0x30);
    private static let leftCommandKey = CGKeyCode(0x37);

    // It doesn't always correspond to the actual state of App Switcher but it's enough for now.
    private(set) static var isActive = false

    static func selectInAppSwitcher() {
        postKeyEvent(key: leftCommandKey, down: false)
        
        isActive = false
    }

    static func cmdTab() {
        postKeyEvent(key: tabKey, down: true, flags: .maskCommand)
        postKeyEvent(key: tabKey, down: false, flags: .maskCommand)
        
        isActive = true
    }

    static func cmdShiftTab() {
        postKeyEvent(key: tabKey, down: true, flags: [.maskCommand, .maskShift])
        postKeyEvent(key: tabKey, down: false, flags: [.maskCommand, .maskShift])
        
        isActive = true
    }

    private static func postKeyEvent(key: CGKeyCode, down: Bool, flags: CGEventFlags? = nil) {
        let event = CGEvent(
            keyboardEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
            virtualKey: CGKeyCode(key),
            keyDown: down)
        if flags != nil {
            event?.flags = flags!
        }
        event?.post(tap: CGEventTapLocation.cghidEventTap)
    }
}
