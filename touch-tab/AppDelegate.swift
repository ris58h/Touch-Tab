import Cocoa
import M5MultitouchSupport
import CoreGraphics

class AppDelegate: NSObject, NSApplicationDelegate {
    private static let tabKey = CGKeyCode(0x30);

    var statusBarItem: NSStatusItem!

    var listener: M5MultitouchListener?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createMenu()

        if !AXIsProcessTrusted() {
            //TODO: notify the user about it!
            return
        }

        self.listener = SwipeManager.addSwipeListener {
            switch $0 {
            case .start(.left):
                AppDelegate.cmdShiftTab()
            case .start(.right):
                AppDelegate.cmdTab()
            case .end:
                AppDelegate.selectInAppSwitcher()
            }
        }
    }

    private static func selectInAppSwitcher() {
        postKeyEvent(key: 0x37, down: false)
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
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(
            withLength: NSStatusItem.variableLength)//TODO
        statusBarItem.button?.title = "🌰"//TODO

        let statusBarMenu = NSMenu(title: "Touch-Tab")
        statusBarItem.menu = statusBarMenu

        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(AppDelegate.quit),
            keyEquivalent: "")
    }

    @objc func quit() {
        if self.listener != nil {
            SwipeManager.removeSwipeListener(listener: self.listener!)
        }
        NSApplication.shared.terminate(self)
    }
}
