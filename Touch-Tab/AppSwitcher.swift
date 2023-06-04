import Cocoa

class AppSwitcher {
    private static let keyboardEventSource = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
    private static let tabKey = CGKeyCode(0x30);
    private static let leftCommandKey = CGKeyCode(0x37);

    static func selectInAppSwitcher() {
        postKeyEvent(key: leftCommandKey, down: false)
    }

    static func cmdTab() {
        postKeyEvent(key: tabKey, down: true, flags: .maskCommand)
        postKeyEvent(key: tabKey, down: false, flags: .maskCommand)
    }

    static func cmdShiftTab() {
        postKeyEvent(key: tabKey, down: true, flags: [.maskCommand, .maskShift])
        postKeyEvent(key: tabKey, down: false, flags: [.maskCommand, .maskShift])
    }

    private static func postKeyEvent(key: CGKeyCode, down: Bool, flags: CGEventFlags = []) {
        let event = CGEvent(keyboardEventSource: keyboardEventSource, virtualKey: key, keyDown: down)
        event?.flags = flags
        event?.post(tap: CGEventTapLocation.cghidEventTap)
    }
}
