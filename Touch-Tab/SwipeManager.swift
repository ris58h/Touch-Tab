import M5MultitouchSupport

class SwipeManager {
    private static let accVelXThreshold: Float = 7
    private static let debounceTimeBeforeActivation: Double = 0.07

    static func addSwipeListener(_ listener: @escaping (EventType) -> Void) -> M5MultitouchListener? {
        var accVelX: Float = 0
        var activated = false
        var touchStartTime: Date? = nil

        func startOrContinueGesture() {
            let direction: EventType.Direction = accVelX < 0 ? .left : .right

            accVelX = 0
            activated = true
            touchStartTime = nil

            listener(.startOrContinue(direction: direction))
        }

        func endGesture() {
            accVelX = 0
            activated = false
            touchStartTime = nil

            listener(.end)
        }

        return M5MultitouchManager.shared().addListener {event in
            if event == nil {
                return
            }

            let touches = event!.touches as! [M5MultitouchTouch]

            // We don't care about non-3-fingers swipes.
            if touches.count != 3 {
                // Except when we already started a gesture, so we need to end it.
                if (touches.count < 2 || touches.count > 3) {
                    if activated {
                        endGesture()
                    } else if touchStartTime != nil {
                        // We have start event skipped due to debounce, so we need to call it first.
                        startOrContinueGesture()
                        endGesture()
                    }
                }
                return
            }

            let velX = SwipeManager.horizontalSwipeVelocity(touches: touches)
            // We don't care about non-horizontal swipes.
            if velX == nil {
                return
            }

            // Reset acc if the swipe has the opposite direction to have a smoother experience.
            if velX!.sign != accVelX.sign {
                accVelX = 0
            }

            accVelX += velX!
            // Not enough swiping.
            if abs(accVelX) < accVelXThreshold {
                return
            }

            // Debounce events before activation to prevent multiple listener calls on one powerful swipe.
            if touchStartTime == nil {
                touchStartTime = Date()
            }
            if -touchStartTime!.timeIntervalSinceNow < debounceTimeBeforeActivation && !activated {
                return
            }

            startOrContinueGesture()
        }
    }

    private static func horizontalSwipeVelocity(touches: [M5MultitouchTouch]) -> Float? {
        var allRight = true
        var allLeft = true
        var sumVelX = Float(0)
        var sumVelY = Float(0)
        for touch in touches {
            allRight = allRight && touch.velX >= 0
            allLeft = allLeft && touch.velX <= 0
            sumVelX += touch.velX
            sumVelY += touch.velY
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

    static func removeSwipeListener(_ listener: M5MultitouchListener) {
        M5MultitouchManager.shared().remove(listener)
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
