import M5MultitouchSupport

class SwipeManager {
    private static let swipeVelXThreshold = Float(10)

    static func addSwipeListener(listener: @escaping (EventType) -> Void) -> M5MultitouchListener? {
        var accVelX = Float(0)
        var activated = false

        func endGesture() {
            accVelX = 0
            activated = false
            listener(.select)
        }

        return M5MultitouchManager.shared().addListener {event in
            if event == nil {
                return
            }

            //TODO: it has wrong size if casted 'as! [M5MultitouchTouch]'
            let touches: [Any] = event!.touches

            // Less then 2 fingers is considered as the end of the gesture.
            if touches.capacity == 1 && activated {
                //TODO: sometimes all fingers released simultaneously, so we don't get 1-finger event and just stuck in App Switcher. Consider scheduled checking.
                endGesture()
                return
            }

            // Just let it go.
            if touches.capacity < 3 {
                return
            }

            // To prevent false activation for more fingers swipe.
            if touches.capacity > 3 {
                if activated {
                    endGesture()
                }
                return
            }

            let velX = SwipeManager.horizontalSwipeVelocity(touches: touches)
            if velX == nil {
                return
            }

            accVelX += velX!
            // Not enough swiping.
            if abs(accVelX) < swipeVelXThreshold {
                return
            }

            accVelX = 0
            activated = true

            listener(.swipe(direction: velX! < 0 ? .left : .right))
        }
    }

    static func horizontalSwipeVelocity(touches: [Any]) -> Float? {
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
        case swipe(direction: Direction)
        case select

        enum Direction {
            case left
            case right
        }
    }
}
