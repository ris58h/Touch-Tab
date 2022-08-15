import M5MultitouchSupport

class SwipeManager {
    private static let accVelXThreshold: Float = 10
    private static let debounceTimeBeforeActivation: Double = 0.1

    static func addSwipeListener(listener: @escaping (EventType) -> Void) -> M5MultitouchListener? {
        var accVelX: Float = 0
        var activated = false
        var segmentStartTime: Date? = nil

        func startOrContinueGesture() {
            let direction: EventType.Direction = accVelX < 0 ? .left : .right

            accVelX = 0
            activated = true
            segmentStartTime = nil

            listener(.startOrContinue(direction: direction))
        }

        func endGesture() {
            accVelX = 0
            activated = false
            segmentStartTime = nil

            listener(.end)
        }

        return M5MultitouchManager.shared().addListener {event in
            if event == nil {
                return
            }

            //TODO: it has wrong size if casted 'as! [M5MultitouchTouch]'
            let touches: [Any] = event!.touches

            // We don't care about non-3-fingers swipes.
            if touches.capacity != 3 {
                // Except when we already started a gesture, so we need to end it.
                //TODO: sometimes all fingers are released simultaneously, so we don't get 1-finger event and just stuck in App Switcher.
                if (touches.capacity == 1 || touches.capacity > 3) {
                    if activated {
                        endGesture()
                    } else if segmentStartTime != nil {
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
            if segmentStartTime == nil {
                segmentStartTime = Date()
            }
            if -segmentStartTime!.timeIntervalSinceNow < debounceTimeBeforeActivation && !activated {
                return
            }

            startOrContinueGesture()
        }
    }

    private static func horizontalSwipeVelocity(touches: [Any]) -> Float? {
        var allRight = true
        var allLeft = true
        var sumVelX = Float(0)
        var sumVelY = Float(0)
        for touch in touches {
            let mTouch = touch as! M5MultitouchTouch
            allRight = allRight && mTouch.velX >= 0
            allLeft = allLeft && mTouch.velX <= 0
            sumVelX += mTouch.velX
            sumVelY += mTouch.velY
        }
        // All fingers should move in the same direction.
        if !allRight && !allLeft {
            return nil
        }

        let velX = sumVelX / Float(touches.capacity)
        let velY = sumVelY / Float(touches.capacity)
        // Only horizontal swipes are interesting.
        if abs(velX) <= abs(velY) {
            return nil
        }

        return velX
    }

    static func removeSwipeListener(listener: M5MultitouchListener) {
        //TODO: there is an issue with releasing devices. See https://github.com/mhuusko5/M5MultitouchSupport/issues/1
        //TODO: consider to use https://github.com/Kyome22/OpenMultitouchSupport
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
