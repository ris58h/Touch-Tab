import Cocoa

class SwipeManager {
    private static let accVelXThreshold: Float = 0.07
    private static let debounceTimeBeforeActivation: Double = 0.07

    private static var eventTap: CFMachPort? = nil
    private static var accVelX: Float = 0
    private static var prevTouchPositions: [String: NSPoint] = [:]
    private static var debounceStartTime: Date? = nil

    //TODO: move it somewhere else?
    private static func listener(_ eventType: EventType) {
        switch eventType {
        case .startOrContinue(.left):
            AppSwitcher.cmdShiftTab()
        case .startOrContinue(.right):
            AppSwitcher.cmdTab()
        case .end:
            AppSwitcher.selectInAppSwitcher()
        }
    }

    static func start() {
        if eventTap != nil {
            debugPrint("SwipeManager is already started")
            return
        }
        eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: NSEvent.EventTypeMask.gesture.rawValue,
            callback: { proxy, type, cgEvent, userInfo in
                return SwipeManager.eventHandler(proxy: proxy, eventType: type, cgEvent: cgEvent, userInfo: userInfo)
            },
            userInfo: nil
        )
        if eventTap == nil {
            return
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(nil, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
        CGEvent.tapEnable(tap: eventTap!, enable: true)
    }
    
    private static func eventHandler(proxy: CGEventTapProxy, eventType: CGEventType, cgEvent: CGEvent, userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
        if eventType.rawValue == NSEvent.EventType.gesture.rawValue, let nsEvent = NSEvent(cgEvent: cgEvent) {
            touchEventHandler(nsEvent)
        } else if (eventType == .tapDisabledByUserInput || eventType == .tapDisabledByTimeout) {
            CGEvent.tapEnable(tap: eventTap!, enable: true)
        }
        return Unmanaged.passUnretained(cgEvent)
    }
    
    private static func touchEventHandler(_ nsEvent: NSEvent) {
        let touches = nsEvent.allTouches()

        // Sometimes there are empty touch events that we have to skip. There are no empty touch events if Mission Control or App Expose use 3-finger swipes though.
        if touches.isEmpty {
            return
        }
        let touchesCount = touches.allSatisfy({ $0.phase == .ended }) ? 0 : touches.count
        
        // We don't care about non-3-fingers swipes.
        if touchesCount != 3 {
            // Except when we already started a gesture, so we need to end it.
            if touchesCount < 2 || touchesCount > 3 {
                if AppSwitcher.isActive {
                    endGesture()
                } else if debounceStartTime != nil {
                    // We have start event skipped due to debounce, so we need to call it first.
                    startOrContinueGesture()
                    endGesture()
                }
            }
            clearState()
            return
        }

        let velX = SwipeManager.horizontalSwipeVelocity(touches: touches)
        // We don't care about non-horizontal swipes.
        if velX == nil {
            return
        }

        accVelX += velX!
        // Not enough swiping.
        if abs(accVelX) < accVelXThreshold {
            return
        }

        // Debounce events before activation to prevent multiple listener calls on one powerful swipe.
        if debounceStartTime == nil {
            debounceStartTime = Date()
        }
        if -debounceStartTime!.timeIntervalSinceNow < debounceTimeBeforeActivation && !AppSwitcher.isActive {
            return
        }

        startOrContinueGesture()
        clearState()
    }
    
    private static func clearState() {
        accVelX = 0
        prevTouchPositions.removeAll()
        debounceStartTime = nil
    }
    
    private static func startOrContinueGesture() {
        let direction: EventType.Direction = accVelX < 0 ? .left : .right
        listener(.startOrContinue(direction: direction))
    }

    private static func endGesture() {
        listener(.end)
    }

    private static func horizontalSwipeVelocity(touches: Set<NSTouch>) -> Float? {
        var allRight = true
        var allLeft = true
        var sumVelX = Float(0)
        var sumVelY = Float(0)
        for touch in touches {
            let (velX, velY) = touchVelocity(touch)
            allRight = allRight && velX >= 0
            allLeft = allLeft && velX <= 0
            sumVelX += velX
            sumVelY += velY

            if touch.phase == .ended {
                prevTouchPositions.removeValue(forKey: "\(touch.identity)")
            } else {
                prevTouchPositions["\(touch.identity)"] = touch.normalizedPosition
            }
        }
        // All fingers should move in the same direction.
        if !allRight && !allLeft {
            return nil
        }

        let velX = sumVelX / Float(touches.count)
        let velY = sumVelY / Float(touches.count)
        // Only horizontal swipes are interesting.
        if abs(velX) <= abs(velY) {
            return nil
        }

        return velX
    }
    
    private static func touchVelocity(_ touch: NSTouch) -> (Float, Float) {
        guard let prevPosition = prevTouchPositions["\(touch.identity)"] else {
            return (0, 0)
        }
        let position = touch.normalizedPosition
        return (Float(position.x - prevPosition.x), Float(position.y - prevPosition.y))
    }

    enum EventType {
        case startOrContinue(direction: Direction)
        case end

        enum Direction {
            case left
            case right
        }
    }
}
