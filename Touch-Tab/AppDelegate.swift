import Cocoa
import M5MultitouchSupport
import CoreGraphics

class AppDelegate: NSObject, NSApplicationDelegate {
    private static let tabKey = CGKeyCode(0x30);
    private static let leftCommandKey = CGKeyCode(0x37);

    private var statusBarItem: NSStatusItem!
    private var listener: M5MultitouchListener?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createMenu()

        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessEnabled {
            return
        }

        self.listener = SwipeManager.addSwipeListener(AppDelegate.processSwipe)
    }
    
    private static func processSwipe(_ eventType: SwipeManager.EventType) {
        switch eventType {
        case .startOrContinue(.left):
            AppDelegate.cmdShiftTab()
        case .startOrContinue(.right):
            AppDelegate.cmdTab()
        case .end:
            AppDelegate.selectInAppSwitcher()
        }
    }

    private static func selectInAppSwitcher() {
        postKeyEvent(key: leftCommandKey, down: false)
    }

    private static func cmdTab() {
        postKeyEvent(key: tabKey, down: true, flags: .maskCommand)
        postKeyEvent(key: tabKey, down: false, flags: .maskCommand)
    }

    private static func cmdShiftTab() {
        postKeyEvent(key: tabKey, down: true, flags: [.maskCommand, .maskShift])
        postKeyEvent(key: tabKey, down: false, flags: [.maskCommand, .maskShift])
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

    func createMenu() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = NSImage(named: "StatusIcon")
        statusBarItem.button?.image?.isTemplate = true
        statusBarItem.button?.toolTip = "Touch-Tab"

        let statusBarMenu = NSMenu(title: "")
        statusBarItem.menu = statusBarMenu
        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(AppDelegate.quit),
            keyEquivalent: "")
    }

    @objc func quit() {
        if self.listener != nil {
            SwipeManager.removeSwipeListener(self.listener!)
        }
        NSApplication.shared.terminate(self)
    }
}
