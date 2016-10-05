import Foundation

extension ViewController {
    func startOutOfRangeTimer() {
        lastTimeSeenTimer = NSTimer.scheduledTimerWithTimeInterval(
            2.0,
            target: self,
            selector: #selector(checkIfTagOutOfRange),
            userInfo: nil,
            repeats: true
        )
    }

    func updateLastSeenTime() {
        lastTimeSeen = NSDate()
    }

    func checkIfTagOutOfRange() {
        let timeUntilOutOfRange = 20.0
        let now = NSDate()
        let diff = Double(now.timeIntervalSinceDate(lastTimeSeen!))

        if diff > timeUntilOutOfRange {
            self.success("out of range")
            resetDemo()
        }
    }

    private func resetDemo() {
        DemoState.standBy()

        lastTimeSeenTimer?.invalidate()
        lastTimeSeenTimer = nil

        challenge = nil
        identity = nil
        done = false
        currentPeripheral = nil
    }
}