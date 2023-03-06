import Cocoa
import M5MultitouchSupport

class AppDelegate: NSObject, NSApplicationDelegate {
    private static let tabKey = CGKeyCode(0x30);
    private static let leftCommandKey = CGKeyCode(0x37);

    private static let statusIcon = templateImage(named: "StatusIcon")
    private static let statusIconWarning = templateImage(named: "StatusIcon-Warning")

    private var statusBarItem: NSStatusItem!
    private var listener: M5MultitouchListener!

    private static func templateImage(named: String) -> NSImage? {
        let image = NSImage(named: named)
        image?.isTemplate = true
        return image
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createStatusBarItem()
        warnAboutAccessibilityPermissionIfNeeded()
        addSwipeListener()
    }
    
    private func addSwipeListener() {
        self.listener = SwipeManager.addSwipeListener {
            switch $0 {
            case .startOrContinue(.left):
                AppDelegate.cmdShiftTab()
            case .startOrContinue(.right):
                AppDelegate.cmdTab()
            case .end:
                AppDelegate.selectInAppSwitcher()
            }
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

    private func warnAboutAccessibilityPermissionIfNeeded() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let isAccessibilityPermissionGranted = AXIsProcessTrustedWithOptions(options)
        if !isAccessibilityPermissionGranted {
            statusBarItem.button?.image = AppDelegate.statusIconWarning
            statusBarItem.menu?.insertItem(AppDelegate.accessibilityWarningMenuItem(), at: 0)
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
                if AXIsProcessTrusted() {
                    statusBarItem.button?.image = AppDelegate.statusIcon
                    statusBarItem.menu?.removeItem(at: 0)
                    timer.invalidate()
                }
            }
        }
    }

    private func createStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = AppDelegate.statusIcon
        statusBarItem.button?.toolTip = "Touch-Tab"

        statusBarItem.menu = NSMenu()
        statusBarItem.menu?.addItem(
            withTitle: "Quit Touch-Tab",
            action: #selector(AppDelegate.quit),
            keyEquivalent: "")
    }
    
    private static func accessibilityWarningMenuItem() -> NSMenuItem {
        let menuItem = NSMenuItem(title: "Open System Settings", action: #selector(openPrivacyAccessibility), keyEquivalent: "")
        menuItem.image = templateImage(named: "MenuItem-Warning")
        menuItem.toolTip = "Grant access to this application in Privacy & Secutiry settings, located in System Settings"
        return menuItem
    }

    @objc private func openPrivacyAccessibility() {
        let privacyAccessibilityURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(privacyAccessibilityURL)
    }
    
    @objc private func quit() {
        if self.listener != nil {
            SwipeManager.removeSwipeListener(self.listener)
        }
        NSApplication.shared.terminate(self)
    }
}
